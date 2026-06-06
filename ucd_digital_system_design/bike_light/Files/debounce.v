`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University College Dublin (UCD)
// Engineer: Olaoluwa Raji
// 
// Create Date: 29.10.2025 21:36:19
// Design Name: 
// Module Name: debounce
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

// Number of cycles to be counted for debouncing.
// Default debounce delay = 10 ms.
module debounce #(parameter NUM_CYCLES = 50_000)
                 (input  reset,
                  input  clock,
                  input  button,
                  output press);
                  
    localparam MAX_CYCLE = NUM_CYCLES - 1;
                  
    // States
    localparam ST_IDLE      =  2'b00;
    localparam ST_DELAYING  =  2'b01;
    localparam ST_DEBOUNCED =  2'b10;
    
    // "Debounce delay (10 ms)" counter.
    // With a 5 MHz clock, a counter with a minimum of 16 bits is required.
    reg [15:0] count_reg;
    reg [15:0] count_next;
    wire max_count; 
    
    // Internal signals for FSM
    reg [1:0] state_reg;
    reg [1:0] state_next;
    
    reg  press_reg;
    reg  press_next;
    
    assign max_count = (count_reg == MAX_CYCLE);
    
    // Next-state logic
    always @(state_reg, button, max_count) begin
        state_next = state_reg;
        case(state_reg)
            ST_IDLE: begin
                if(button) state_next = ST_DELAYING;
            end
            ST_DELAYING: begin
                if(max_count) begin
                    if(button) state_next = ST_DEBOUNCED;
                    else       state_next = ST_IDLE;
                end
            end
            ST_DEBOUNCED: begin
                if(!button) state_next = ST_IDLE;
            end
            default: state_next = ST_IDLE;
        endcase
    end
    
    // FSM outputs
    always @(state_reg, count_reg) begin        
        case(state_reg)
            ST_IDLE: begin
                press_next =  1'b0;
                count_next = 16'd0;
            end
            ST_DELAYING: begin
                press_next = 1'b0;
                count_next = count_reg + 1;
            end
            ST_DEBOUNCED: begin
                press_next =  1'b1;
                count_next = 16'd0;
            end
            default: begin
                press_next = 1'b0;
                count_next = 16'd0;
            end     
        endcase
    end
    
    // Top-level output: Rising edge detector to get "single press."
    assign press = press_next & ~(press_reg);
    
    // Registers
    always @(posedge clock) begin
        if(reset) begin
            state_reg <= ST_IDLE;
            press_reg <=  1'b0;
            count_reg <= 16'd0;
        end
        else begin
            state_reg <= state_next;
            press_reg <= press_next;
            count_reg <= count_next;
        end
    end
endmodule
