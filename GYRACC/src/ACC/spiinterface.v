`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
//				 Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    SPIinterface
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module involves the control of the SPI interface with three 
//				 	 processes including the reception of data, the transmission of data,
//					 and finally the production of the serial data clock used in the SPI
//					 interface.
//
// 	 Inputs:
//			transmit 			Signal from SPImaster	
//			txbuffer 			Transmission Buffer, holds signal from SPImaster
//			rst					User input RESET
//			clk 					100 MHz clock signal
//			sdi 					Serial Data In from ACL
//		
//  	Outputs:
//			rxbuffer 			Recieve Buffer, holds signal from sdi
//			done_out 				signal that goes to SPImaster signalling end of Transmission
//			sdo 					Serial Data Out to ACL
//			sclk 					Serial Clock out to ACL
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added comments and modified code (Josh Sackos)
////////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module SPIinterface(
		txbuffer,
		rxbuffer,
		transmit,
		done_out,
		sdi, sdo,
		rst, clk,
		sclk
);
   
// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input            clk;
   input            rst;
   input            transmit;
   input            sdi;
	input [15:0]     txbuffer;
   output [7:0]     rxbuffer;
   output           done_out;
   output           sdo;
   output           sclk;
   
   
// ====================================================================================
// 							  Parameters, Registers, and Wires
// ====================================================================================
	wire             sclk;
	wire             done_out;
   reg              sdo;
	wire [7:0]		  rxbuffer;
   
   parameter [7:0]  CLKDIVIDER = 8'hFF;		//leads to sclk of about 98kHz

   parameter [1:0]  TxType_idle = 0,
                    TxType_transmitting = 1;

   parameter [1:0]  RxType_idle = 0,
                    RxType_recieving = 1;

   parameter [1:0]  SCLKType_idle = 0,
                    SCLKType_running = 1;
						  
   reg [7:0]        clk_count = 7'd0;
   reg              clk_edge_buffer = 1'd0;
   
   reg              sck_previous = 1'b1;
   reg              sck_buffer = 1'b1;
   
   reg [15:0]       tx_shift_register = 16'h0000;
   reg [3:0]        tx_count = 4'h0;
   reg [7:0]        rx_shift_register = 8'h00;
   reg [3:0]        rx_count = 4'h0;

   reg              done = 1'b0;
   reg [1:0]        TxSTATE = TxType_idle;
   reg [1:0]        RxSTATE = RxType_idle;
   reg [1:0]        SCLKSTATE = SCLKType_idle;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
		//-------------------------------------------------------------------------
		//		 			 			 Transmission Controller
		//-------------------------------------------------------------------------
		always @(posedge clk)
		begin: TxProcess
			//Reset state
			
			begin
				if (rst == 1'b1)
				begin
					tx_shift_register <= 16'd0;
					tx_count <= 4'd0;
					sdo <= 1'b1;
					TxSTATE <= TxType_idle;
				end
				else
					case (TxSTATE)
						//when idle, if transmit goes high, then the state goes into 
						//transmitting. during idle state, sdo is held high
						TxType_idle :
							begin
								tx_shift_register <= txbuffer;
								//sdo<='1';
								if (transmit == 1'b1)
									TxSTATE <= TxType_transmitting;
								else if (done == 1'b1)
									sdo <= 1'b1;
							end
						TxType_transmitting :
							if (sck_previous == 1'b1 & sck_buffer == 1'b0)
							begin
								//when count is 15, then cycles out to idle state again. 
								//otherwise, the TxData is shifted out on the falling edge
								//of the serial clock
								if (tx_count == 4'b1111) begin
									TxSTATE <= TxType_idle;
									tx_count <= 4'd0;
									sdo <= tx_shift_register[15];
								end
								else begin
									tx_count <= tx_count + 4'b0001;
									sdo <= tx_shift_register[15];
									tx_shift_register <= {tx_shift_register[14:0], 1'b0};
								end
							end
					endcase
			end
		end
		
		//-------------------------------------------------------------------------
		//		 			 			  Reception Controller
		//-------------------------------------------------------------------------
		always @(posedge clk)
		begin: RxProcess
			//Reset state
			
			begin
				if (rst == 1'b1)
				begin
					rx_shift_register <= 8'h00;
					rx_count <= 4'h0;
					done <= 1'b0;
					RxSTATE <= RxType_idle;
				end
				else
					case (RxSTATE)
						RxType_idle :
							//when transmit goes high from the SPImaster, the state
							//goes to recieving and rx_shift_register is zeroed
							if (transmit == 1'b1)
							begin
								RxSTATE <= RxType_recieving;
								rx_shift_register <= 8'h00;
							end
							else if (SCLKSTATE == RxType_idle)
								done <= 1'b0;
						RxType_recieving :
							if (sck_previous == 1'b0 & sck_buffer == 1'b1)
							begin
								//sdi is sampled on the rising edge and after the 16 rising edge, 
								//the state goes back to idle and done is asserted
								if (rx_count == 4'b1111)
								begin
									RxSTATE <= RxType_idle;
									rx_count <= 4'd0;
									rx_shift_register <= {rx_shift_register[6:0], sdi};
									done <= 1'b1;
								end
								else
								begin
									rx_count <= rx_count + 4'd1;
									rx_shift_register <= {rx_shift_register[6:0], sdi};
								end
							end
					endcase
			end
		end
		
		//-------------------------------------------------------------------------
		//		 			 					Serial Clock
		//-------------------------------------------------------------------------
		always @(posedge clk)
		begin: SCLKgen
			//Reset State with SCK held high      
			begin
				if (rst == 1'b1)
				begin
					clk_count <= 8'h00;
					SCLKSTATE <= SCLKType_idle;
					sck_previous <= 1'b1;
					sck_buffer <= 1'b1;
				end
				else
					case (SCLKSTATE)
						SCLKType_idle :
							begin
								sck_previous <= 1'b1;
								sck_buffer <= 1'b1;
								clk_count <= 8'h00;
								clk_edge_buffer <= 1'b0;
								
								//when transmit is high, the state goes to running
								if (transmit == 1'b1)
								begin
									SCLKSTATE <= SCLKType_running;
								end
							end
						SCLKType_running :
							//when done is high, the state goes back to idle
							if (done == 1'b1) begin
								SCLKSTATE <= SCLKType_idle;
							end
							//if done is nto asserted, the clock continues to be 
							//generated
							else if (clk_count == CLKDIVIDER) begin
								if (clk_edge_buffer == 1'b0) begin
									sck_buffer <= 1'b1;
									clk_edge_buffer <= 1'b1;
								end
								else begin
									sck_buffer <= (~sck_buffer);
									clk_count <= 8'h00;
								end
							end
							else begin
								sck_previous <= sck_buffer;
								clk_count <= clk_count + 1'b1;
							end
					endcase
			end
		end
		
		//-------------------------------------------------------------------------
		//		 			 					Assign Outputs
		//-------------------------------------------------------------------------
		//The rxbuffer is tied to the rx_shift_register and is ouput to the SPImaster
		assign rxbuffer = rx_shift_register;
		//the signal SCK is tied to the output sclk
		assign sclk = sck_buffer;
		//done_out, to the SPImaster, is tied to the signal done produced in the recieving state machine
		assign done_out = done;
   
endmodule


