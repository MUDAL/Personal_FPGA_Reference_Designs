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

// Reshaper: Converts 2D memory addresses into 1D memory addresses.
// Equation: 1D address = Number of rows * row index + column index.
// LATENCY: 3 clock cycles.

module reshaper 
#( parameter  int   ADDR_LEN = 12 )
 ( input     logic                i_clk,
   input     logic                i_rst,
   input     logic                i_valid,
   input     logic [ADDR_LEN-1:0] i_row_max,   
   input     logic [ADDR_LEN-1:0] i_row,
   input     logic [ADDR_LEN-1:0] i_col,
   output    logic [ADDR_LEN-1:0] o_mem_addr,
   output    logic                o_valid);
   
   typedef struct
   {
      logic   [ADDR_LEN-1:0] max;
      logic   [ADDR_LEN-1:0] row;
      logic   [ADDR_LEN-1:0] col1;
      logic   [ADDR_LEN-1:0] col2;
      logic [2*ADDR_LEN-1:0] prod;
      logic [2*ADDR_LEN:0  ] sum;
   }data_t; // Datapath registers
   data_t data_reg;
   data_t data_next;
   
   logic [1:0] i_vreg;   
   logic       o_vreg;   
   
   // Loading input registers
   assign data_next.max   = (i_valid)   ?  i_row_max : data_reg.max;
   assign data_next.row   = (i_valid)   ?  i_row     : data_reg.row;
   assign data_next.col1  = (i_valid)   ?  i_col     : data_reg.col1;
   // Pipeline - 1st stage 
   assign data_next.col2  =  data_reg.col1;
   assign data_next.prod  = (i_vreg[0]) ?  data_reg.max * data_reg.row  : data_reg.prod;
   // Pipeline - 2nd stage
   assign data_next.sum   = (i_vreg[1]) ? data_reg.prod + data_reg.col2 : data_reg.sum;
   
   // Top-level outputs
   assign o_mem_addr = data_reg.sum[ADDR_LEN-1:0];
   assign o_valid    = o_vreg;
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         data_reg  <=  '{default:0};
         i_vreg    <=      2'b0;
         o_vreg    <=      1'b0;
      end
      else begin
         data_reg  <=   data_next;
         i_vreg[0] <=   i_valid;
         i_vreg[1] <=   i_vreg[0];
         o_vreg    <=   i_vreg[1];
      end
   end
endmodule 
