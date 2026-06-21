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

// Task 2: Top-level design

module task2 
#( parameter int DATA_LEN = 8,
   parameter int ADDR_LEN = 12)
 ( input    logic                i_clk,
   input    logic                i_rst,
   input    logic                i_valid,
   input    logic                i_first,
   input    logic                i_last,
   input    logic [DATA_LEN-1:0] i_data,
   output   logic [DATA_LEN-1:0] o_data,
   output   logic                o_valid,
   output   logic                o_last);
   
   // Internal signals
   //////////////////////////////////////////////////////////////////
   logic                traverse_done;
   logic [ADDR_LEN-1:0] row_max;
   logic [ADDR_LEN-1:0] col_max;
   logic [DATA_LEN-1:0] i_mem_data;
   logic [DATA_LEN-1:0] o_mem_data;
   logic [ADDR_LEN-1:0] write_addr;
   logic                write_en;
   logic                read_en;
   logic [ADDR_LEN-1:0] read_addr;
   //////////////////////////////////////////////////////////////////
   
   // Instantiations
   //////////////////////////////////////////////////////////////////
   memory_controller memory_control_ip
   (.i_clk           (i_clk),
    .i_rst           (i_rst),
    .i_valid         (i_valid),
    .i_first         (i_first),
    .i_last          (i_last),
    .i_data          (i_data),
    .i_traverse_done (traverse_done),
    .o_row_max       (row_max),
    .o_col_max       (col_max),   
    .o_data          (i_mem_data), 
    .o_write_addr    (write_addr),
    .o_write_en      (write_en),
    .o_read_en       (read_en));
   
   memory memory_ip
   (.i_clk  (i_clk),
    .i_we   (write_en),
    .w_addr (write_addr),
    .r_addr (read_addr),
    .i_data (i_mem_data),
    .o_data (o_mem_data));
   
   matrix_traverse marix_traverse_ip
   (.i_clk       (i_clk),
    .i_rst       (i_rst),
    .i_row_max   (row_max),
    .i_col_max   (col_max),
    .i_enable    (read_en),
    .i_data      (o_mem_data),
    .o_read_addr (read_addr),
    .o_done      (traverse_done),  
    .o_data      (o_data),   
    .o_valid     (o_valid),
    .o_last      (o_last));
   //////////////////////////////////////////////////////////////////
endmodule 
