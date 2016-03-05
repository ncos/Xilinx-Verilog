`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    selData
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module converts axis data from 2's compliment to its magnitude
//					 representation.  Based upon the input switches SW(1) and SW(0) either
//					 the x-axis, y-axis, or z-axis data will be output on the DOUT output.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
///////////////////////////////////////////////////////////////////////////////////////////

// ====================================================================================
// 										  Define Module
// ====================================================================================
module sel_Data(
		CLK,
		RST,
		SW,
		xAxis,
		yAxis,
		zAxis,
		DOUT,
		LED
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input        CLK;
   input        RST;
   input [1:0]  SW;
   input [9:0]  xAxis;
   input [9:0]  yAxis;
   input [9:0]  zAxis;
   output [9:0] DOUT;
   output [2:0] LED;
   

// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   reg [9:0]    DOUT;
   reg [2:0]    LED;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================

		//-----------------------------------------------
		//	Select Display Data and Convert to Magnitude
		//-----------------------------------------------
		always @(posedge CLK or posedge RST)
			if (RST == 1'b1)
			begin
				LED <= 3'b000;
				DOUT <= 10'b0000000000;
			end
			else 
			begin
				// select xAxis data for display
				if (SW == 2'b00) begin
					LED <= 3'b001;
					if (xAxis[9] == 1'b1)
						DOUT <= {xAxis[9], (9'b000000000 - xAxis[8:0])};
					else
						DOUT <= xAxis;
				end
				// select yAxis data for display
				else if (SW == 2'b01) begin
					LED <= 3'b010;
					if (yAxis[9] == 1'b1)
						DOUT <= {yAxis[9], (9'b000000000 - yAxis[8:0])};
					else
						DOUT <= yAxis;
				end
				// select zAxis data for display
				else if (SW == 2'b10) begin
					LED <= 3'b100;
					if (zAxis[9] == 1'b1)
						DOUT <= {zAxis[9], (9'b000000000 - zAxis[8:0])};
					else
						DOUT <= zAxis;
				end
				// Default select xAxis data for display
				else begin
					LED <= 3'b001;
					if (xAxis[9] == 1'b1)
						DOUT <= {xAxis[9], (9'b000000000 - xAxis[8:0])};
					else
						DOUT <= xAxis;
				end
			end
		
endmodule

