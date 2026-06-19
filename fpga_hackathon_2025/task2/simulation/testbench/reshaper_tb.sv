//  Copyright (c) 2026 Olaoluwa Raji
//  
//  Permission is hereby granted; free of charge; to any person obtaining a copy
//  of this software and associated documentation files (the "Software"); to deal
//  in the Software without restriction; including without limitation the rights
//  to use; copy; modify; merge; publish; distribute; sublicense; and/or sell
//  copies of the Software; and to permit persons to whom the Software is
//  furnished to do so; subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS"; WITHOUT WARRANTY OF ANY KIND; EXPRESS OR
//  IMPLIED; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY;
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM; DAMAGES OR OTHER
//  LIABILITY; WHETHER IN AN ACTION OF CONTRACT; TORT OR OTHERWISE; ARISING FROM;
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

// Testbench: Reshaper

`timescale 1ns / 1ps

module reshaper_tb(); 
   // Constants
   localparam int CLK_PERIOD = 10;  
   localparam int ADDR_LEN   = 12;
   localparam int NUM_ROWS   =  8;
   localparam int NUM_COLS   =  8;
   // Signals: UUT
   logic                i_clk      =           1'b0;
   logic                i_rst      =           1'b0;
   logic                i_valid    =           1'b0;
   logic [ADDR_LEN-1:0] i_row_max  = {ADDR_LEN{1'b0}};  
   logic [ADDR_LEN-1:0] i_row      = {ADDR_LEN{1'b0}};
   logic [ADDR_LEN-1:0] i_col      = {ADDR_LEN{1'b0}};
   logic [ADDR_LEN-1:0] o_mem_addr;
   logic                o_valid; 
   // Signals: Simulation
   logic [ADDR_LEN-1:0] expected [NUM_ROWS*NUM_COLS-1:0];
   
   initial begin: clock_gen
      forever begin
         #(CLK_PERIOD / 2);
         i_clk <= ~i_clk;
      end
   end
   
   initial begin: reset_gen
      repeat(5) @(posedge i_clk);
      i_rst <= 1'b1;
      repeat(5) @(posedge i_clk);
      i_rst <= 1'b0;
   end
   
   // UUT instantiation
   reshaper #(.ADDR_LEN   (ADDR_LEN)) uut
             (.i_clk      (i_clk),
              .i_rst      (i_rst),
              .i_valid    (i_valid),
              .i_row_max  (i_row_max),
              .i_row      (i_row),
              .i_col      (i_col),
              .o_mem_addr (o_mem_addr),
              .o_valid    (o_valid));  
   
   initial begin: stimuli
      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      $display("%0t | Driving UUT input signals",$time);
      i_valid    <= 1'b1;
      i_row_max  <= NUM_ROWS;
      for(int row = 0; row < NUM_ROWS; row++) begin
         for(int col = 0; col < NUM_COLS; col++) begin
            i_row <= row;
            i_col <= col;
            expected[NUM_ROWS*row+col] = NUM_ROWS*row+col;
            @(posedge i_clk);
         end
      end
      i_valid <= 1'b0;
      $display("%0t | Stimuli injection completed",$time);
   end
              
   initial begin: monitor
      ///////////////////////////////////////////////////////////////
      int addr;
      int passed;
      int failed;
      addr   = 0;
      passed = 0;
      failed = 0;
      ///////////////////////////////////////////////////////////////
      $timeformat(-9, 0, " ns");
      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      forever begin
         @(negedge i_clk);
         if(addr == NUM_ROWS*NUM_COLS) begin
            $display("%0t | PASSED: %0d, FAILED: %0d",$time,passed,failed);
            $finish;
         end
         if(o_valid) begin
            if(o_mem_addr == expected[addr]) begin
               $display("%0t | [PASS] -> Expected: %0d, Got: %0d",
                        $time, expected[addr], o_mem_addr);
               passed = passed + 1;
            end
            else begin
               $display("%0t | [FAIL] -> Expected: %0d, Got: %0d",
                        $time, expected[addr], o_mem_addr);
               failed = failed + 1;
            end
            addr = addr + 1;
         end
      end
   end
endmodule 
