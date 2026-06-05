//////////////////////////////////////////////////////////////////////////////////
// Company:       UCD School of Electrical and Electronic Engineering
// Engineer:      Brian Mulkeen
// Project:       Bicycle Light Design assignment
// Target Device: XC7A100T-csg324 on Digilent Nexys-4/A7 board
// Description:   Top-level module for testing bicycle light design.
//                Defines input and output signals on the FPGA, described in
//                comments on the port list.
//                Wire light connects to all 3 led outputs as required.
//                Instantiates clock and reset generator block, for 5 MHz clock.
//                Instantiates the light controller to be tested.
//////////////////////////////////////////////////////////////////////////////////
module BikeLightTest (
        input clk100,        // 100 MHz clock from oscillator on board
        input rstPBn,        // reset signal, active low, from CPU RESET pushbutton
        input btnL,          // signal from BTNL pushbutton, active high
        output [3:0] JA,     // output for viewing on an oscilloscope
        output [2:0] led     // output to 3 LEDs, active high
        );

// ===========================================================================
// Internal Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire reset;             // internal reset signal, active high
    wire light;             // connects to the output of the light controller

// ===========================================================================
// Connect the 1-bit output of the light controller to 3 LEDs
    assign led = {3{light}};  // 3 copies of the light signal

// ===========================================================================
// Assign signals to the test port for viewing on an oscilloscope
    assign JA = {led, btnL};

// ===========================================================================
// Instantiate clock and reset generator, connect to signals
    clockReset  clkGen  (
            .clk100 (clk100),       // input clock at 100 MHz
            .rstPBn (rstPBn),       // input reset, active low
            .clk5   (clk5),         // output clock, 5 MHz
            .reset  (reset) );      // output reset, active high


// ==================================================================================
// Instantiate your light controller here. 
// Use the 5 MHz clock signal, clk5, and the active high reset signal, reset.
// Use btnL as the button input signal to your controller.
// If your controller has a 1-bit output, connect it to the light signal.
// If your controller has a 3-bit output, connect it directly to the led signal, 
// and delete lines 26 to 30.
    
    light_controller #(.NUM_HALF_PERIOD_CYCLES (1_250_000),
                       .NUM_DEBOUNCE_CYCLES    (50_000))
                       
        light_control(.reset  (reset),
                      .clock  (clk5),
                      .button (btnL),
                      .light  (light));
                                    
endmodule
