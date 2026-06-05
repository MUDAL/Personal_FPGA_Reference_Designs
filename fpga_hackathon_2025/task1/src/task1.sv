// Task 1: Maximum Finder Implementation
// Author: Olaoluwa Raji
// Team:   team_fsm

`timescale 1ns / 1ps
module task1
#(
  parameter int TASK_INPUT_WIDTH  = 16,
  parameter int TASK_OUTPUT_WIDTH = 16,
  parameter int INPUT_STREAMS     = 1,
  parameter int OUTPUT_STREAMS    = 1

)(
  input  logic                                i_clk,
  input  logic                                i_rst,
  input  logic                                i_valid,
  input  logic                                i_first,
  input  logic                                i_last,
  input  logic signed [TASK_INPUT_WIDTH-1:0]  i_data,
  output logic                                o_valid,
  output logic                                o_last,
  output logic signed [TASK_OUTPUT_WIDTH-1:0] o_data
);
  
  typedef enum int unsigned {IDLE, SAMPLE, OUTPUT} state_t;
  state_t state_reg;
  state_t state_next;
  
  logic is_larger;
  logic signed [TASK_INPUT_WIDTH-1:0] largest_reg;
  logic signed [TASK_INPUT_WIDTH-1:0] largest_next;
  
  always_comb begin: datapath
   state_next = state_reg;
   is_larger  = 1'b0;
   case(state_reg)
      IDLE: begin
         o_data  = {TASK_OUTPUT_WIDTH{1'b0}};
         o_valid =       1'b0;
         o_last  =       1'b0;
         if(i_valid && i_first) begin
            state_next = SAMPLE;
            is_larger  = 1'b1;
         end
      end
      SAMPLE: begin
         o_data  = {TASK_OUTPUT_WIDTH{1'b0}};
         o_valid =       1'b0;
         o_last  =       1'b0;
         if(i_valid && i_data > largest_reg) is_larger = 1'b1;
         if(i_last) state_next = OUTPUT;
      end
      OUTPUT: begin
         o_data     = largest_reg;
         o_valid    = 1'b1;
         o_last     = 1'b1;
         state_next = IDLE;
      end
   endcase
  end
 
  // New maximum value detected
  assign largest_next = (is_larger) ? i_data: largest_reg; 
 
  always @(posedge i_clk) begin: registers
   if(i_rst) begin
      state_reg   <= IDLE;
      largest_reg <= {TASK_INPUT_WIDTH{1'b0}};
   end
   else begin
      state_reg   <= state_next;
      largest_reg <= largest_next;
   end
  end

endmodule
