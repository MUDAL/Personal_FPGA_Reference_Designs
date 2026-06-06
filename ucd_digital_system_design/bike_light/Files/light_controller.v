`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University College Dublin (UCD)
// Engineer: Olaoluwa Raji
// 
// Create Date: 29.10.2025 23:03:05
// Design Name: 
// Module Name: light_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Defaults:
// Number of cycles to be counted before toggling the "light" output.
// We're using a 2 Hz flashing frequency hence we need to toggle every
// 0.25 seconds (since 1 period = 0.5 seconds).
// With a 5 MHz clock, we'll need 1,250,000 cycles and a 21-bit counter.
module light_controller #(parameter NUM_HALF_PERIOD_CYCLES = 1_250_000,
                          parameter NUM_DEBOUNCE_CYCLES    = 50_000)
                         (input  reset,
                          input  clock,
                          input  button,
                          output light);
                          
    localparam MAX_CYCLE = NUM_HALF_PERIOD_CYCLES - 1;
    
    // FSM States
    localparam ST_OFF   =  2'b00;
    localparam ST_ON    =  2'b01;
    localparam ST_FLASH =  2'b10;    
    
    // Internal signals for FSM
    reg [1:0] state_reg;
    reg [1:0] state_next;
    
    wire press;
    wire time_to_toggle;
    reg  light_out;
    
    // Internal signals for "flashing/blinking" logic
    reg [20:0] flash_count_reg;
    reg [20:0] flash_count_next;    
    reg        flash_enable;
    reg        blink_reg;
    reg        blink_next;
    
    // Instantiate "Button Debounce" logic
    debounce #(.NUM_CYCLES (NUM_DEBOUNCE_CYCLES))
        cleanup(.reset  (reset),
                .clock  (clock),
                .button (button),
                .press  (press));
                     
    // Next-state logic
    always @(state_reg, press) begin
        state_next = state_reg;
        case(state_reg)
            ST_OFF: begin
                if(press) state_next = ST_ON;
            end
            ST_ON: begin
                if(press) state_next = ST_FLASH;
            end
            ST_FLASH: begin
                if(press) state_next = ST_OFF;
            end
            default: state_next = ST_OFF;
        endcase
    end
    
    // FSM outputs
    always @(state_reg, blink_reg) begin
        case(state_reg)
            ST_OFF: begin
                light_out    = 1'b0;
                flash_enable = 1'b0;
            end
            ST_ON: begin
                light_out    = 1'b1;
                flash_enable = 1'b0;
            end
            ST_FLASH: begin
                light_out    = blink_reg;
                flash_enable = 1'b1;
            end
            default: begin
                light_out    = 1'b0;
                flash_enable = 1'b0;
            end
        endcase
    end
    
    // The flashing/blinking logic has two main sections.
    // These are the "toggling logic" and the hardware (counter-based) 
    // to drive it.
    assign time_to_toggle = (flash_count_reg == MAX_CYCLE);
    
    // Toggling logic
    always @(time_to_toggle, blink_reg) begin
        if(time_to_toggle) blink_next = ~blink_reg;
        else               blink_next =  blink_reg;
    end  
    
    // Counter-based logic to drive the "toggling logic"
    always @(flash_enable, time_to_toggle, flash_count_reg) begin
        if(!flash_enable)      flash_count_next = 21'd0;
        else begin
            if(time_to_toggle) flash_count_next = 21'd0;
            else               flash_count_next = flash_count_reg + 1;
        end
    end
    
    // Top-level output
    assign light = light_out;
    
    // Registers
    always @(posedge clock) begin
        if(reset) begin
            state_reg       <= ST_OFF;
            flash_count_reg <= 21'd0; 
            blink_reg       <=  1'b0;
        end
        else begin
            state_reg       <= state_next;
            flash_count_reg <= flash_count_next;
            blink_reg       <= blink_next;
        end
    end
endmodule
