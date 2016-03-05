`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
// 
// Create Date:    08/16/2011
// Module Name:    display_controller
// Project Name: 	 PmodGYRO_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module formats all data received from the PmodGYRO and
//					 displays it on the seven segment display (SSD).
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
///////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================
// 										  Define Module
// ==============================================================================
module display_controller(
		clk,
		rst,
		sel,
		temp_data,
		x_axis,
		y_axis,
		z_axis,
		dp,
		an,
		seg,
		display_sel,
		data_out
);

// ==============================================================================
// 										Port Declarations
// ==============================================================================
   input        clk;
   input        rst;
   input [1:0]  sel;
   input [7:0]  temp_data;
   input [15:0] x_axis;
   input [15:0] y_axis;
   input [15:0] z_axis;
   input        display_sel;
   output       dp;
   output [3:0] an;
   output [6:0] seg;
   output [15:0] data_out;

// ==============================================================================
// 							Parameters, Registers, and Wires
// ==============================================================================   
   wire [1:0]   control;
   wire         dclk;

   wire [3:0]   digit;
   wire [15:0]  data;
	wire 			 dispSel;
	wire [3:0]	 anodes;
   wire [3:0] D1;
   wire [3:0] D2;
   wire [3:0] D3;
   wire [3:0] D4;
	reg [1:0]    nSel;
	wire [3:0]	 an;

// ==============================================================================
// 										Implementation
// ==============================================================================

			//---------------------------------------------------
			// 		Formats data received from PmodGYRO
			//---------------------------------------------------
			data_controller C0(
						.clk(clk),
						.dclk(dclk),
						.rst(rst),
						.display_sel(dispSel),
						.sel(sel),
						.data(data),
						.D1(D1),
						.D2(D2),
						.D3(D3),
						.D4(D4),
						.frmt(data_out)
			);
			
			
			//---------------------------------------------------
			// 		  Clock for display components
			//---------------------------------------------------
			display_clk C1(
						.clk(clk),
						.RST(rst),
						.dclk(dclk)
			);
			
			
			//---------------------------------------------------
			// Produces anode pattern to illuminate digit on SSD
			//---------------------------------------------------
			anode_decoder C2(
						.anode(anodes),
						.control(control)
			);
			
			
			//---------------------------------------------------
			// Produces cathode pattern to dipslay digits on SSD
			//---------------------------------------------------
			seven_seg_decoder C3(
						.num_in(digit),
						.control(control),
						.seg_out(seg),
						.display_sel(dispSel)
			);
			
			
			//---------------------------------------------------
			//			    Provides select/control signal
			//---------------------------------------------------
			two_bit_counter C4(
						.dclk(dclk),
						.rst(rst),
						.control(control)
			);
			
			
			//---------------------------------------------------
			// 			         Digit data mux
			//---------------------------------------------------
			digit_select C5(
						.d1(D1),
						.d2(D2),
						.d3(D3),
						.d4(D4),
						.control(control),
						.digit(digit)
			);
			
			
			//---------------------------------------------------
			//				   Anode for the decimal on SSD
			//---------------------------------------------------
			decimal_select C6(
						.control(control),
						.dp(dp)
			);
		

			//---------------------------------------------------
			//    Select temperature or axis data to display
			//---------------------------------------------------
			data_select C7(
						.x_axis(x_axis),
						.y_axis(y_axis),
						.z_axis(z_axis),
						.temp_data(temp_data),
						.sel(sel),
						.data(data)
			);

			// Both select bits asserted, temperature selected, display decimal value
			assign dispSel = (display_sel == 1'b1 || sel == 2'b11) ? 1'b1 : 1'b0;
			
			// Do not display anything if reset
			assign an = (rst == 1'b1) ? 4'b1111 : anodes;

endmodule
