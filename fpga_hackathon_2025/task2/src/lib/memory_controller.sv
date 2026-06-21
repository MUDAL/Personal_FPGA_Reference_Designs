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

// Memory controller module.

// WORK IN PROGRESS !!!!!!!

module memory_controller
#( parameter int   DATA_LEN = 8,
   parameter int   ADDR_LEN = 12 )
 ( input    logic                i_clk,
   input    logic                i_rst,
   input    logic                i_valid,
   input    logic                i_first,
   input    logic                i_last,
   input    logic [DATA_LEN-1:0] i_data,
   input    logic                i_traverse_done,
   output   logic [ADDR_LEN-1:0] o_row_max,
   output   logic [ADDR_LEN-1:0] o_col_max,   
   output   logic [DATA_LEN-1:0] o_data, 
   output   logic [ADDR_LEN-1:0] o_write_addr,
   output   logic                o_write_en,
   output   logic                o_read_en);
   
   typedef enum int unsigned {IDLE = 0, HEADER_END, WRITE, READ} state_t;
   state_t state_reg;
   state_t state_next;
   
   typedef struct
   {
      logic  [ADDR_LEN-1:0] max_row;
      logic  [ADDR_LEN-1:0] max_col;
      logic  [ADDR_LEN-1:0] addr;
   }data_t;      // Datapath register
   data_t o_reg; // Register output
   data_t i_reg; // Register input
   
   always_comb begin: datapath
      state_next = state_reg;
      i_reg      = o_reg;
      case(state_reg)
         IDLE: begin
            if(i_valid && i_first) begin
               state_next    = HEADER_END;
               i_reg.max_row = i_data;
            end
         end
         HEADER_END: begin
            state_next    = WRITE;
            i_reg.max_col = i_data;
         end
         WRITE: begin
            i_reg.addr = o_reg.addr + 1'b1;
            if(i_valid && i_last) state_next = READ;
         end
         READ: begin
            if(i_traverse_done) begin
               state_next =      IDLE;
               i_reg.addr = {ADDR_LEN{1'b0}};
            end
         end
      endcase
   end
   
   // Top-level outputs
   assign o_row_max    =  o_reg.max_row;
   assign o_col_max    =  o_reg.max_col;
   assign o_write_addr =  o_reg.addr;  
   assign o_data       = (state_reg == WRITE) ? i_data : {DATA_LEN{1'b0}};
   assign o_write_en   = (state_reg == WRITE);
   assign o_read_en    = (state_reg == READ);
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         state_reg <=     IDLE;
         o_reg     <= '{default:0};
      end
      else begin
         state_reg <=   state_next;
         o_reg     <=   i_reg;
      end
   end   
endmodule 
