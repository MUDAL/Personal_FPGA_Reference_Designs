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

// Testbench: Matrix traverse

`timescale 1ns / 1ps

module matrix_traverse_tb();
   // Constants
   localparam  int  CLK_PERIOD     =  10;
   localparam  int  DATA_LEN       =   8;
   localparam  int  ADDR_LEN       =  12;
   localparam  int  LATENCY        =   3;
   // Signals: UUT
   logic                i_clk      =           1'b0;
   logic                i_rst      =           1'b0;
   logic [ADDR_LEN-1:0] i_row_max  = {ADDR_LEN{1'b0}};
   logic [ADDR_LEN-1:0] i_col_max  = {ADDR_LEN{1'b0}};
   logic                i_enable   =           1'b0;
   logic [DATA_LEN-1:0] i_data_uut;
   logic [ADDR_LEN-1:0] o_read_addr;
   logic [DATA_LEN-1:0] o_data_uut;   
   logic                o_valid;
   logic                o_last;
   // Signals: Block RAM
   logic                i_we        =           1'b0;
   logic [ADDR_LEN-1:0] w_addr      = {ADDR_LEN{1'b0}};
   logic [ADDR_LEN-1:0] r_addr;
   logic [DATA_LEN-1:0] i_data_bram = {DATA_LEN{1'b0}};
   logic [DATA_LEN-1:0] o_data_bram;   
   // Signals: File I/O
   logic [DATA_LEN-1:0] data_in;
   logic [DATA_LEN-1:0] data_out;
   
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

   initial begin: fill_block_ram
      int fd;
      int i; i = 0;
      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      fd = $fopen("../scripts/matrix_traverse_inputs.txt", "r"); 
      
      if(fd == 0) $fatal(1, "Failed to open matrix_traverse_inputs.txt");
      
      // Reference: https://chipverify.com/systemverilog/systemverilog-file-io
      // Detecting EOF with $fscanf() instead of $feof()
      while($fscanf(fd, "%d", data_in) > 0) begin
         if(i == 0)      i_col_max <= data_in;
         else if(i == 1) i_row_max <= data_in;
         else begin
            i_we        <= 1'b1;           
            i_data_bram <= data_in;
            w_addr      <= i - 2;         
         end
         i = i + 1;
         @(posedge i_clk);
      end
      i_we <= 1'b0;
      $fclose(fd);
   end   
   
   initial begin: activate_matrix_traverse
      wait(i_we == 1'b1);
      wait(i_we == 1'b0);
      i_enable <= 1'b1;
      @(posedge i_clk);
      i_enable <= 1'b0;
   end

   // Instantiate Block RAM
   memory #(.DATA_LEN (DATA_LEN),
            .ADDR_LEN (ADDR_LEN)) block_ram 
           (.i_clk    (i_clk),
            .i_we     (i_we),
            .w_addr   (w_addr),
            .r_addr   (r_addr),
            .i_data   (i_data_bram),
            .o_data   (o_data_bram));

   assign i_data_uut = o_data_bram;
   assign r_addr     = o_read_addr;

   matrix_traverse #(.DATA_LEN     (DATA_LEN),
                     .ADDR_LEN     (ADDR_LEN),
                     .LATENCY      (LATENCY)) uut
                    (.i_clk        (i_clk),
                     .i_rst        (i_rst),
                     .i_row_max    (i_row_max),
                     .i_col_max    (i_col_max),
                     .i_enable     (i_enable),
                     .i_data       (i_data_uut),
                     .o_read_addr  (o_read_addr),
                     .o_data       (o_data_uut),
                     .o_valid      (o_valid),
                     .o_last       (o_last));

   initial begin: monitor
      int return_code;
      int fd_output; int fd_report;
      int pass; int fail;
      pass = 0; 
      fail = 0;

      wait(i_enable == 1'b1);
      wait(i_enable == 1'b0);
      fd_output = $fopen("../scripts/matrix_traverse_outputs.txt", "r");
      fd_report = $fopen("../scripts/matrix_traverse_report.txt",  "w");

      if(fd_output == 0) $fatal(1, "Failed to open matrix_traverse_outputs.txt");
      if(fd_report == 0) $fatal(1, "Failed to open matrix_traverse_report.txt");

      forever begin
         @(negedge i_clk);
         if(o_valid) begin
            return_code = $fscanf(fd_output, "%d", data_out);
            if(o_data_uut == data_out) pass = pass + 1;
            else fail = fail + 1;
            $display("EXPECTED: %2d | GOT: %2d", data_out, o_data_uut);
            $fdisplay(fd_report, "EXPECTED: %2d | GOT: %2d", data_out, o_data_uut);

            if(o_last) begin
               $display("\n-----------------------------------------");
               $display("TESTCASES: %0d | PASSED: %0d | FAILED: %0d", pass + fail, pass, fail);
               $display("-----------------------------------------\n");

               $fdisplay(fd_report, "\n-----------------------------------------");
               $fdisplay(fd_report, "TESTCASES: %0d | PASSED: %0d | FAILED: %0d", pass + fail, pass, fail);
               $fdisplay(fd_report, "-----------------------------------------\n");  
                            
               $fclose(fd_output);
               $fclose(fd_report);
               $finish;
            end
         end
      end    
   end
endmodule 
