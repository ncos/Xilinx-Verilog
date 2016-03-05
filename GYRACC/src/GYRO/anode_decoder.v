//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    anode_decoder
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Produces anode patterns to illuminate one digit on the SSD at a time.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module anode_decoder(
		anode,
		control
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================

			output [3:0] anode;
			input [1:0]  control;
   
// ==============================================================================
// 										Implementation
// ==============================================================================

			// Anode Mux
			assign anode = (control == 2'b00) ? 4'b1110 : 
								(control == 2'b01) ? 4'b1101 : 
								(control == 2'b10) ? 4'b1011 : 
								4'b0111;
   
endmodule
