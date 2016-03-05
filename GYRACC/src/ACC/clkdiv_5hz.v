`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    ClkDiv_5Hz
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Converts input 100MHz clock signal to a 5Hz clock signal.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////

// ====================================================================================
// 										  Define Module
// ====================================================================================
module ClkDiv_5Hz(
		CLK,
		RST,
		CLKOUT
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input            CLK;		// 100MHz onboard clock
   input            RST;		// Reset
   output           CLKOUT;	// New clock output
   
   
// ====================================================================================
// 							   Parameters, Registers, and Wires
// ====================================================================================
   reg CLKOUT;
	
   // Current count value
   reg [23:0]       clkCount = 24'h000000;
   // Value to toggle output clock at
   parameter [23:0] cntEndVal = 24'h989680;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
		//------------------------------------------------
		//	5Hz Clock Divider Generates Send/Receive signal
		//------------------------------------------------
		always @(posedge CLK or posedge RST)
			
			// Reset clock
			if (RST == 1'b1) begin
					CLKOUT <= 1'b0;
					clkCount <= 24'h000000;
			end
			else begin
					if (clkCount == cntEndVal) begin
						CLKOUT <= (~CLKOUT);
						clkCount <= 24'h000000;
					end
					else begin
						clkCount <= clkCount + 1'b1;
					end
			end
   
endmodule
