`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:46:50 02/18/2016 
// Design Name: 
// Module Name:    AR_RXD 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AR_RXD(
    input clk,  // clock
    input in0,  // input for 0 signal
    input in1,  // input for 1 signal
    output [22:0] sr_dat,  // received data
    output [7:0]  sr_adr,  // received address
    output ce_wr  // receive completed correctly
    );
	 
	 wire fall;
	 wire rise;
	 reg in          = 0;
	 reg st_in       = 0;
	 reg st_in_prev  = 0;
	 reg time_done   = 0;
	 reg err         = 0;
	 reg wr_r        = 0;
	 reg parity      = 1;
	 reg [31:0] recv = 0;
	 reg [63:0] counter   = 0;
	 reg [5:0]  rcv_count = 0;
	 reg [31:0] out       = 0;
	 reg [63:0] in_time   = 0;

	 assign ce_wr = wr_r;
	 assign fall  = ((st_in == 0) & (st_in_prev == 1));
	 assign rise  = ((st_in == 1) & (st_in_prev == 0));
	 assign sr_adr = out [31 : 24];
	 
	 genvar i;
	 generate for (i = 23; i >= 1; i = i - 1)
	   begin
	       assign sr_dat[i-1] = out [24-i];
	   end  
	 endgenerate
	 
	 //assign sr_dat = out [23 : 1];
	 
	 always @(posedge clk)
	 begin
		st_in_prev <= st_in;
		st_in <= (in0 | in1) ? 1 : 0;
		in    <= (rise) ? in1 : in;
		counter    <= (fall) ? 0 : counter + 1;
		err        <= (err == 1) ? 0 : (time_done & (counter > (in_time << 1))) ? 1 : 0;
		wr_r       <= (err == 1) ? 0 : (rcv_count == 32) ? (parity == recv[0]) : wr_r;
		parity     <= (err == 1) ? 1 : (rcv_count == 32) ? 1    : (fall) ? parity ^ recv[0] : parity;
		recv       <= (err == 1) ? 0 : (rcv_count == 32) ? 0    : (fall) ? (recv << 1) | in : recv;
		rcv_count  <= (err == 1) ? 0 : (rcv_count == 32) ? 0    : (fall) ? rcv_count+1 : rcv_count;
		out        <= (err == 1) ? 0 : (rcv_count == 32) ? recv : out;
		in_time    <= (err == 1) ? 0 : (rcv_count == 32) ? 0    : ((time_done == 0) & (st_in)) ? in_time + 1 : in_time;
		time_done  <= (err == 1) ? 0 : (rcv_count == 32) ? 0    : ((time_done == 0) & (fall == 1)) ? 1 : time_done; 
	 end


endmodule