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

module memory_controller(
   input  logic        i_clk,
   input  logic        i_rst,
   input  logic        i_valid,
   input  logic        i_first,
   input  logic        i_last,
   input  logic [7:0]  i_data,
   input  logic        i_restart,
   output logic        o_mem_full,  
   output logic [11:0] o_row_max,
   output logic [11:0] o_col_max,   
   output logic [7:0]  o_data, 
   output logic [11:0] o_write_addr,
   output logic        o_write_en);
   
   typedef enum int unsigned {IDLE = 0, HEADER, WRITE, READ} state_t;
   state_t state_reg;
   state_t state_next;
   
   always_comb begin: datapath
      state_next = state_reg;
      case(state_reg)
         IDLE: begin
         end
         HEADER: begin
         end
         WRITE: begin
         end
         READ: begin
         end
      endcase
   end
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         state_reg <= IDLE;
      end
      else begin
         state_reg <= state_next;
      end
   end   
endmodule 
