//  Copyright (c) 2026 Olaoluwa Raji
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

// Testbench: Memory controller

`timescale 1ns / 1ps

module memory_controller_tb();
   // Constants
   localparam int CLK_PERIOD = 10;
   localparam int DATA_LEN   = 12;
   localparam int ADDR_LEN   = 12;

   // Signals: UUT
   logic                i_clk   =           1'b0;
   logic                i_rst   =           1'b0;
   logic                i_valid =           1'b0;
   logic                i_first =           1'b0;
   logic                i_last  =           1'b0;
   logic [DATA_LEN-1:0] i_data  = {DATA_LEN{1'b0}};
   logic                i_traverse_done  =  1'b0;
   logic [ADDR_LEN-1:0] o_row_max;
   logic [ADDR_LEN-1:0] o_col_max;   
   logic [DATA_LEN-1:0] o_data;
   logic [ADDR_LEN-1:0] o_write_addr;
   logic                o_write_en;
   logic                o_read_en;   

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

   // TO-DO: Generate stimuli from the data extracted from matrix_inputs.txt file.
   initial begin: stimuli
   end

   memory_controller #(.DATA_LEN        (DATA_LEN),
                       .ADDR_LEN        (ADDR_LEN)) uut 
                      (.i_clk           (i_clk),
                       .i_rst           (i_rst),
                       .i_valid         (i_valid),
                       .i_first         (i_first),
                       .i_last          (i_last),
                       .i_data          (i_data),
                       .i_traverse_done (i_traverse_done),
                       .o_row_max       (o_row_max),
                       .o_col_max       (o_col_max),   
                       .o_data          (o_data), 
                       .o_write_addr    (o_write_addr),
                       .o_write_en      (o_write_en),
                       .o_read_en       (o_read_en));

   initial begin: monitor
      $finish;
   end
endmodule 
