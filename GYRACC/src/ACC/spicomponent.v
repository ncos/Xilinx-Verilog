`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
//				 Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    SPIcomponent
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: The spi_master controls the state of the entire interface. Using 
//					 several signals to interact with the other modules. The spi_master
//					 selects the data to be transmitted and stores all data received
//					 from the PmodACL.  The data is then made available to the rest of
//					 the design on the xAxis, yAxis, and zAxis outputs.
//
//
//  Inputs:
//		CLK				100MHz onboard system clock
//		RST				Main Reset Controller
//		START				Signal to initialize a data transfer
//		SDI				Serial Data In
//
//  Outputs:
//		SDO				Serial Data Out
//		SCLK				Serial Clock
//		SS					Slave Select
//		xAxis				x-axis data received from PmodACL
//		yAxis				y-axis data received from PmodACL
//		zAxis				z-axis data received from PmodACL
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added comments and modified code (Josh Sackos)
////////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								  Define Module, Inputs and Outputs
//  ===================================================================================
module SPIcomponent(
		CLK,
		RST,
		START,
		SDI,
		SDO,
		SCLK,
		SS,
		xAxis,
		yAxis,
		zAxis
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input        CLK;
   input        RST;
   input        START;
   input        SDI;
   output       SDO;
   output       SCLK;
   output       SS;
   output [9:0] xAxis;
   output [9:0] yAxis;
   output [9:0] zAxis;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
	wire [9:0] 	 xAxis;
	wire [9:0] 	 yAxis;
	wire [9:0] 	 zAxis;

   wire [15:0]  TxBuffer;
   wire [7:0]   RxBuffer;
   wire         doneConfigure;
   wire         done;
   wire         transmit;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
		//-------------------------------------------------------------------------
		//	Controls SPI Interface, Stores Received Data, and Controls Data to Send
		//-------------------------------------------------------------------------
		SPImaster C0(
					.rst(RST),
					.start(START),
					.clk(CLK),
					.transmit(transmit),
					.txdata(TxBuffer),
					.rxdata(RxBuffer),
					.done(done),
					.x_axis_data(xAxis),
					.y_axis_data(yAxis),
					.z_axis_data(zAxis)
		);
		
		//-------------------------------------------------------------------------
		//		 Produces Timing Signal, Reads ACL Data, and Writes Data to ACL
		//-------------------------------------------------------------------------
		SPIinterface C1(
					.sdi(SDI),
					.sdo(SDO),
					.rst(RST),
					.clk(CLK),
					.sclk(SCLK),
					.txbuffer(TxBuffer),
					.rxbuffer(RxBuffer),
					.done_out(done),
					.transmit(transmit)
		);
		
		//-------------------------------------------------------------------------
		//		 			 	Enables/Disables PmodACL Communication
		//-------------------------------------------------------------------------
		slaveSelect C2(
					.clk(CLK),
					.ss(SS),
					.done(done),
					.transmit(transmit),
					.rst(RST)
		);
   
endmodule
