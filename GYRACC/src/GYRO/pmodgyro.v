`timescale 1ns / 1ps
// ==============================================================================
// 										  Define Module
// ==============================================================================
module PmodGYRO (
		input wire clk,
		input wire RST,
		inout wire  [3:0] JA,
             
        output wire [7:0]   temp_data,
        output wire [15:0]  x_axis_data,
        output wire [15:0]  y_axis_data,
        output wire [15:0]  z_axis_data
);
// ==============================================================================
// 							  Parameters, Registers, and Wires
// ==============================================================================   
   wire         begin_transmission;
   wire         end_transmission;
   wire [7:0]   send_data;
   wire [7:0]   recieved_data;
   wire         slave_select;
   
// ==============================================================================
// 							  		   Implementation
// ==============================================================================      
			//--------------------------------------
			//		Serial Port Interface Controller
			//--------------------------------------
			master_interface C0(
						.begin_transmission(begin_transmission),
						.end_transmission(end_transmission),
						.send_data(send_data),
						.recieved_data(recieved_data),
						.clk(clk),
						.rst(RST),
						.slave_select(slave_select),
						.start(1'b1),
						.temp_data(temp_data),
						.x_axis_data(x_axis_data),
						.y_axis_data(y_axis_data),
						.z_axis_data(z_axis_data)
			);
   
   
			//--------------------------------------
			//		    Serial Port Interface
			//--------------------------------------
			spi_interface C1(
						.begin_transmission(begin_transmission),
						.slave_select(slave_select),
						.send_data(send_data),
						.recieved_data(recieved_data),
						.miso(JA[2]),
						.clk(clk),
						.rst(RST),
						.end_transmission(end_transmission),
						.mosi(JA[1]),
						.sclk(JA[3])
			);

			//  Assign slave select output
			assign JA[0] = slave_select;
   
endmodule
