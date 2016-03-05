`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    two_bit_counter
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Produces the select/control signals used to display data.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module two_bit_counter(
		dclk,
		rst,
		control
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================
			
			input        dclk;
			input        rst;
			output [1:0] control;
   
// ==============================================================================
// 							 Parameters, Registers, and Wires
// ==============================================================================   
			
			reg [1:0]    count;
   
// ==============================================================================
// 										Implementation
// ==============================================================================   

			// Counting process
			always @(posedge dclk or posedge rst)
				
				begin
					if (rst == 1'b1)
						count <= {2{1'b0}};
					else
						count <= count + 1'b1;
				end
			
			// Assign output control bus
			assign control = count;
   
endmodule

