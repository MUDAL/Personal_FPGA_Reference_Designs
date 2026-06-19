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
   
   logic   [ADDR_LEN-1:0] max_reg;
   logic   [ADDR_LEN-1:0] max_next;
   logic   [ADDR_LEN-1:0] row_reg;
   logic   [ADDR_LEN-1:0] row_next;
   logic   [ADDR_LEN-1:0] col_reg1;
   logic   [ADDR_LEN-1:0] col_next1;
   logic   [ADDR_LEN-1:0] col_reg2;
   logic   [ADDR_LEN-1:0] col_next2;   
   logic [2*ADDR_LEN-1:0] prod_reg;
   logic [2*ADDR_LEN-1:0] prod_next;
   logic [2*ADDR_LEN:0  ] sum_reg;
   logic [2*ADDR_LEN:0  ] sum_next;
   logic            [1:0] i_vreg;   
   logic                  o_vreg;   
   
   // Loading input registers
   assign max_next   = (i_valid)   ?  i_row_max : max_reg;
   assign row_next   = (i_valid)   ?  i_row     : row_reg;
   assign col_next1  = (i_valid)   ?  i_col     : col_reg1;
   // Pipeline - 1st stage 
   assign col_next2  =  col_reg1;
   assign prod_next  = (i_vreg[0]) ?  max_reg * row_reg  : prod_reg;
   // Pipeline - 2nd stage
   assign sum_next   = (i_vreg[1]) ? prod_reg + col_reg2 : sum_reg;
   
   // Top-level outputs
   assign o_mem_addr = sum_reg[ADDR_LEN-1:0];
   assign o_valid    =  o_vreg;
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         max_reg   <= {     ADDR_LEN{1'b0}};
         row_reg   <= {     ADDR_LEN{1'b0}};
         col_reg1  <= {     ADDR_LEN{1'b0}};
         col_reg2  <= {     ADDR_LEN{1'b0}};         
         prod_reg  <= {   2*ADDR_LEN{1'b0}};
         sum_reg   <= { 2*ADDR_LEN+1{1'b0}};
         i_vreg    <=          2'b0;
         o_vreg    <=          1'b0;
      end
      else begin
         max_reg   <=   max_next;
         row_reg   <=   row_next;
         col_reg1  <=   col_next1;
         col_reg2  <=   col_next2;       
         prod_reg  <=   prod_next;
         sum_reg   <=   sum_next;
         i_vreg[0] <=   i_valid;
         i_vreg[1] <=   i_vreg[0];
         o_vreg    <=   i_vreg[1];
      end
   end
endmodule 
