`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/23/2012
// Module Name:    Binary_To_BCD
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module receives a 9 bit binary value and converts it to
//					 a packed binary coded decimal (BCD) using the shift add 3
//					 algorithm.
//
//					 The output consists of 4 BCD digits as follows:
//
//								BCDOUT[15:12]	- Thousands place
//								BCDOUT[11:8]	- Hundreds place
//								BCDOUT[7:4]		- Tens place
//								BCDOUT[3:0]		- Ones place
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module Binary_To_BCD(
		CLK,
		RST,
		START,
		BIN,
		BCDOUT
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input            CLK;		// 100Mhz CLK
   input            RST;		//	Reset
   input            START;		//	Signal to initialize conversion
   input [8:0]      BIN;		//	Binary value to be converted
   output [15:0]     BCDOUT;		//	4 digit binary coded decimal output
   
   
// ====================================================================================
// 							  Parameters, Registers, and Wires
// ====================================================================================
   reg [15:0] BCDOUT;
	
	
   // Stores number of shifts executed
   reg [4:0]        shiftCount;
   // Temporary shift regsiter
   reg [27:0]       tmpSR;
   
   // FSM States
   parameter [2:0]  state_type_Idle = 0,
                    state_type_Init = 1,
                    state_type_Shift = 2,
                    state_type_Check = 3,
                    state_type_Done = 4;
   
   // Present state, Next State
   reg [2:0]        STATE;
   reg [2:0]        NSTATE;
   
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
   //------------------------------
   //		   State Register
   //------------------------------
   always @(posedge CLK or posedge RST)
   begin: STATE_REGISTER
      if (RST == 1'b1)
         STATE <= state_type_Idle;
      else 
         STATE <= NSTATE;
   end
   
   //------------------------------
   //		Output Logic/Assignment
   //------------------------------
   always @(posedge CLK or posedge RST)
   begin: OUTPUT_LOGIC
      if (RST == 1'b1) begin
         // Reset/clear values
         BCDOUT[11:0] <= 12'h000;
         tmpSR <= 28'h0000000;
      end      
      else
         case (STATE)
            
				// Idle State
            state_type_Idle : begin
                  BCDOUT <= BCDOUT;				// Output does not change
                  tmpSR <= 28'h0000000;		// Temp shift reg empty
            end
				
				// Init State
            state_type_Init : begin
                  BCDOUT <= BCDOUT;										// Output does not change
                  tmpSR <= {19'b0000000000000000000, BIN};		// Copy input to lower 9 bits
            end

				// Shift State
            state_type_Shift : begin
                  BCDOUT <= BCDOUT;						// Output does not change
                  tmpSR <= {tmpSR[26:0], 1'b0};		// Shift left 1 bit
                  
                  shiftCount <= shiftCount + 1'b1;	// Count the shift
            end
				// Check State
            state_type_Check : begin
                  BCDOUT <= BCDOUT;		// Output does not change
                  
                  // Not done converting
                  if (shiftCount != 4'hC)
                  begin
                     
                     // Add 3 to thousands place
                     if (tmpSR[27:24] >= 4'h5)
                        tmpSR[27:24] <= tmpSR[27:24] + 4'h3;
                     
                     // Add 3 to hundreds place
                     if (tmpSR[23:20] >= 4'h5)
                        tmpSR[23:20] <= tmpSR[23:20] + 4'h3;
                     
                     // Add 3 to tens place
                     if (tmpSR[19:16] >= 4'h5)
                        tmpSR[19:16] <= tmpSR[19:16] + 4'h3;
                     
                     // Add 3 to ones place
                     if (tmpSR[15:12] >= 4'h5)
                        tmpSR[15:12] <= tmpSR[15:12] + 4'h3;
                  end
            end
            
				// Done State
            state_type_Done :
               begin
                  BCDOUT[11:0] <= tmpSR[23:12];		// Assign output the new BCD values
                  tmpSR <= 28'h0000000;				// Clear temp shift register
                  shiftCount <= 5'b00000;				// Clear shift count
               end
         endcase
   end
   
   //------------------------------
   //		  Next State Logic
   //------------------------------
   always @(START or shiftCount or STATE)
   begin: NEXT_STATE_LOGIC

      // Define default state to avoid latches
      NSTATE <= state_type_Idle;
      
      case (STATE)
			
			// Idle State
         state_type_Idle :
            if (START == 1'b1)
               NSTATE <= state_type_Init;
            else
               NSTATE <= state_type_Idle;

			// Init State
         state_type_Init :
            NSTATE <= state_type_Shift;

			// Shift State
         state_type_Shift :
            NSTATE <= state_type_Check;

			// Check State
         state_type_Check :
            if (shiftCount != 4'hC)
               NSTATE <= state_type_Shift;
            else
               NSTATE <= state_type_Done;

			// Done State
         state_type_Done :
            NSTATE <= state_type_Idle;

			// Default State
         default : NSTATE <= state_type_Idle;
      endcase
   end
   
endmodule
