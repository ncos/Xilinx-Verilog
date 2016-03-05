`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
//				 Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    SPImaster
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: The spi_master controls the state of the entire interface. Using 
//					 several signals to interact with the other modules. The spi_master
//					 selects the data to be transmitted and stores all data received
//					 from the PmodACL.  The data is then made available to the rest of
//					 the design on the xAxis, yAxis, and zAxis outputs.
//
//
//  Inputs:
//		rst							Device Reset Signal
//		clk 							Base system clock of 100 MHz
//		start 						start tied to external user input
//		done 							Signal from SPIinterface for completed transmission
//		rxdata 						Recieved data
//		
//  Outputs:
//		transmit 					Signal to SPIinterface for beginning of transmission
//		txdata						Data out for transmission
//		x_axis_data 				Collected x-Axis data
//		y_axis_data 				Collected y-Axis data
//		z_axis_data 				Collected z-Axis data
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added comments and modified code (Josh Sackos)
////////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module SPImaster(
		rst,
		clk,
		start,
		rxdata,
		done,
		transmit,
		txdata,
		x_axis_data,
		y_axis_data,
		z_axis_data
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
	input            rst;
   input            clk;
   input            start;
   input [7:0]      rxdata;
   input            done;
   output           transmit;
   output [15:0]    txdata;
   output [9:0]     x_axis_data;
   output [9:0]     y_axis_data;
   output [9:0]     z_axis_data;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   reg [15:0]       txdata;
   reg [9:0]        x_axis_data;
   reg [9:0]        y_axis_data;
   reg [9:0]        z_axis_data;
   reg              transmit;

   // Define FSM states
   parameter [2:0]  state_type_idle = 3'd0,
                    state_type_configure = 3'd1,
                    state_type_transmitting = 3'd2,
                    state_type_recieving = 3'd3,
                    state_type_finished = 3'd4,
                    state_type_break = 3'd5,
                    state_type_holding = 3'd6;
   // STATE reg
   reg [2:0]        STATE;
   
   parameter [1:0]  data_type_x_axis = 2'd0,
                    data_type_y_axis = 2'd1,
                    data_type_z_axis = 2'd2;
   reg [1:0]        DATA;
   
   parameter [1:0]  configure_type_powerCtl = 0,
                    configure_type_bwRate = 1,
                    configure_type_dataFormat = 2;
   reg [1:0]        CONFIGUREsel;
   
   //Setting up Configuration Registers
   //POWER_CTL Bits 0x2D
   parameter [15:0] POWER_CTL = 16'h2D08;
   //BW_RATE Bits 0x2C
   parameter [15:0] BW_RATE = 16'h2C08;
   //CONFIG Bits 0x31
   parameter [15:0] DATA_FORMAT = 16'h3100;
   
   //Axis registers set to only read and do it in single byte increments
   parameter [15:0] xAxis0 = 16'hB200;		//10110010;
   parameter [15:0] xAxis1 = 16'hB300;		//10110011;
   parameter [15:0] yAxis0 = 16'hB400;		//10110100;
   parameter [15:0] yAxis1 = 16'hB500;		//10110101;
   parameter [15:0] zAxis0 = 16'hB600;		//10110110;
   parameter [15:0] zAxis1 = 16'hB700;		//10110111;
   
   reg [11:0]       break_count;
   reg [20:0]       hold_count;
   reg              end_configure;
   reg              done_configure;
   reg              register_select;
   reg              finish;
   reg              sample_done;
   reg [3:0]        prevstart;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
   
		//-----------------------------------------------
		//						Master Controller
		//-----------------------------------------------
		always @(posedge clk)
		begin: spi_masterProcess
			begin
				// Debounce Start Button
				prevstart <= {prevstart[2:0], start};
				//Reset Condition
				if (rst == 1'b1) begin
					transmit <= 1'b0;
					STATE <= state_type_idle;
					DATA <= data_type_x_axis;
					break_count <= 12'h000;
					hold_count <= 21'b000000000000000000000;
					done_configure <= 1'b0;
					CONFIGUREsel <= configure_type_powerCtl;
					txdata <= 16'h0000;
					register_select <= 1'b0;
					sample_done <= 1'b0;
					finish <= 1'b0;
					x_axis_data <= 10'b0000000000;
					y_axis_data <= 10'b0000000000;
					z_axis_data <= 10'b0000000000;
					end_configure <= 1'b0;
				end
				else
					//Main State, selects what the overall system is doing
					case (STATE)
						state_type_idle :
							//If the system has not been configured, enter the configure state
							if (done_configure == 1'b0) begin
								STATE <= state_type_configure;
								txdata <= POWER_CTL;
								transmit <= 1'b1;
							end
							//If the system has been configured, enter the transmission state when start is asserted
							else if (prevstart == 4'b0011 & start == 1'b1 & done_configure == 1'b1) begin
								STATE <= state_type_transmitting;
								finish <= 1'b0;
								txdata <= xAxis0;
								sample_done <= 1'b0;
							end
						state_type_configure :
							//Substate of configure selects what configuration is output
							case (CONFIGUREsel)
								//Send power control address with desired configuration bits
								configure_type_powerCtl : begin
										STATE <= state_type_finished;
										CONFIGUREsel <= configure_type_bwRate;
										transmit <= 1'b1;
									end
								//Send band width rate address with desired configuration bits
								configure_type_bwRate : begin
										txdata <= BW_RATE;
										STATE <= state_type_finished;
										CONFIGUREsel <= configure_type_dataFormat;
										transmit <= 1'b1;
									end
								//Send data format address with desired configuration bits
								configure_type_dataFormat : begin
										txdata <= DATA_FORMAT;
										STATE <= state_type_finished;
										transmit <= 1'b1;
										finish <= 1'b1;
										end_configure <= 1'b1;
									end
								default :
									;
							endcase
						
						//transmitting leads to the transmission of addresses of data to sample them
						state_type_transmitting :
							//Substate of transmitting selects which data register will be sampled
							case (DATA)
								//Selects the x_axis data
								data_type_x_axis :
									//register_select chooses which of the two registers for each axis 
									//will be sampled
									case (register_select)
										1'b0 :
											begin
												//in each case for data and register_select the state goes to 
												//recieving to accept data from SPIinterface and transmit goes
												//high to begin the transmission of data to the ACL
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
										default :
											begin
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
									endcase
								data_type_y_axis :
									case (register_select)
										1'b0 :
											begin
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
										default :
											begin
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
									endcase
								data_type_z_axis :
									case (register_select)
										1'b0 :
											begin
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
										default :
											begin
												STATE <= state_type_recieving;
												transmit <= 1'b1;
											end
									endcase
								default :
									;
							endcase
						
						//recieving controls the flow of data into the spi_master
						state_type_recieving :
							//Substate of Recieving, DATA controls where data will be stored
							case (DATA)
								//Substate of DATA same as in transmitting
								data_type_x_axis :
									//register_select controls which half of the output register the 
									//collected data goes to
									case (register_select)
										1'b0 :
											begin
												//transmit de-asserted as transmission has already be begun
												transmit <= 1'b0;
												//when done is asserted, the register to be sampled next
												//changes with txdata, data is assigned to the desired output,
												//the overall state goes to finish, and register select is 
												//inverted to go to the other half. this same purpose is used
												//throughout DATA in recieving
												if (done == 1'b1)
												begin
													txdata <= xAxis1;
													x_axis_data[7:0] <= rxdata[7:0];
													STATE <= state_type_finished;
													register_select <= 1'b1;
												end
											end
										default :
											begin
												transmit <= 1'b0;
												if (done == 1'b1)
												begin
													txdata <= yAxis0;
													x_axis_data[9:8] <= rxdata[1:0];
													register_select <= 1'b0;
													DATA <= data_type_y_axis;
													STATE <= state_type_finished;
												end
											end
									endcase
								data_type_y_axis :
									case (register_select)
										1'b0 :
											begin
												transmit <= 1'b0;
												if (done == 1'b1)
												begin
													txdata <= yAxis1;
													y_axis_data[7:0] <= rxdata[7:0];
													register_select <= 1'b1;
													STATE <= state_type_finished;
												end
											end
										default :
											begin
												transmit <= 1'b0;
												if (done == 1'b1)
												begin
													txdata <= zAxis0;
													y_axis_data[9:8] <= rxdata[1:0];
													register_select <= 1'b0;
													DATA <= data_type_z_axis;
													STATE <= state_type_finished;
												end
											end
									endcase
								data_type_z_axis :
									case (register_select)
										1'b0 :
											begin
												transmit <= 1'b0;
												if (done == 1'b1)
												begin
													txdata <= zAxis1;
													z_axis_data[7:0] <= rxdata[7:0];
													register_select <= 1'b1;
													STATE <= state_type_finished;
												end
											end
										default :
											begin
												transmit <= 1'b0;
												if (done == 1'b1)
												begin
													txdata <= xAxis0;
													z_axis_data[9:8] <= rxdata[1:0];
													register_select <= 1'b0;
													DATA <= data_type_x_axis;
													STATE <= state_type_finished;
													sample_done <= 1'b1;
												end
											end
									endcase
								default :
									;
							endcase
						
						//finished leads to the break state when transmission completed
						state_type_finished :
							begin
								transmit <= 1'b0;
								if (done == 1'b1)
								begin
									STATE <= state_type_break;
									if (end_configure == 1'b1)
										done_configure <= 1'b1;
								end
							end
						
						//the break state keeps an idle state long enough between transmissions 
						//to satisfy timing requirements. break can be decreased if desired
						state_type_break :
							if (break_count == 12'hFFF)
							begin
								break_count <= 12'h000;
								//only exit to idle if start has been de-asserted ( to keep from 
								//looping transmitting and recieving undesirably ) and finish and 
								//sample_done are high showing that the desired action has been 
								//completed
								if ((finish == 1'b1 | sample_done == 1'b1) & start == 1'b0)
								begin
									STATE <= state_type_idle;
									txdata <= xAxis0;
								end
								//if done configure is high, and sample done is low, the reception
								//has not been completed so the state goes back to transmitting
								else if (sample_done == 1'b1 & start == 1'b1)
									STATE <= state_type_holding;
								else if (done_configure == 1'b1 & sample_done == 1'b0)
								begin
									STATE <= state_type_transmitting;
									transmit <= 1'b1;
								end
								//if the system has not finished configuration, then the state loops
								//back to configure
								else if (done_configure == 1'b0)
									STATE <= state_type_configure;
							end
							else
								break_count <= break_count + 1'b1;
						state_type_holding :
							if (hold_count == 24'h1FFFFF)
							begin
								hold_count <= 21'd0;
								STATE <= state_type_transmitting;
								sample_done <= 1'b0;
							end
							else if (start <= 1'b0)
							begin
								STATE <= state_type_idle;
								hold_count <= 21'd0;
							end
							else begin
								hold_count <= hold_count + 1'b1;
							end
					endcase
			end
		end
   
endmodule

