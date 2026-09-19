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
   localparam  int  MEM_WR_LATENCY =   1;
   localparam  int  MEM_RD_LATENCY =   1; 
   // Signals: UUT
   logic                i_clk      =           1'b0;
   logic                i_rst      =           1'b0;
   logic [ADDR_LEN-1:0] i_row_max  = {ADDR_LEN{1'b0}};
   logic [ADDR_LEN-1:0] i_col_max  = {ADDR_LEN{1'b0}};
   logic                i_enable   =           1'b0;
   logic [DATA_LEN-1:0] i_data     = {DATA_LEN{1'b0}};
   logic [ADDR_LEN-1:0] o_read_addr;
   logic                o_done;
   logic [DATA_LEN-1:0] o_data;   
   logic                o_valid;
   logic                o_last;
   // Signals: Simulation
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

   initial begin: stimuli
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
            i_enable <= 1'b1;           
            i_data   <= data_in;
         end
         i = i + 1;         
         @(posedge i_clk);
      end
      i_enable <= 1'b0;
      $fclose(fd);
   end   
   
   matrix_traverse uut(.i_clk       (i_clk),
                       .i_rst       (i_rst),
                       .i_row_max   (i_row_max),
                       .i_col_max   (i_col_max),
                       .i_enable    (i_enable),
                       .i_data      (i_data),
                       .o_read_addr (o_read_addr),
                       .o_done      (o_done),
                       .o_data      (o_data),
                       .o_valid     (o_valid),
                       .o_last      (o_last));

   initial begin: monitor
      int fd;
      wait(i_rst == 1'b1);
      wait(i_rst == 1'b0);
      // fd = $fopen("../scripts/matrix_traverse_outputs.txt", "r");

      // if(fd == 0) $fatal(1, "Failed to open matrix_traverse_outputs.txt");

      // while($fscanf(fd, "%d", data_out) > 0) begin
      //    $display("Data out: %d", data_out);          
      //    @(posedge i_clk);
      // end
      // $fclose(fd);

      forever begin
         @(negedge i_clk);
         $display("o_read_addr: %d | o_done: %d | o_data: %d | o_valid: %d | o_last: %d",
                   o_read_addr, o_done, o_data, o_valid, o_last);
         if(o_done) $finish;
      end    
   end
  
endmodule 
