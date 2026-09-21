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

// Matrix traverse.
// Functional design completed on 21/09/2026.  

module matrix_traverse 
#( parameter  int   DATA_LEN = 8,
   parameter  int   ADDR_LEN = 12,
   parameter  int   LATENCY  = 3 )
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
   
   logic                last_element; 
   logic                o_last_reg;
   logic [LATENCY-1:0]  delay_reg;

   // Signals: Reshaper
   logic                i_valid_reshaper;
   logic                o_valid_reg;      
   logic                o_valid_reshaper;
   logic [ADDR_LEN-1:0] o_mem_addr;

   reshaper reshape_ip(.i_clk      (i_clk),
                       .i_rst      (i_rst),
                       .i_valid    (i_valid_reshaper),
                       .i_col_max  (i_col_max),   
                       .i_row      (o_reg.row),
                       .i_col      (o_reg.col),
                       .o_mem_addr (o_mem_addr),
                       .o_valid    (o_valid_reshaper)); 
   
   assign i_valid_reshaper = (state_reg != IDLE);
   assign last_element     =  o_reg.row == i_row_max - 1 && o_reg.col == i_col_max - 1;

   always_comb begin: datapath
      state_next = state_reg;
      i_reg      = o_reg;
      case(state_reg)
         IDLE: begin
            i_reg = '{default:0};
            if(i_enable && !o_valid_reshaper) state_next = HORIZONTAL;
         end
         
         HORIZONTAL: begin
            if(o_reg.row == {ADDR_LEN{1'b0}}) begin
               state_next      =    DIAGONAL;
               i_reg.col       = o_reg.col + 1'b1;            
               i_reg.diag_down =      1'b1;
            end
            else if(o_reg.row == i_row_max - 1) begin
               if(o_reg.col == i_col_max - 1) begin
                  state_next =     IDLE;
                  i_reg      = '{default:0};               
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
               i_reg.row = o_reg.row + 1'b1;
               i_reg.col = o_reg.col - 1'b1;                
               if(last_element) begin                                 
                  state_next =  IDLE;
                  i_reg      =  o_reg;
               end    
               else if(o_reg.row == i_row_max - 2)              state_next = HORIZONTAL;
               else if(o_reg.col == {{ADDR_LEN-1{1'b0}}, 1'b1}) state_next = VERTICAL;
            end
            else begin
               i_reg.row = o_reg.row - 1'b1;
               i_reg.col = o_reg.col + 1'b1;                 
               if(last_element) begin
                  state_next =  IDLE;
                  i_reg      =  o_reg;
               end               
               else if(o_reg.row == {{ADDR_LEN-1{1'b0}}, 1'b1}) state_next = HORIZONTAL;
               else if(o_reg.col == i_col_max - 2)              state_next = VERTICAL;
            end
         end
         
         VERTICAL: begin
            if(o_reg.col == {ADDR_LEN{1'b0}}) begin
               state_next      =    DIAGONAL;
               i_reg.row       = o_reg.row + 1'b1;            
               i_reg.diag_down =      1'b0;
            end
            else if(o_reg.col == i_col_max - 1) begin
               if(o_reg.row == i_row_max - 1) begin
                  state_next =     IDLE;
                  i_reg      = '{default:0};                  
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
  
   // Top-level outputs  
   assign o_read_addr  =   o_mem_addr;
   assign o_last       =   delay_reg[LATENCY-1];
   assign o_valid      =   o_valid_reg;
   assign o_data       =   i_data;
   assign o_done       =   o_valid_reg & delay_reg[LATENCY-1];
   
   always_ff @(posedge i_rst,posedge i_clk) begin: registers
      if(i_rst) begin
         state_reg      <=     IDLE;
         o_reg          <= '{default:0};
         o_valid_reg    <=     1'b0;
         o_last_reg     <=     1'b0;
         delay_reg      <= {LATENCY{1'b0}};
      end
      else begin
         state_reg      <=  state_next;
         o_reg          <=  i_reg;
         o_valid_reg    <=  o_valid_reshaper;
         o_last_reg     <=  last_element;
         // Delay register to account for the reshape IP's latency.
         delay_reg[0]           <=  o_last_reg;
         delay_reg[LATENCY-1:1] <=  delay_reg[LATENCY-2:0];
      end
   end   
endmodule 
