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

// Memory module

module memory
#( parameter int   DATA_LEN = 8,
   parameter int   ADDR_LEN = 12 )
 ( input    logic                i_clk,
   input    logic                i_we,
   input    logic [ADDR_LEN-1:0] w_addr,
   input    logic [ADDR_LEN-1:0] r_addr,
   input    logic [DATA_LEN-1:0] i_data,
   output   logic [DATA_LEN-1:0] o_data);
   
   logic [DATA_LEN-1:0] bram[0:2**ADDR_LEN-1];  
   
   always_ff @(posedge i_clk) begin
      if(i_we) begin
         bram[w_addr] <= i_data;
      end
      o_data <= bram[r_addr];
   end   
endmodule 
