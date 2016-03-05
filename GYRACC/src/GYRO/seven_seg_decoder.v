`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    seven_seg_decoder
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Produces cathode signals for displaying digits on the SSD.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module seven_seg_decoder(
		num_in,
		control,
		seg_out,
		display_sel
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================
			input [3:0]  num_in;
			input [1:0]  control;
			output [6:0] seg_out;
			input        display_sel;
   
   
// ==============================================================================
// 						     Parameters, Registers, and Wires
// ==============================================================================
			wire [6:0]   seg_out_bcd;
			wire [6:0]   seg_out_hex;
			wire [6:0]   seg_out_buf;
   
// ==============================================================================
// 										Implementation
// ==============================================================================

			// If displaying hex, then make digit 4 on the SSD be an "H"
			assign seg_out = (control == 2'b11 & display_sel == 1'b0) ? 7'b0001001 : seg_out_buf;
			
			// Select either the HEX data or Dec. data to display on the SSD.
			assign seg_out_buf = (display_sel == 1'b1) ? seg_out_bcd : seg_out_hex;
			
			// Decimal decoder
			assign seg_out_bcd = (num_in == 4'b0000) ? 7'b1000000 : 		//0
										(num_in == 4'b0001) ? 7'b1111001 : 		//1
										(num_in == 4'b0010) ? 7'b0100100 : 		//2
										(num_in == 4'b0011) ? 7'b0110000 : 		//3
										(num_in == 4'b0100) ? 7'b0011001 : 		//4
										(num_in == 4'b0101) ? 7'b0010010 : 		//5
										(num_in == 4'b0110) ? 7'b0000010 : 		//6
										(num_in == 4'b0111) ? 7'b1111000 : 		//7
										(num_in == 4'b1000) ? 7'b0000000 : 		//8
										(num_in == 4'b1001) ? 7'b0010000 : 		//9
										(num_in == 4'b1010) ? 7'b1111111 : 		//nothing when positive
										(num_in == 4'b1011) ? 7'b1000110 : 		//C for temperature reading
										7'b0111111;										//minus sign

			// Hex decoder
			assign seg_out_hex = (num_in == 4'b0000) ? 7'b1000000 : 		//0
										(num_in == 4'b0001) ? 7'b1111001 : 		//1
										(num_in == 4'b0010) ? 7'b0100100 : 		//2
										(num_in == 4'b0011) ? 7'b0110000 : 		//3
										(num_in == 4'b0100) ? 7'b0011001 : 		//4
										(num_in == 4'b0101) ? 7'b0010010 : 		//5
										(num_in == 4'b0110) ? 7'b0000010 : 		//6
										(num_in == 4'b0111) ? 7'b1111000 : 		//7
										(num_in == 4'b1000) ? 7'b0000000 : 		//8
										(num_in == 4'b1001) ? 7'b0010000 : 		//9
										(num_in == 4'b1010) ? 7'b0001000 : 		//A
										(num_in == 4'b1011) ? 7'b0000011 : 		//B
										(num_in == 4'b1100) ? 7'b1000110 : 		//C
										(num_in == 4'b1101) ? 7'b0100001 : 		//D
										(num_in == 4'b1110) ? 7'b0000110 : 		//E
										7'b0001110;										//F
   
endmodule
