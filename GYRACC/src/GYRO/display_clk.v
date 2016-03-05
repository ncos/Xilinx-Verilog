`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    08/16/2011
// Module Name:    display_clk
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module is a simple clock divider that produces the clock signal
//					 used in display controller.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module display_clk(
		clk,
		RST,
		dclk
);

// ==============================================================================
// 										Port Declarations
// ==============================================================================

			input            clk;
			input            RST;
			output           dclk;
   
// ==============================================================================
// 							  Parameters, Registers, and Wires
// ==============================================================================   

			parameter [15:0] CNTENDVAL = 16'b1011011100110101;
			reg [15:0]       cntval;

// ==============================================================================
// 							  		   Implementation
// ==============================================================================

			//--------------------------------------
			//			  Clock Divider Process
			//--------------------------------------
			always @(posedge clk)
				
				begin
					if (RST == 1'b1)
						cntval <= {16{1'b0}};
					else
						if (cntval == CNTENDVAL)
							cntval <= {16{1'b0}};
						else
							cntval <= cntval + 1'b1;
				end
			
			// Assign output clock
			assign dclk = cntval[15];
   
endmodule
