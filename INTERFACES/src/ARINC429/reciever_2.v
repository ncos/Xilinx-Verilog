`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:02:31 02/17/2016 
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
module AR_RXD_2(
	input clk, 
	input	wire in1, //Импульсы канала 1
	input wire in0, //Импульсы канала 0
	output [7:0] sr_adr, 
	output [22:0]sr_dat,
	output wire ce_wr);

reg [31:0] tmp_buf = 32'd0;
reg [31:0] out_buf = 32'd0;
assign sr_adr = out_buf [31:24];
genvar i;
generate
for (i = 0; i <= 22 ; i = i + 1) 
begin: data_loop
	assign sr_dat[i] = out_buf [23 - i];
end
endgenerate
assign par_bit = out_buf [0];

reg [1:0] Nvel = 3;

parameter Fclk = 50000000 ; //50 MHz
parameter V1Mb = 1000000 ; // 1000 kb/s
parameter V100kb = 100000 ; // 100 kb/s
parameter V50kb = 50000 ; // 50 kb/s
parameter V12_5kb = 12500 ; // 12.5 kb/s

wire [10:0]AR_Nt = (Nvel [1:0] == 3)? (Fclk / (2 * V1Mb)) : //1000.000 kb/s
						 (Nvel [1:0] == 2)? (Fclk / (2 * V100kb)) : // 100.000 kb/s
					    (Nvel [1:0] == 1)? (Fclk / (2 * V50kb)) : // 50.000 kb/s
						 (Fclk / (2 * V12_5kb)); // 12.500 kb/s

reg [10:0] cb_tce = 0; // Счетчик такта
wire ce_tact = (cb_tce == AR_Nt); // Tce_tact=1/(2*VEL)

parameter WaitNextData = 0;
parameter RecData = 1;
parameter WaitPos = 2;
parameter WaitNeg = 3;
parameter Done = 4;
parameter Clear = 5;
reg [2:0] cur_state = WaitNextData;
reg clr_before_next = 0;

reg act_par_bit = 0;
reg ok_check = 0;
assign ce_wr = ok_check;
reg [5:0] rec_bit_num = 0;
parameter MaxTimeOut = 20;
reg [3:0] time_out = 0;

always @(posedge clk)
begin
	if (cur_state == WaitNextData) 
	begin
		cur_state <= (in1 | in0) ? Clear : WaitNextData;
		clr_before_next <= 1;
		cb_tce <= 0;
		time_out <= 0;
	end
	else 
	begin
		cb_tce <= (ce_tact) ? 1 : cb_tce + 1;
	end
	
	if (cur_state == WaitPos)
	begin
		time_out <= ce_tact ? time_out : time_out + 1;
		cur_state <= (time_out > MaxTimeOut) ? Clear : (rec_bit_num == 32) ? Done : (in1 | in0) ? RecData : WaitPos;
	end
	else if (cur_state == RecData)
	begin
		tmp_buf <= in1 ? (tmp_buf << 1 | 1) : in0 ? (tmp_buf << 1) : tmp_buf;
		act_par_bit <= act_par_bit ^ in1;
		rec_bit_num <= rec_bit_num + 1;
		time_out <= 0;
		cur_state <= WaitNeg;
	end
	else if (cur_state ==  WaitNeg)
	begin 
		cur_state <= (!in1 & !in0) ? WaitPos : WaitNeg;
	end
	else if (cur_state ==  Done)
	begin
		out_buf <= tmp_buf;
		ok_check <= act_par_bit;
		cur_state <= WaitNextData;
	end
	else if (cur_state == Clear)
	begin
		tmp_buf <= 0;
		out_buf <= 0;
		act_par_bit <= 0;
		ok_check <= 0;
		rec_bit_num <= 0;
		time_out <= 0;
		cur_state <= clr_before_next ? WaitPos : WaitNextData;
	end
end

endmodule
