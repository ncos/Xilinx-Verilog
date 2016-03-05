`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    digit_select
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Selects current digit to display on SSD.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module digit_select(
		d1,
		d2,
		d3,
		d4,
		control,
		digit
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================

			input [3:0]  d1;
			input [3:0]  d2;
			input [3:0]  d3;
			input [3:0]  d4;
			input [1:0]  control;
			output [3:0] digit;  
   
// ==============================================================================
// 									    Implementation
// ==============================================================================

			// Assign digit to display on SSD cathodes
			assign digit = (control == 2'b11) ? d1 : 
								(control == 2'b10) ? d2 : 
								(control == 2'b01) ? d3 : 
								d4;
   
endmodule
