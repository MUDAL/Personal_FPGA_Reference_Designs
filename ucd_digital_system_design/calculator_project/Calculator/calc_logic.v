`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2025 22:22:08
// Design Name: 
// Module Name: calc_logic
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

module calc_logic(input         reset,
                  input         clock,
                  input         newkey,
                  input  [4:0]  keycode,
                  output [19:0] result,
                  output        overflow);
    
    // Constants - Operator keycodes [4 LSBs].
    localparam MUL = 4'b1010; // Multiplication.
    localparam ADD = 4'b1011; // Addition.
    localparam EQ  = 4'b1100; // Equal.
    localparam SQ  = 4'b0011; // Square.
    localparam CLR = 4'b0100; // Clear.
    
    // Internal signals - Operator (Op) and operands (X and Y).
    reg [3:0]  op_reg;
    reg [3:0]  op_next;
    reg [19:0] x_reg;
    reg [19:0] x_next;
    reg [19:0] y_reg;
    reg [19:0] y_next;
    
    // Overflow register.
    reg overflow_reg;
    reg overflow_next;
    
    wire op_detected;  // Triggered when an operator is detected.
    wire num_detected; // Triggered when an operand (number) is detected.
    wire op_equal_new; // Triggered when the new (unregistered) operator is EQ.
    
    // Internal signals to indicate registered operators.
    wire op_clear;
    wire op_equal;
    wire op_add;
    wire op_mul;
    
    // Determine when to clear X and set Y = X.
    reg  xclr_yset_reg;
    wire xclr_yset_next;
    wire xclr_yset; // Rising edge detector.    
    
    // Select bits for operand X's wide multiplexer.
    wire sel_add;
    wire sel_mul;
    wire sel_square;
    wire sel_clear;
    wire [3:0] sel_result; // To select the result of the desired operation.
    
    // Results from user calculation.
    wire [39:0] x_square;
    wire [39:0] x_mul;
    wire [20:0] x_add;
    
    // Overflow detection signals.
    wire overflow_square;
    wire overflow_mul;
    wire overflow_add;
    
    assign op_detected    = (newkey & ~keycode[4]);
    assign num_detected   = (newkey &  keycode[4]);
    assign op_equal_new   = (op_next ==  EQ);
    assign op_clear       = (op_reg  ==  CLR);
    assign op_equal       = (op_reg  ==  EQ);
    assign op_add         = (op_reg  ==  ADD);
    assign op_mul         = (op_reg  ==  MUL);
    
    assign xclr_yset_next =  op_add | op_mul;
    assign xclr_yset      =  xclr_yset_next & ~xclr_yset_reg;
    
    assign sel_add        =  op_equal_new & op_add;
    assign sel_mul        =  op_equal_new & op_mul;
    assign sel_square     =  op_detected  & (keycode[3:0] == SQ);
    assign sel_clear      =  op_clear | xclr_yset;
    assign sel_result     = {sel_add, sel_mul, sel_square, sel_clear};
    
    // Combinational logic for "operator"
    always @(op_detected, keycode, op_clear, op_reg) 
    begin
        if(op_detected)  op_next = keycode[3:0];
        else begin
            if(op_clear) op_next = 4'b0;
            else         op_next = op_reg;
        end
    end
    
    // Combinational logic for "operand Y"
    always @(op_equal, op_clear, xclr_yset, x_reg, y_reg) 
    begin
        if(xclr_yset) y_next = x_reg;
        else begin
            if(op_equal || op_clear) y_next = 20'b0;
            else                     y_next = y_reg;
        end
    end
    
    // Combinational logic for "operand X"
    // If number is detected:
    // Shift registered value to be left by 4 bits and accept new keycode.
    always @(num_detected,
             x_square,
             x_mul,
             x_add,
             sel_result, 
             x_reg, 
             keycode) 
    begin
        if(num_detected) x_next = {x_reg[15:0], keycode[3:0]};
        else begin
            case(sel_result)
                4'b0001: x_next = 20'b0;
                4'b0010: x_next = x_square[19:0];
                4'b0100: x_next = x_mul[19:0];
                4'b1000: x_next = x_add[19:0];
                default: x_next = x_reg;
            endcase
        end
    end
    
    // Calculator's operations.
    assign x_square = x_reg * x_reg; 
    assign x_mul    = x_reg * y_reg;
    assign x_add    = x_reg + y_reg;
    
    // Overflow logic.
    assign overflow_square = (x_square[39:20] != 0);
    assign overflow_mul    = (x_mul[39:20] != 0);
    assign overflow_add    =  x_add[20]; 
    
    always @(sel_result, 
             overflow_square,
             overflow_mul,
             overflow_add,
             overflow_reg) 
    begin
        case(sel_result)
            4'b0001: overflow_next = 1'b0;
            4'b0010: overflow_next = overflow_square;
            4'b0100: overflow_next = overflow_mul;
            4'b1000: overflow_next = overflow_add;
            default: overflow_next = overflow_reg;
        endcase      
    end
    
    // Top-level outputs.
    assign result   = x_reg; 
    assign overflow = overflow_reg;
    
    // Registers.
    always @(posedge reset or posedge clock) 
    begin
        if(reset) begin
            op_reg        <=   4'b0;
            x_reg         <=  20'b0;
            y_reg         <=  20'b0;
            xclr_yset_reg <=   1'b0;
            overflow_reg  <=   1'b0;
        end
        else begin
            op_reg        <=  op_next;
            x_reg         <=  x_next;
            y_reg         <=  y_next;
            xclr_yset_reg <=  xclr_yset_next;
            overflow_reg  <=  overflow_next;
        end
    end
endmodule
