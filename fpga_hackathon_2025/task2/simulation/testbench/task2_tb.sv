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

// Testbench: Task 2 (Top-level design)

`timescale 1ns / 1ps

module task2_tb();
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
   logic [DATA_LEN-1:0] o_data;
   logic                o_valid;
   logic                o_last;   

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

   initial begin: stimuli
      int fd;
      logic [DATA_LEN-1:0] data_in;
      int num_cols; int num_rows;
      int i;

      data_in  = {DATA_LEN{1'b0}}; 
      num_cols = 0; num_rows = 0; i = 0;

      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      fd = $fopen("../scripts/matrix_inputs.txt", "r"); 
      if(fd == 0) $fatal(1, "Failed to open matrix_inputs.txt");

      while($fscanf(fd, "%d", data_in) > 0) begin
         i_valid <= 1'b1;
         i_first <= 1'b0;
         if(i == 0) begin
            num_cols = data_in;
            i_first <= 1'b1;
         end
         else if(i == 1) num_rows = data_in;
         else if(i == 2+num_cols*num_rows-1) i_last <= 1'b1;
         i_data <= data_in;
         i = i + 1;
         @(posedge i_clk);         
      end
      $fclose(fd);
      i_valid <= 1'b0;
      i_last  <= 1'b0;
   end

   task2 #(.DATA_LEN (DATA_LEN),
           .ADDR_LEN (ADDR_LEN)) uut 
          (.i_clk    (i_clk),
           .i_rst    (i_rst),
           .i_valid  (i_valid),
           .i_first  (i_first),
           .i_last   (i_last),
           .i_data   (i_data),
           .o_data   (o_data), 
           .o_valid  (o_valid),
           .o_last   (o_last));

   initial begin: monitor
      int fd_output; int fd_report;
      int passes; int fails;
      int return_code;
      logic [DATA_LEN-1:0] data_out;

      $timeformat(-9, 0, " ns");     
      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      passes = 0; fails = 0;

      fd_output = $fopen("../scripts/matrix_outputs.txt", "r");
      fd_report = $fopen("../scripts/task2_report.txt", "w"); 
      if(fd_output == 0) $fatal(1, "Failed to open matrix_outputs.txt");
      if(fd_report == 0) $fatal(1, "Failed to open task2_report.txt");

      forever begin
         @(negedge i_clk);
         if(o_valid) begin
            return_code = $fscanf(fd_output, "%d", data_out);
            if(o_data == data_out) passes = passes + 1;
            else fails = fails + 1;
            $display("TIME: %0t | EXPECTED: %2d | GOT: %2d", $time, data_out, o_data);
            $fdisplay(fd_report, "TIME: %0t | EXPECTED: %2d | GOT: %2d", $time, data_out, o_data);
            if(o_last) begin
               $display("TIME: %0t | PASSES: %4d | FAILS: %2d | TOTAL: %2d", 
                        $time, passes, fails, passes + fails);
               $fdisplay(fd_report, "TIME: %0t | PASSES: %4d | FAILS: %2d | TOTAL: %2d", 
                         $time, passes, fails, passes + fails);
               $fclose(fd_output); 
               $fclose(fd_report);
               $finish;
            end
         end
      end
   end
endmodule 
