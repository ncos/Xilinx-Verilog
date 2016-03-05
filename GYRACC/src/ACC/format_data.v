`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    Format_Data 
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: The purpose of this module is to calculate the "g" value of the
//					 the input data.  In this demo the accelerometer is configured for
//					 +/- 2g, this means that the input data must be divided by the LSB
//					 to get the "g" value of the current reading.
//
//					 The calculated/measured "g" value will range from 0.00 to 2.0X. The
//					 calculated "g" value is sent into a binary to BCD converter, and
//					 the BCD data is output for display on the SSD.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
///////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module Format_Data(
		CLK,
		DCLK,
		RST,
		DIN,
		BCDOUT
);


// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input           CLK;
   input           DCLK;
   input           RST;
   input [8:0]     DIN;
   output [11:0]   BCDOUT;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   // Scaled up divisor and scaling factor for "g" calculation to get hundredths place accuracy
   parameter [7:0] DIVISOR = 8'b10100011;
   parameter [6:0] SCALING = 7'b1000000;
   
   // Signals for scaled division to determine "g" number
   wire [15:0]     tmpDIVIDEND;
   wire [14:0]     quo;
   wire [7:0]      rmd;
   wire            rfd;
   
   // Input/Output data, binary to BCD converter
   wire [8:0]      inputBCD;
   wire [15:0]     outputBCD;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
   // Calculate scaled up dividend
   assign tmpDIVIDEND = DIN * SCALING;
   
   // Assign input data to binary to BCD converter
   assign inputBCD = quo[8:0];
   
   //------------------------------
   //		 	LSB Division
   //------------------------------
   Div Division(
				.clk(CLK),
				.dividend(tmpDIVIDEND[14:0]),
				.divisor(DIVISOR),
				.rfd(rfd),
				.quotient(quo),
				.fractional(rmd)
	);
   
   //------------------------------
   //		 	Binary to BCD
   //------------------------------
   Binary_To_BCD BtoBCD(
				.CLK(CLK),
				.RST(RST),
				.START(DCLK),
				.BIN(inputBCD),
				.BCDOUT(outputBCD)
	);
   
   // Assign output display data
   assign BCDOUT[11:0] = {outputBCD[11:8], {outputBCD[7:4], outputBCD[3:0]}};
   
endmodule
