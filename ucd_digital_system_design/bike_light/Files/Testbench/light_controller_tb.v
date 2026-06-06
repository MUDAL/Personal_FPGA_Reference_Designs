// This testbench was auto-generated from a GUI tool provided by UCD.
// Modified by Olaoluwa Raji to accomodate parameterized UUT instantiation.
// The verification of this module was manual as it relied heavily on the
// inspection of waveforms in Vivado.  
// Date: 31/10/2025

`timescale 1ns / 1ps

module light_controller_tb;
   // Inputs to module being verified
   reg clock, reset, button;
   // Outputs from module being verified
   wire light;
   
   // Instantiate module
   light_controller #(.NUM_HALF_PERIOD_CYCLES (3),
                      .NUM_DEBOUNCE_CYCLES    (4)) uut
                     (.clock  (clock),
                      .reset  (reset),
                      .button (button),
                      .light  (light));
                      
   // Generate clock signal
   initial begin
      clock = 1'b0;
      forever #100 clock  = ~clock;
   end
   
   // Generate other input signals
   initial begin
      reset = 1'b1;
      button = 1'b1;
      #350
      reset = 1'b0;
      #2900
      button = 1'b0;
      #900
      button = 1'b1;
      #3500
      button = 1'b0;
      #1500
      button = 1'b1;
      #200
      button = 1'b0;
      #200
      button = 1'b1;
      #300
      button = 1'b0;
      #300
      button = 1'b1;
      #2700
      button = 1'b0;
      #7150
      $stop;
   end
endmodule
