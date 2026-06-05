//////////////////////////////////////////////////////////////////////////////////
// Company:       UCD School of Electrical and Electronic Engineering
// Engineer:      Brian Mulkeen
// Project:       Display Interface Design
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   Top-level module to act as test hardware for display interface.
//                Defines top-level input and output signals (see comments on ports).
//                Instantiates clock and reset generator block, for 5 MHz clock.
//                Should instantiate the display interface to be tested.
//  Created: 8 October 2016
//  Modified: 11 October 2019 - new signal name and comments.
//            16 October 2020 - added switch input to control dots
//             3 October 2023 - adjustable number of digits
//////////////////////////////////////////////////////////////////////////////////
module displayTest(
        input clk100,        // 100 MHz clock from oscillator on circuit board
        input rstPBn,        // reset signal, active low, from CPU RESET pushbutton
        input [5:0] sw,      // connects to 6 switches on the circuit board
        output [7:0] digit,  // digit controls - active low (7 on left, 0 on right)
        output [7:0] segment // segment controls - active low (a b c d e f g p)
        );

    localparam NDIGIT = 5;  // number of digits to be displayed (5 or 6)
// ===========================================================================
// Interconnecting Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire rstInt;            // internal reset signal, active high
    wire [4*NDIGIT-1:0] dispVal;    // value to be displayed
    wire [NDIGIT-1:0] swit;     // signal to control the dots

// ===========================================================================
// Instantiate clock and reset generator, connect to signals
    clockReset  clkGen  (
            .clk100 (clk100),       // input clock at 100 MHz
            .rstPBn (rstPBn),       // input reset, active low
            .clk5   (clk5),         // output clock, 5 MHz
            .reset  (rstInt) );     // output reset, active high

//=====================================================================================
// This hardware generates a test value for the display block, using a 30-bit counter.

// 30-bit counter, clocked at 5 MHz, overflows every 214 seconds (approx).
    reg [29:0] testCount;      // 30-bit counter
    always @ (posedge clk5)
        if (rstInt) testCount <= 30'b0;
        else testCount <= testCount + 1'b1;

// Take selected bits from the counter to build the value to be displayed, using
// overlapping groups of bits from the counter for each hexadecimal digit.
// This allows each digit to change at a different rate, slow enough to be checked easily,
// but fast enough to cycle through all 16 symbols in a reasonable time.  
    assign dispVal[3:0]   = testCount[25:22]; // right digit changes every 0.84 s (approx)
    assign dispVal[7:4]   = testCount[26:23]; // second digit changes every 1.7 s (approx)
    assign dispVal[11:8]  = testCount[27:24]; // third digit changes every 3.4 s (approx)
    assign dispVal[15:12] = testCount[28:25]; // fourth changes every 6.7 s (approx)
    assign dispVal[19:16] = testCount[29:26]; // fifth digit changes every 13.4 s (approx)

// For the 6-digit display, the sixth digit is 3 greater than the fifth digit.
    generate 
        if (NDIGIT == 6)
            assign dispVal[23:20] = testCount[29:26] + 4'd3;
    endgenerate

//=====================================================================================
// This hardware generates the dots input for the display block, using switch signals.
    generate 
        if (NDIGIT == 6)
            assign swit = sw;   // use all 6 bits of the switch input
        else   // only 5 bits needed, but all inputs must be used to avoid warning
            assign swit = {sw[5]|sw[4], sw[3:0]};  // combine 2 bits on the left
    endgenerate

// ==================================================================================
/* Instantiate your display interface here.  Connect its clock input to the 5 MHz clock 
	signal, clk5, and its reset input to the internal reset signal, rstInt.  
	The value to be displayed is in the dispVal signal, as generated above.
	The signal to control the dots is called swit.
	The segment output of your module connects to the segment signal.
	The digit output of your module connects to the digit signal.  */

    display_interface #(.CYCLES_BEFORE_SWITCH (1000))
                      disp_interface(.clock   (clk5),
                                     .reset   (rstInt),
                                     .value   (dispVal),
                                     .dots    (swit),
                                     .digit   (digit),
                                     .segment (segment));
     
endmodule
