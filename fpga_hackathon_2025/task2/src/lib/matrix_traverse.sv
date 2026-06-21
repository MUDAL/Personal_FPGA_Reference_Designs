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

// Matrix traverse

// WORK IN PROGRESS !!!!!!!!!!!!!

// Important stuff [You might not get it perfectly on first try. Verify!!!!]:
// 1. You need to know the latency of the reshaper in order to know when to
// supply a valid address to the memory.
// 2. You need to know the latency of the memory in order to know when to
// transfer the valid incoming data from the memory.

// 3. How do we return to the IDLE state when we are done? This transition is
// possible in two cases. Case 1: Horizontal state, last column. 
// ---------------------- Case 2: Vertical state, last row. [DONE]

// 4. 'o_done' should be asserted a cycle after o_valid & o_last to signal the 
// end of the matrix traverse. [DONE]

// 5. Add logic for 'i_rvalid'. This signifies valid data into the reshaper IP.
// Valid data goes into the IP when we're not in the IDLE state. [DONE]

// You can register the 'o_valid' and 'o_data' later.

module matrix_traverse 
#( parameter  int   DATA_LEN       = 8,
   parameter  int   ADDR_LEN       = 12,
   parameter  int   MEM_WR_LATENCY = 1,
   parameter  int   MEM_RD_LATENCY = 1 )
 ( input     logic                i_clk,
   input     logic                i_rst,
   input     logic [ADDR_LEN-1:0] i_row_max,
   input     logic [ADDR_LEN-1:0] i_col_max,
   input     logic                i_enable,
   input     logic [DATA_LEN-1:0] i_data,
   output    logic [ADDR_LEN-1:0] o_read_addr,
   output    logic                o_done, 
   output    logic [DATA_LEN-1:0] o_data,   
   output    logic                o_valid,
   output    logic                o_last);
   
   typedef enum int unsigned {
      IDLE = 0, 
      HORIZONTAL, 
      DIAGONAL, 
      VERTICAL
   }state_t;
   state_t state_reg;
   state_t state_next;
   
   typedef struct {
      logic [ADDR_LEN-1:0] row;
      logic [ADDR_LEN-1:0] col;
      logic                diag_down;
   }data_t;      // Datapath registers
   data_t o_reg; // Register output
   data_t i_reg; // Register input
   
   logic                 o_mem_last; 
   logic                 done_reg;
   logic                 done_next; 
   // Signals: Reshaper
   logic                 i_rvalid;   
   logic                 o_rvalid;
   logic [ADDR_LEN-1:0]  o_mem_addr;
   // Pipeline registers
   localparam int PIPE_REGS = MEM_WR_LATENCY + MEM_RD_LATENCY;
   logic [PIPE_REGS-1:0] o_valid_pipe;
   logic [PIPE_REGS-1:0] o_last_pipe;
   
   reshaper reshape_ip(.i_clk      (i_clk),
                       .i_rst      (i_rst),
                       .i_valid    (i_rvalid),
                       .i_row_max  (i_row_max),   
                       .i_row      (o_reg.row),
                       .i_col      (o_reg.col),
                       .o_mem_addr (o_mem_addr),
                       .o_valid    (o_rvalid)); 
   
   assign i_rvalid = (state_reg != IDLE);
   
   always_comb begin: datapath
      state_next = state_reg;
      i_reg      = o_reg;
      case(state_reg)
         IDLE: begin
            if(i_enable) begin
               state_next = HORIZONTAL;
            end
         end
         
         HORIZONTAL: begin
            if(o_reg.row == {ADDR_LEN{1'b0}}) begin
               state_next      =    DIAGONAL;
               i_reg.col       = o_reg.col + 1'b1;            
               i_reg.diag_down =      1'b1;
            end
            if(o_reg.row == i_row_max - 1) begin
               if(o_reg.col == i_col_max - 1) begin
                  state_next      =      IDLE;
                  i_reg.row       = {ADDR_LEN{1'b0}};
                  i_reg.col       = {ADDR_LEN{1'b0}};
                  i_reg.diag_down =      1'b0;                 
               end
               else begin
                  state_next      =     DIAGONAL;
                  i_reg.col       =  o_reg.col + 1'b1;            
                  i_reg.diag_down =       1'b0;               
               end          
            end
         end
         
         DIAGONAL: begin
            if(o_reg.diag_down) begin
               if(o_reg.row == i_row_max - 2) begin
                  state_next = HORIZONTAL;
                  i_reg.row  = o_reg.row + 1'b1;
                  i_reg.col  = o_reg.col - 1'b1;
               end
               else if(o_reg.col == {{ADDR_LEN-1{1'b0}}, 1'b1}) begin
                  state_next = VERTICAL;
                  i_reg.row  = o_reg.row + 1'b1;
                  i_reg.col  = o_reg.col - 1'b1;                
               end
            end
            else begin
               if(o_reg.col == i_col_max - 2) begin
                  state_next = VERTICAL;
                  i_reg.row  = o_reg.row - 1'b1;
                  i_reg.col  = o_reg.col + 1'b1;                  
               end
               else if(o_reg.row == {{ADDR_LEN-1{1'b0}}, 1'b1}) begin
                  state_next = HORIZONTAL;
                  i_reg.row  = o_reg.row - 1'b1;
                  i_reg.col  = o_reg.col + 1'b1;
               end
            end
         end
         
         VERTICAL: begin
            if(o_reg.col == {ADDR_LEN{1'b0}}) begin
               state_next      =    DIAGONAL;
               i_reg.row       = o_reg.row + 1'b1;            
               i_reg.diag_down =      1'b0;
            end
            if(o_reg.col == i_col_max - 1) begin
               if(o_reg.row == i_row_max - 1) begin
                  state_next      =      IDLE;
                  i_reg.row       = {ADDR_LEN{1'b0}};
                  i_reg.col       = {ADDR_LEN{1'b0}};
                  i_reg.diag_down =      1'b0;                 
               end
               else begin
                  state_next      =     DIAGONAL;
                  i_reg.row       =  o_reg.row + 1'b1;            
                  i_reg.diag_down =       1'b1;               
               end
            end         
         end
      endcase
   end
   
   assign o_mem_last  = (o_reg.row == i_row_max - 1 && o_reg.col == i_col_max - 1);
   assign done_next   =  o_valid_pipe[PIPE_REGS-1] & o_last_pipe[PIPE_REGS-1];
   // Top-level outputs  
   assign o_read_addr =  o_mem_addr;
   assign o_last      =  o_last_pipe[ PIPE_REGS-1];
   assign o_valid     =  o_valid_pipe[PIPE_REGS-1];
   assign o_data      = (o_valid_pipe[PIPE_REGS-1]) ? i_data : {DATA_LEN{1'b0}};
   assign o_done      =  done_reg;
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         state_reg    <=      IDLE;
         o_reg        <=  '{default:0};
         done_reg     <=      1'b0;
         o_valid_pipe <= {PIPE_REGS{1'b0}};
         o_last_pipe  <= {PIPE_REGS{1'b0}};
      end
      else begin
         state_reg    <=    state_next;
         o_reg        <=    i_reg;
         done_reg     <=    done_next;
         // Shift registers for pipelining
         o_valid_pipe[0]             <= o_rvalid;
         o_valid_pipe[PIPE_REGS-1:1] <= o_valid_pipe[PIPE_REGS-2:0];
         o_last_pipe[0]              <= o_mem_last;
         o_last_pipe[PIPE_REGS-1:1]  <= o_last_pipe[PIPE_REGS-2:0];
      end
   end   
endmodule 
