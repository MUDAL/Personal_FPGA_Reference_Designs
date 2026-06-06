//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Brian Mulkeen
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Top-level module for calculator design.
//                Defines top-level input and output signals.
//                Instantiates clock and reset generator block, for 5 MHz clock
//                Instantiates keypad, and display interface modules.
//                
//  Created: 30 October 2015
//  Tidied 12 December 2018
//  Updated 16 November 2023 for new version of assignment.
//
//  Modified by Olaoluwa Raji: 23/11/2025
//////////////////////////////////////////////////////////////////////////////////
module calculator_top(
        input clk100,		 // 100 MHz clock from oscillator on board
        input rstPBn,		 // reset signal, active low, from CPU RESET pushbutton
        input [5:0] kpcol,   // keypad column signals
        output [3:0] kprow,  // keypad row signals
        output [7:0] digit,  // digit controls - active low (7 on left, 0 on right)
        output [7:0] segment // segment controls - active low (a b c d e f g p)
        );

// =================================================================================
// Interconnecting Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire reset;             // active high reset, for use in all design blocks
    wire newkey;            // pulse to indicate new key pressed, keycode valid
    wire [4:0]  keycode;    // 5-bit code to identify which key pressed
    wire [19:0] calcOut;    // 20-bit output from calculator, to be displayed
    wire        overflow;   // active-high signal indicating an overflow
    wire [4:0]  dots;       // "dots" input to display [active-low]
// =================================================================================
// Instantiate clock and reset generator, connect to signals
    clockReset  clkGen  (
            .clk100 (clk100),  // 100 MHz clock from oscillator on Nexys 4 board
            .rstPBn (rstPBn),  // active low reset from pushbutton on Nexys 4 board
            .clk5   (clk5),    // 5 MHz clock output for use in the design
            .reset  (reset) ); // reset output, active high, for use in design

//==================================================================================
// Instantiate keypad interface to scan the keypad and return valid keycode
    keypad keypd (
        .clk(clk5),            // clock for keypad module is 5 MHz
        .rst(reset),            // reset is internal reset signal
        .kpcol(kpcol),            // 6 keypad column inputs
        .kprow(kprow),            // 4 keypad row outputs
        .newkey(newkey),        // new key signal
        .keycode(keycode)        // 5-bit code representing key
        );

//==================================================================================
// Display interface
    
    // Disable 4 leftmost dots and use the MSB as an overflow indicator.
    // The "overflow" bit is active-high from "calc_logic". Therefore, it
    // must be inverted in order to turn on the "dot" LEDs which are 
    // active-low.
    assign dots = ~{5{overflow}};
    
    // Our display interface routes the "dots" input to the "segment" output.
    // The "segment" output is active-low.
	display_interface disp (
           .clock   (clk5), 		// 5 MHz clock
	       .reset   (reset),        // active high reset
	       .value   (calcOut),		// input value to be displayed
		   .dots    (dots),         // turn on leftmost dot when overflow occurs
		   .digit   (digit), 		// outputs to the display on the Nexys-4 board
		   .segment (segment)
		   );

//==================================================================================
/* Instantiate your calculator here, and connect its ports to signals in this module:
    Use the 5 MHz clock signal, clk5.
	Use the active-high reset signal, reset.
	Use the keycode and newkey signals from the keypad interface.
	Connect the output to the calcOut signal - change the number of bits if necessary. */
	
	calc_logic calc(.reset    (reset),
	                .clock    (clk5),
	                .newkey   (newkey),
	                .keycode  (keycode),
	                .result   (calcOut),
	                .overflow (overflow));	   
endmodule
