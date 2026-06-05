`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Olaoluwa Raji
// 
// Create Date: 02.10.2025 11:09:28
// Design Name: 
// Module Name: display_interface
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

// Parameter:
// Number of cycles that must be counted before switching to next digit.
module display_interface #(parameter CYCLES_BEFORE_SWITCH = 1000)
                          (input           clock,
                           input           reset,
                           input    [19:0] value,
                           input    [4:0]  dots,
                           output   [7:0]  digit,
                           output   [7:0]  segment);
                           
    // Signals for counter that selects digits.
    reg  [2:0]  digit_select_reg;
    reg  [2:0]  digit_select_next;
    wire        time_to_switch;
    
    // Signals for counter that switches from one digit segment to another.
    // Refresh period (for 8 digits) = 1.6ms. Time per digit: 1.6ms/8 = 200us.
    // Since the time per digit = 200us, we'll need to count 1000 cycles.
    reg  [11:0] digit_switch_reg;
    reg  [11:0] digit_switch_next;
    
    // Hexadecimal value to be displayed on a segment.
    reg  [3:0]  hex_value;
    
    // Internal signals mapped to top-level outputs.
    reg  [7:0]  dig;
    wire [6:0]  seg;
    reg         dot;
    
    // Combinational logic for counter that switches from digit to digit.
    assign time_to_switch = (digit_switch_reg == CYCLES_BEFORE_SWITCH - 1);
    
    always @(digit_switch_reg, time_to_switch)
    begin
        if(time_to_switch) digit_switch_next = 12'b0;
        else               digit_switch_next = digit_switch_reg + 1;
    end   
    
    // Combinational logic for counter to select digits.
    always @(digit_select_reg, time_to_switch)
    begin
        if(time_to_switch) digit_select_next = digit_select_reg + 1;
        else               digit_select_next = digit_select_reg;
    end  
    
    // Digit selector - MUX.
    always @(digit_select_reg)
    begin
        case(digit_select_reg)
            3'b000:  dig = 8'b11111110;
            3'b001:  dig = 8'b11111101;
            3'b010:  dig = 8'b11111011;
            3'b011:  dig = 8'b11110111;
            3'b100:  dig = 8'b11101111;
            default: dig = 8'b11111111; // Don't activate unused digits.
        endcase
    end
    
    // Hexadecimal value selector - MUX.
    always @(digit_select_reg, value)
    begin
        case(digit_select_reg)
            3'b000:  hex_value = value[3:0];
            3'b001:  hex_value = value[7:4];
            3'b010:  hex_value = value[11:8];
            3'b011:  hex_value = value[15:12];
            3'b100:  hex_value = value[19:16];
            default: hex_value = 4'b0; // Don't care about unused digits.
        endcase
    end    
    
    // Dots selector - MUX.
    always @(digit_select_reg, dots)
    begin
        case(digit_select_reg)
            3'b000:  dot = dots[0];
            3'b001:  dot = dots[1];
            3'b010:  dot = dots[2];
            3'b011:  dot = dots[3];
            3'b100:  dot = dots[4];
            default: dot = 1'b1; // Don't care about unused digits. 
        endcase
    end 
    
    // Instantiate the "hex2seg" converter provided on Brightspace.
    hex2seg converter(.number  (hex_value),
                      .pattern (seg)
                      );
    
    // Outputs.
    assign digit   =  dig;
    assign segment = {seg, dot};
    
    // Registers.
    always @(posedge clock)
    begin
        if(reset) begin
            digit_select_reg <=  3'b0;
            digit_switch_reg <= 12'b0;
        end 
        else begin      
            digit_select_reg <= digit_select_next;
            digit_switch_reg <= digit_switch_next;
        end
    end  
    
endmodule
