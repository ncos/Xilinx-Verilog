`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Andrew Skreen
//				 Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    slaveSelect
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: A simple module involving the switching of the slave select line
//					 during transmission and idle states. 
//
//  Inputs:
//		rst 					User input Reset
//		transmit 			signal from SPImaster causing ss line to go low
//								( enable )
//		done 					signal from SPIinterface causing ss line to go 
//								high ( disable )
//
//  Outputs:
//		ss 					ss output to ACL
//
// Revision History: 
// 						Revision 0.01 - File Created (Andrew Skreen)
//							Revision 1.00 - Added comments and modified code (Josh Sackos)
////////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module slaveSelect(
		rst,
		clk,
		transmit,
		done,
		ss
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input   rst;
   input   clk;
   input   transmit;
   input   done;
   output  ss;
   reg     ss = 1'b1;
   
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
   
		//-----------------------------------------------
		//			  Generates Slave Select Signal
		//-----------------------------------------------
		always @(posedge clk)
		begin: ssprocess
			
			begin
				//reset state, ss goes high ( disabled )
				if (rst == 1'b1)
					ss <= 1'b1;
				//if transmitting, then ss goes low ( enabled )
				else if (transmit == 1'b1)
					ss <= 1'b0;
				//if done, then ss goes high ( disabled )
				else if (done == 1'b1)
					ss <= 1'b1;
			end
		end
   
endmodule


