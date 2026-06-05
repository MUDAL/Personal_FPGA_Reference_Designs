`timescale 1ns / 1ps
module debounce_tb;
	// Inputs to module being verified
	reg clock, reset, button;
	// Outputs from module being verified
	wire press;
	// Instantiate module
	debounce #(.NUM_CYCLES (50))
	   uut (
.clock  (clock),
		    .reset  (reset),
		    .button (button),
		    .press  (press));
	// Generate clock signal
	initial
		begin
			clock  = 1'b0;
			forever
				#100 clock  = ~clock ;
		end
	// Generate other input signals
	initial
		begin
			reset = 1'b1;
			button = 1'b0;
			#400
			reset = 1'b0;
			#100
			button = 1'b1;
			#300
			button = 1'b0;
			#400
			button = 1'b1;
			#200
			button = 1'b0;
			#200
			button = 1'b1;
			#100
			button = 1'b0;
			#200
			button = 1'b1;
			#100
			button = 1'b0;
			#800
			button = 1'b1;
			#1200
			button = 1'b0;
			#400
			button = 1'b1;
			#10_000
			button = 1'b0;
			#12_000
			button = 1'b1;
			#200
			button = 1'b0;
			#800
			button = 1'b1;
			#50
			button = 1'b0;
			#100_000
			button = 1'b1;
			#20_000
			button = 1'b0;
			#500
			button = 1'b1;
			#500
			button = 1'b0;
			#500
			button = 1'b1;
			#500
			button = 1'b0;
			#500
			button = 1'b1;	
			#1000
			button = 1'b0;	
			#2000
			button = 1'b1;	
			#800
			button = 1'b0;												
			#200_000
			$stop;
		end
endmodule
