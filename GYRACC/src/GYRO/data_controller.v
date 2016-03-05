`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////


// ==============================================================================
// 										  Define Module
// ==============================================================================
module data_controller(
		clk,
		dclk,
		rst,
		display_sel,
		sel,
		data,
		D1,
		D2,
		D3,
		D4,
		frmt
);

// ==============================================================================
// 									   Port Declarations
// ==============================================================================
			input			 clk;
			input			 dclk;
			input			 rst;
			input        display_sel;
			input [1:0]  sel;
			input [15:0] data;
			output [3:0] D1;
			output [3:0] D2;
			output [3:0] D3;
			output [3:0] D4;
            output [15:0] frmt;
   
// ==============================================================================
// 						     Parameters, Registers, and Wires
// ==============================================================================
			wire [15:0]  bcd_buf;
			wire [19:0]  temp;
			wire [15:0]  unsigned_data;
			wire [19:0]  unsigned_scaled_data;
			wire [15:0]  bcd;
   
// ==============================================================================
// 										Implementation
// ==============================================================================

			// Assign outputs
			assign D1 = (display_sel == 1'b1) ? bcd[15:12] : 4'b0000;
			assign D2 = (display_sel == 1'b1) ? bcd[11:8] : data[15:12];
			assign D3 = (display_sel == 1'b1) ? bcd[7:4] : data[11:8];
			assign D4 = (display_sel == 1'b1) ? bcd[3:0] : data[7:4];
			assign frmt = {D1, D2, D3, D4};
			
			//determine sign of data, if shown BCD data is zero, don't have a negative sign
			assign bcd[15:12] = ((data[15] == 1'b1 & (bcd[11:0] != 0))) ? 4'b1111 : 4'b1010;
			
			//two's complement of data
			assign unsigned_data = (data[15] == 1'b1) ? ((~(data)) + 1'b1) : data;
			
			//scale value
			assign temp = (sel != 2'b11) ? (unsigned_data * 4'b1001) : {4'b0000, (5'd25 - (data - 5'd25))};
			assign unsigned_scaled_data = (sel != 2'b11) ? {10'b0000000000, temp[19:10]} : temp;
			
			// Convert from binary to binary coded decimal
			Binary_To_BCD BtoBCD(
						.CLK(clk),
						.RST(rst),
						.START(dclk),
						.BIN(unsigned_scaled_data[15:0]),
						.BCDOUT(bcd_buf)
			);
			
			// Assign BCD output
			assign bcd[11:0] = (sel == 2'b11) ? {bcd_buf[7:0], 4'b1011} : bcd_buf[11:0];
   
endmodule
