`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    decimal_select
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Select decimal display data.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module decimal_select(
		control,
		dp
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================
			input [1:0] control;
			output      dp;
   
// ==============================================================================
// 									    Implementation
// ==============================================================================
  
			assign dp = (control == 2'b11) ? 1'b1 : 
							(control == 2'b10) ? 1'b1 : 
							(control == 2'b01) ? 1'b1 : 
							1'b1;
			
endmodule
