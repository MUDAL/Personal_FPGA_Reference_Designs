`timescale 1ns / 1ps
module display_interface_tb;
    
    function [3:0] get_value(input [6:0] seg);
	begin
	   case(seg)
	     7'b0000001:  get_value = 4'h0;
         7'b1001111:  get_value = 4'h1;
         7'b0010010:  get_value = 4'h2;
         7'b0000110:  get_value = 4'h3;
         7'b1001100:  get_value = 4'h4;
         7'b0100100:  get_value = 4'h5;
         7'b0100000:  get_value = 4'h6;
         7'b0001111:  get_value = 4'h7;
         7'b0000000:  get_value = 4'h8;
         7'b0000100:  get_value = 4'h9;
         7'b0001000:  get_value = 4'hA;
         7'b1100000:  get_value = 4'hB;
         7'b0110001:  get_value = 4'hC;
         7'b1000010:  get_value = 4'hD;
         7'b0110000:  get_value = 4'hE;
         7'b0111000:  get_value = 4'hF;
	   endcase
	end
    endfunction
    
    // Constants
    localparam integer CLK_PERIOD_NS        = 200;
    localparam integer CYCLES_BEFORE_SWITCH = 15;
    localparam integer NUMBER_OF_TESTS      =  7;
    
    // Array of test inputs to be injected into the design
    reg [19:0] test_values [0:NUMBER_OF_TESTS - 1];
    reg [4:0]  test_dots   [0:NUMBER_OF_TESTS - 1];
    
    // Signals
    reg           clock =  1'b0;
    reg           reset =  1'b1;
    reg   [19:0]  value = 20'b0;
    reg   [4:0]   dots  =  5'b11111;
    wire  [7:0]   digit;
    wire  [7:0]   segment;
    
    // UUT
    display_interface #(.CYCLES_BEFORE_SWITCH (CYCLES_BEFORE_SWITCH))
        uut(.clock   (clock),
            .reset   (reset),
            .value   (value),
            .dots    (dots),
            .digit   (digit),
            .segment (segment));
    
    initial begin: Reset_generator
        #(2 * CLK_PERIOD_NS);
        reset <= 1'b0;
        #(150 * CLK_PERIOD_NS);
        reset <= 1'b1;
        #(5 * CLK_PERIOD_NS);
        reset <= 1'b0;
    end
    
    initial begin: Clock_generator
        forever begin
            #(CLK_PERIOD_NS / 2);
            clock <= ~clock;
        end 
    end 
    
    initial begin: Prepare_tests
        test_values[0] = 20'h25697;
        test_values[1] = 20'h91503;
        test_values[2] = 20'h47128;
        test_values[3] = 20'h69351;
        test_values[4] = 20'h17395;
        test_values[5] = 20'h38645;
        test_values[6] = 20'h74906;
        
        ///////////////////////////
        test_dots[0] = 5'b11110;
        test_dots[1] = 5'b11101;
        test_dots[2] = 5'b11011;
        test_dots[3] = 5'b10111;
        test_dots[4] = 5'b01111;
        test_dots[5] = 5'b11111; 
        test_dots[6] = 5'b01111;
    end
    
    initial begin: Stimuli
        integer i;
        wait(reset == 0);
        for(i = 0; i < NUMBER_OF_TESTS; i = i + 1) begin
            value <= test_values[i];
            dots  <= test_dots[i];
            #(120 * CLK_PERIOD_NS); 
        end        
    end
    
    initial begin: Console_log
        wait(reset == 0);
        $timeformat(-9, 0, "ns");
        $monitor("%10d | rst: %b | value_in: %h | dots_in: %b | digit_out: %b | display_out: %h | dots_out: %b",
                 $time, 
                 reset, 
                 value, 
                 dots, 
                 digit, 
                 get_value(segment[7:1]),
                 segment[0]);
    end
endmodule
