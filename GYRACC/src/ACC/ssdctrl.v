`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    ssdCtrl 
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module interfaces the onboard seven segment display (SSD) on
//					 the Nexys3, and formats the data to be displayed.
//
//					 The DIN input is a binary number that gets formatted to binary
//					 coded decimal, and is displayed as a signed 3 digit number on the
//					 SSD. Bit 9 on the DIN input controls whether or not a minus sign
//					 will be displayed on the SSD or not.  The AN output bus drives the
//					 SSD's anodes controling the illumination of the 4 digits on the SSD.
//					 The SEG output bus drives the cathodes on the SSD to display different
//					 characters.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
///////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module ssdCtrl(
		CLK,
		RST,
		DIN,
		AN,
		SEG,
		DOT,
		bcdData
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input            CLK;
   input            RST;
   input [9:0]      DIN;
   output [3:0]     AN;
   reg [3:0]        AN;
   output [6:0]     SEG;
   reg [6:0]        SEG;
   output           DOT;
   output wire [15:0] bcdData;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   // 1 kHz Clock Divider
   parameter [15:0] cntEndVal = 16'hC350;
   reg [15:0]       clkCount;
   reg              DCLK;
   
   // 2 Bit Counter
   reg [1:0]        CNT;
   
   // Binary Data to BCD "g" value format x.xx
   //wire [15:0]      bcdData;
   
   // Output Data Mux
   reg [3:0]        muxData;
   
// ====================================================================================
// 										 Implementation
// ====================================================================================
   
		//assign bcdData[15:12] = (DIN[9] == 1'b0) ? (4'hA) : (4'hF);
		
		// Assign DOT when count is 2
		assign DOT = (CNT == 2'b11) ? 1'b0 : 1'b1;
		
		//------------------------------
		//		 	Format Data
		//------------------------------
		Format_Data FDATA(
				.CLK(CLK),
				.DCLK(DCLK),
				.RST(RST),
				.DIN(DIN),
				.BCDOUT(bcdData)
		);
		
		//-----------------------------------------------
		//					 Output Data Mux
		// 		Select data to display on SSD
		//-----------------------------------------------
		always @(CNT[1] or CNT[0] or bcdData or RST)
			if (RST == 1'b1)
				muxData <= 4'b0000;
			else
				case (CNT)
					2'b00 : muxData <= bcdData[3:0];
					2'b01 : muxData <= bcdData[7:4];
					2'b10 : muxData <= bcdData[11:8];
					2'b11 : muxData <= bcdData[15:12];
					default : muxData <= 4'b0000;
				endcase
		
		//------------------------------
		//		   Segment Decoder
		// Determines cathode pattern
		//   to display digit on SSD
		//------------------------------
		always @(posedge DCLK or posedge RST)
			if (RST == 1'b1)
				SEG <= 7'b1000000;
			else 
				case (muxData)
					4'h0 : SEG <= 7'b1000000;	   // 0
					4'h1 : SEG <= 7'b1111001;	   // 1
					4'h2 : SEG <= 7'b0100100;	   // 2
					4'h3 : SEG <= 7'b0110000;	   // 3
					4'h4 : SEG <= 7'b0011001;	   // 4
					4'h5 : SEG <= 7'b0010010;	   // 5
					4'h6 : SEG <= 7'b0000010;	   // 6
					4'h7 : SEG <= 7'b1111000;	   // 7
					4'h8 : SEG <= 7'b0000000;	   // 8
					4'h9 : SEG <= 7'b0010000;	   // 9
					4'hA : SEG <= 7'b0111111;	   // Minus
					4'hF : SEG <= 7'b1111111;	   // Off
					default : SEG <= 7'b1111111;
				endcase
		
		//---------------------------------
		//	  		  Anode Decoder
		//    Determines digit digit to
		//   illuminate for clock period
		//---------------------------------
		always @(posedge DCLK or posedge RST)
			if (RST == 1'b1)
				AN <= 4'b1111;
			else 
				case (CNT)
					2'b00 : AN <= 4'b1110; 	 // 0
					2'b01 : AN <= 4'b1101; 	 // 1
					2'b10 : AN <= 4'b1011; 	 // 2
					2'b11 : AN <= 4'b0111; 	 // 3
					default : AN <= 4'b1111; // All off
				endcase
		
		//------------------------------
		//			2 Bit Counter
		//	 Used to select which digit
		//	  is being illuminated, and
		//	selects data to be displayed
		//------------------------------
		always @(posedge DCLK) begin
				CNT <= CNT + 1'b1;
		end
		
		//------------------------------
		//			1khz Clock Divider
		//  Timing for refreshing the
		//  			 SSD, etc.
		//------------------------------
		always @(posedge CLK) begin
				if (clkCount == cntEndVal) begin
					DCLK <= 1'b1;
					clkCount <= 16'h0000;
				end
				else begin
					DCLK <= 1'b0;
					clkCount <= clkCount + 1'b1;
				end
		end
   
endmodule


