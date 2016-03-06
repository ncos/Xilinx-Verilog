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
   input wire [9:0] DIN;
   output reg [15:0] BCDOUT;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   // Signals for scaled division to determine "g" number
   
   // Input/Output data, binary to BCD converter
   wire [8:0]      inputBCD;
   wire [15:0]     outputBCD;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
   	
   	reg [16:0] tmpDIVIDEND; // Scaling to 'g' values
   	reg [9:0] unsigned_data; //two's complement of data
   	always @(posedge CLK) begin
        unsigned_data <= (DIN[9] == 1'b1) ? ((~(DIN)) + 1'b1) : DIN;
        tmpDIVIDEND <= unsigned_data[8:0] * 8'd201;
    end
   
   // Calculate scaled up dividend
   assign inputBCD = {1'b0, tmpDIVIDEND[16:9]};
   //assign inputBCD = unsigned_data[8:0];

   //------------------------------
   //		 	Binary to BCD
   //------------------------------
   Binary_To_BCD BtoBCD(
				.CLK(CLK),
				.RST(RST),
				.START(DCLK),
				.BIN(unsigned_data),
				.BCDOUT(outputBCD)
	);
   
   // Assign output display data
   //bcdData[15:12] = (DIN[9] == 1'b0) ? (4'hA) : (4'hF);
   always @(posedge CLK) begin
        if (DIN[9]) begin
            BCDOUT <= {4'hF, outputBCD[11:0]};
        end
        else begin
            BCDOUT <= {4'hA, outputBCD[11:0]};
        end
   end
   
endmodule
