`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University College Dublin (UCD)
// Engineer: Olaoluwa Raji
// 
// Create Date: 23.11.2025 12:53:53
// Design Name: 
// Module Name: calc_logic_tb
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

module calc_logic_tb();
    
    localparam CLK_PERIOD = 200; // In nanoseconds.
    localparam OPERAND    = 1'b1;
    localparam OPERATOR   = 1'b0;
    localparam NUM_DIGITS = 5;
    localparam NUM_TESTS  = 100;
    
    // Operators [4 LSBs].
    localparam MUL = 4'b1010; // Multiplication.
    localparam ADD = 4'b1011; // Addition.
    localparam EQ  = 4'b1100; // Equal.
    localparam SQ  = 4'b0011; // Square.
    localparam CLR = 4'b0100; // Clear.
    
    // Identifiers for testcases.
    localparam TEST_1 = 0; // Addition and multiplication.
    localparam TEST_2 = 1; // Squaring.
    localparam TEST_3 = 2; // Chaining and clearing.
    localparam TEST_4 = 3; // Corner cases.
    
    // Test value for chaining using "SQ".
    localparam TEST_SQ = 20'h3;    
    
    // UUT signals.
    reg         clock;
    reg         reset;
    reg         newkey;
    reg  [4:0]  keycode;
    wire [19:0] result;
    wire        overflow;   
    
    // Test vectors.
    reg [19:0] x_test  [0:NUM_TESTS-1];
    reg [19:0] y_test  [0:NUM_TESTS-1];
    reg [19:0] op_test [0:NUM_TESTS-1];
    
    // Testbench monitoring signals.
    reg  [2:0]  test_tracker = TEST_1;    
    reg  [39:0] expected;
    wire [19:0] exp_result;
    wire        exp_overflow;
    reg         done_injecting = 1'b0;
    
    assign exp_result   =  expected[19:0];
    assign exp_overflow = (expected[39:20] > 0); 
    
    // Brief: Simulates a press of the keypad's key by generating:
    // 1. A "newkey" pulse
    // 2. Preparing a keycode using the "input_type" and "input_code."
    // Parameters:
    // input_type: Represents an operand (1'b1) or operator (1'b0).
    // input_code: The 4 LSBs of a keycode.  
    task press_key(input input_type, input [3:0] input_code);
        begin
            @(posedge clock); 
            keycode <= {input_type, input_code};
            newkey  <= 1'b1;
            @(posedge clock);
            newkey  <= 1'b0;
            repeat(5) @(posedge clock); 
        end
    endtask                 
    
    // Brief: Tests operations requiring two operands (e.g. Add & Multiply).
    // Takes two test values, performs the specified operation.
    // Parameters:
    // 1. x:  Test value for x_reg.
    // 2. op: Test value for op_reg.    
    // 3. y:  Test value for y_reg.
    task test_two_operand_calc(input [4*NUM_DIGITS-1:0] x, 
                               input [3:0] op, 
                               input [4*NUM_DIGITS-1:0] y);    
        integer i;  
        begin
            // Inject all digits of operand x 
            for(i = 0; i < NUM_DIGITS; i = i + 1) begin
                press_key(OPERAND, x[19 - i*4 -: 4]);
            end         
            // Inject operator (add or multiply).  
            press_key(OPERATOR, op);       
            // Inject all digits of operand y    
            for(i = 0; i < NUM_DIGITS; i = i + 1) begin
                press_key(OPERAND, y[19 - i*4 -: 4]);
            end         
            // Inject "=" so that we can monitor the output.   
            press_key(OPERATOR, EQ);                                        
        end
    endtask
    
    // Brief: Tests operations requiring one operand (e.g Square).
    // Takes one test value and performs the specified operation.
    // Parameters:
    // 1. x:  Test value for x_reg.
    // 2. op: Test value for op_reg. 
    task test_one_operand_calc(input [4*NUM_DIGITS-1:0] x, 
                               input [3:0] op);
        integer i;
        begin
            // Inject all digits of operand x 
            for(i = 0; i < NUM_DIGITS; i = i + 1) begin
                press_key(OPERAND, x[19 - i*4 -: 4]);
            end         
            // Inject operator (e.g. square).  
            press_key(OPERATOR, op);  
            // Inject "=" so that we can monitor the output.   
            press_key(OPERATOR, EQ);                      
        end
    endtask 
    
    // Reset the UUT.
    initial begin: reset_generator
        reset <= 1'b1;
        repeat(4) @(posedge clock);
        reset <= 1'b0;
    end
    
    // Clock
    initial begin: clock_generator
        clock <= 1'b0;
        forever begin
            #(CLK_PERIOD / 2);
            clock <= ~clock;
        end
    end
    
    // Instantiate the design for testing.
    calc_logic uut(.reset    (reset),
                   .clock    (clock),
                   .newkey   (newkey),
                   .keycode  (keycode),
                   .result   (result),
                   .overflow (overflow));
    
    // Populate arrays with Python-generated test vectors.
    initial begin: read_test_vectors_from_file 
        $readmemh("x_test.txt",  x_test);
        $readmemh("y_test.txt",  y_test);
        $readmemh("op_test.txt", op_test);    
    end
    
    // Stimuli for test 1 - Testing addition & multiplication.
    integer j; // Loop counter (reused for stimuli generators).
                   
    initial begin: stimuli_addition_multiplication
        @(negedge reset);        
        
        $display("Testing addition and multiplication:");
        for(j = 0; j < NUM_TESTS; j = j + 1) begin            
            done_injecting <= 1'b0;
            test_two_operand_calc(x_test[j], op_test[j],  y_test[j]);
            done_injecting <= 1'b1;
            @(posedge clock);
        end
        
        test_tracker <= TEST_2;
        @(posedge clock);            
    end            
    
    // Stimuli for test 2 - Testing squaring.
    initial begin: stimuli_squaring
        @(negedge reset);
        wait(test_tracker == TEST_2);
        
        $display("Testing squaring:");
        for(j = 0; j < NUM_TESTS; j = j + 1) begin
            done_injecting <= 1'b0;
            test_one_operand_calc(x_test[j], SQ);
            done_injecting <= 1'b1;
            @(posedge clock);
        end
        
        test_tracker <= TEST_3;
        @(posedge clock);
    end
    
    // Stimuli for test 3 - Testing chaining & clearing.
    // Chaining test: Using addition, multiplication, and squaring.
    // Clearing test: Inject "clear" and ensure result is 0.
    initial begin: stimuli_chaining_clearing
        @(negedge reset);
        wait(test_tracker == TEST_3);
        
        $display("Testing clearing:");
        done_injecting <= 1'b0;
        press_key(OPERATOR, CLR);
        done_injecting <= 1'b1;
        @(posedge clock);
        
        $display("Testing chaining by adding 1st 3 testvectors in X array:");        
        done_injecting <= 1'b0;
        test_two_operand_calc(x_test[0], ADD, x_test[1]);
        test_two_operand_calc(result,    ADD, x_test[2]);
        done_injecting <= 1'b1;
        @(posedge clock);
        
        $display("Testing chaining by multiplying with 3 constants (2,3, and 4):");
        done_injecting <= 1'b0;
        test_two_operand_calc(result, MUL, 2);
        test_two_operand_calc(result, MUL, 3);
        test_two_operand_calc(result, MUL, 4);
        done_injecting <= 1'b1;
        @(posedge clock); 
        
        $display("Testing chaining by squaring using ((%0x^2)^2)^2): ", TEST_SQ);
        done_injecting <= 1'b0;
        test_one_operand_calc(TEST_SQ, SQ);
        test_one_operand_calc(result,  SQ);
        test_one_operand_calc(result,  SQ);
        done_injecting <= 1'b1;
        @(posedge clock);
          
        test_tracker <= TEST_4;
        @(posedge clock);            
    end
    
    // Stimuli for test 4 - Corner cases.
    // Testing cases such as:
    // 1. Deactivation of overflow signal when addition or multiplication key is pressed.
    // 2. Random combination of keys.
    initial begin: stimuli_corner_cases
        @(negedge reset);
        wait(test_tracker == TEST_4);
        
        $display("Test 4 - Testing corner cases: ");
        $display("Let's clear the calculator's result first");
        press_key(OPERATOR, CLR);
        
        $display("Test 4.1 - Trigger overflow by adding 1 to 0xFFFFF");
        done_injecting <= 1'b0;
        test_two_operand_calc(20'hFFFFF, ADD, 1);
        done_injecting <= 1'b1;
        @(posedge clock);
        
        $display("Test 4.1 - Addition key is about to be pressed");
        done_injecting <= 1'b0;        
        press_key(OPERATOR, ADD);
        $display("Test 4.1 - Addition key has been pressed");
        done_injecting <= 1'b1;
        @(posedge clock);
        
        $display("Test 4.2 - Now, we'll test random user inputs.");
        done_injecting <= 1'b0;
        // Corner case: changing an arithmetic operator before pressing EQ.
        press_key(OPERAND,   7);  $display("User just pressed 7");
        press_key(OPERAND,   1);  $display("User just pressed 1");
        press_key(OPERATOR, MUL); $display("User just pressed the MUL key");
        press_key(OPERATOR, ADD); $display("User just pressed the ADD key");
        press_key(OPERAND,   2);  $display("User just pressed 2");
        press_key(OPERATOR, EQ);  $display("User just pressed the EQ key");
        // End of injection.
        done_injecting <= 1'b1;
        @(posedge clock);
        
        $display("Test 4.3 - Another set of random user inputs.");
        done_injecting <= 1'b0;
        press_key(OPERAND,   4);  $display("User just pressed 4");
        press_key(OPERATOR, MUL); $display("User just pressed the MUL key");
        press_key(OPERATOR, EQ);  $display("User just pressed the EQ key"); 
        press_key(OPERAND,   3);  $display("User just pressed 3");    
        press_key(OPERATOR, ADD); $display("User just pressed the ADD key"); 
        press_key(OPERATOR, MUL); $display("User just pressed the MUL key");  
        press_key(OPERATOR, EQ);  $display("User just pressed the EQ key");
        done_injecting <= 1'b1;
        @(posedge clock);
    end
    
    // Output verification of test 1 - Testing addition & multiplication.
    // Counters (reused for verification purposes).
    integer k;
    reg [31:0] pass = 0;
    reg [31:0] fail = 0;
    
    initial begin: verify_addition_multiplication
        if(test_tracker == TEST_1) begin
            for(k = 0; k < NUM_TESTS; k = k + 1) begin
                if(op_test[k] == ADD) begin
                    expected <= x_test[k] + y_test[k];
                end
                else begin 
                    expected <= x_test[k] * y_test[k];
                end
                
                @(posedge done_injecting);
                if(result == exp_result && overflow == exp_overflow) begin
                    pass = pass + 1;
                end
                else begin                  
                    fail = fail + 1;
                end  
                $display("Test 1 - X = %x, Y = %x, Result: %x, Expected: %x, Overflow: %b, Expected: %b",  
                         x_test[k], y_test[k], result, exp_result, overflow, exp_overflow);     
            end
            $display("Test 1 - PASS: %2d, FAIL: %2d\n", pass, fail);
        end
    end
    
    // Output verification of test 2 - Testing squaring.
    initial begin: verify_squaring
        wait(test_tracker == TEST_2);
        pass = 0;
        fail = 0;
        
        for(k = 0; k < NUM_TESTS; k = k + 1) begin
            expected <= x_test[k] * x_test[k];
            @(posedge done_injecting);
            if(result == exp_result && overflow == exp_overflow) begin
                pass = pass + 1;
            end
            else begin
                fail = fail + 1;
            end
            
            $display("Test 2 - X = %x, Result: %x, Expected: %x, Overflow: %b, Expected: %b", 
                     x_test[k], result, exp_result, overflow, exp_overflow);                  
        end
        $display("Test 2 - PASS: %2d, FAIL: %2d\n", pass, fail);
    end
    
    // Output verification of test 3 - Testing chaining & clearing.
    initial begin: verify_chaining_clearing
        wait(test_tracker == TEST_3);
        
        @(negedge done_injecting);
        $display("Result before clearing = %x, Overflow: %b", 
                 result, overflow);
        @(posedge done_injecting);
        $display("Result after clearing = %x, Overflow: %b\n", 
                 result, overflow);
        
        // Monitoring chaining by addition.
        @(negedge done_injecting);
        expected <= x_test[0] + x_test[1] + x_test[2];
        @(posedge done_injecting);
        
        if(result == exp_result && overflow == exp_overflow) begin
            $display("Test 3.1 - Op: (%x + %x + %x), Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: PASS\n", 
                     x_test[0], x_test[1], x_test[2], result, exp_result, overflow, exp_overflow);
        end
        else begin
             $display("Test 3.1 - Op: (%x + %x + %x), Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: FAIL\n", 
                      x_test[0], x_test[1], x_test[2], result, exp_result, overflow, exp_overflow);           
        end
        
        // Monitoring chaining by multiplication.
        @(negedge done_injecting);
        expected <= 2 * exp_result; @(posedge clock);
        expected <= 3 * exp_result; @(posedge clock);
        expected <= 4 * exp_result; @(posedge clock);
        @(posedge done_injecting);
        
        if(result == exp_result && overflow == exp_overflow) begin
            $display("Test 3.2 - Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: PASS\n", 
                     result, exp_result, overflow, exp_overflow);        
        end
        else begin
            $display("Test 3.2 - Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: FAIL\n", 
                     result, exp_result, overflow, exp_overflow);         
        end
        
        // Monitoring chaining by squaring.
        @(negedge done_injecting);
        expected <= TEST_SQ    * TEST_SQ;    @(posedge clock);
        expected <= exp_result * exp_result; @(posedge clock);
        expected <= exp_result * exp_result; @(posedge clock);
        @(posedge done_injecting);
        
        if(result == exp_result && overflow == exp_overflow) begin
            $display("Test 3.3 - Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: PASS\n", 
                     result, exp_result, overflow, exp_overflow);        
        end
        else begin
            $display("Test 3.3 - Result: %x, Expected: %x, Overflow: %b, Expected: %b, Status: FAIL\n", 
                     result, exp_result, overflow, exp_overflow);         
        end                      
    end
    
    // Output verification of test 4 - Testing corner cases.
    initial begin: verify_corner_cases
        wait(test_tracker == TEST_4);
        
        @(posedge done_injecting);
        $display("Test 4.1 - 0xFFFFF + 1 = %x, Overflow: %b", result, overflow);
        @(posedge done_injecting);
        $display("Test 4.1 - Result after pressing ADD key following an overflow: %x, Overflow: %b\n", 
                 result, overflow); 
        @(posedge done_injecting);
        $display("Test 4.2 - Result: %x, Overflow: %b\n", result, overflow);                   
        @(posedge done_injecting);
        $display("Test 4.3 - Result: %x, Overflow: %b\n", result, overflow);          
        $finish;  
    end
endmodule
