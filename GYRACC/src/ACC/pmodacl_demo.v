`timescale 1ns / 1ps


// ====================================================================================
// 										  Define Module
// ====================================================================================
module PmodACL(
		CLK,
		RST,
		SDI,
		SDO,
		SCLK,
		SS,
		AN,
		SEG,
		DOT,
		LED,
		x_out,
		y_out,
		z_out
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input        CLK;
   input        RST;
   input        SDI;
   output       SDO;
   output       SCLK;
   output       SS;
   output [3:0] AN;
   output [6:0] SEG;
   output       DOT;
   output [2:0] LED;
   output wire [15:0] x_out;
   output wire [15:0] y_out;
   output wire [15:0] z_out;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   wire [9:0]   xAxis;		// x-axis data from PmodACL
   wire [9:0]   yAxis;		// y-axis data from PmodACL
   wire [9:0]   zAxis;		// z-axis data from PmodACL
   
   wire [9:0]   selData;	// Data selected to display
   
   wire         START;		// Data Transfer Request Signal
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
		//-----------------------------------------------
		//	Select Display Data and Convert to Magnitude
		//-----------------------------------------------
		sel_Data SDATA(
					.CLK(CLK),
					.RST(RST),
					.SW(2'b00),
					.xAxis(xAxis),
					.yAxis(yAxis),
					.zAxis(zAxis),
					.DOUT(selData),
					.LED(LED)
		);
		
		//-----------------------------------------------
		//		 			 Interfaces PmodACL
		//-----------------------------------------------
		SPIcomponent SPI(
					.CLK(CLK),
					.RST(RST),
					.START(START),
					.SDI(SDI),
					.SDO(SDO),
					.SCLK(SCLK),
					.SS(SS),
					.xAxis(xAxis),
					.yAxis(yAxis),
					.zAxis(zAxis)
		);
		
		//-----------------------------------------------
		//		 	 Formats Data and Displays on SSD
		//-----------------------------------------------
		ssdCtrl Disp(
					.CLK(CLK),
					.RST(RST),
					.DIN(selData[9:0]),
					.AN(AN),
					.SEG(SEG),
					.DOT(DOT)
		);
		
		ssdCtrl Disp_X(
                    .CLK(CLK),
                    .RST(RST),
                    .DIN(xAxis),
                    .bcdData(x_out)
        );		
		
		ssdCtrl Disp_Y(
                    .CLK(CLK),
                    .RST(RST),
                    .DIN(yAxis),
                    .bcdData(y_out)
        );
        
		ssdCtrl Disp_Z(
                    .CLK(CLK),
                    .RST(RST),
                    .DIN(zAxis),
                    .bcdData(z_out)
        );        		
		//-----------------------------------------------
		//	 Generates a 5Hz Data Transfer Request Signal
		//-----------------------------------------------
		ClkDiv_5Hz genStart(
					.CLK(CLK),
					.RST(RST),
					.CLKOUT(START)
		);
   
endmodule
