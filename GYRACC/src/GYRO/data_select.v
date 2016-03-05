`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    07/11/2012
// Module Name:    data_select
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: Uses "sel" input signals to select data to output on "data" bus.
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module data_select(
		x_axis,
		y_axis,
		z_axis,
		temp_data,
		data,
		sel
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================

			input [15:0]  x_axis;
			input [15:0]  y_axis;
			input [15:0]  z_axis;
			input [7:0]   temp_data;
			input [1:0]   sel;
			output [15:0] data;

// ==============================================================================
// 							  Parameters, Registers, and Wires
// ==============================================================================

			reg [15:0] data;
   
// ==============================================================================
// 									    Implementation
// ==============================================================================
   
			always @(sel, x_axis, y_axis, z_axis, temp_data) begin
					case (sel)
							2'b00 : data <= x_axis;
							2'b01 : data <= y_axis;
							2'b10 : data <= z_axis;
							2'b11 : data <= {8'h00, temp_data};
					endcase
			end

endmodule
