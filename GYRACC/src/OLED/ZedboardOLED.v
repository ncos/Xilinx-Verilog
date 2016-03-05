`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TAMUQ University 
// Engineers: Ali Aljaani 
// part of this work was contributed by Ryan Kim,and Josh Sackos as a demo for the PmodOLED/Nexys3 board By Digilent Inc.
//									  
// 
// Create Date:    06:13:25 08/18/2014
// Module Name:    ZedboardOLED_v1_0_S00_AXI 
// Project Name: 	 ZedboardOLED
// Target Devices: Zynq
// Tool versions:  Vivado 14.2 (64-bits)
// Description: The core is a slave AXI peripheral with 17 software-accessed registers.
// registers 0-16 are used for data, register 17 is the control register 
//
// Revision: 1.0 - ZedboardOLED_v1_0_S00_AXI completed
// Revision 0.01 - File Created 
//
//////////////////////////////////////////////////////////////////////////////////
	module ZedboardOLED
	(
	    //SPI Data In (MOSI)
        output  SDIN,
        //SPI Clock 
        output  SCLK,
        //Data_Command Control 
        output  DC,
        //Power Reset 
        output  RES,
        //Battery Voltage Control - connected to field-effect transistors-active low
        output  VBAT,
        // Logic Voltage Control - connected to field-effect transistors-active low 
        output  VDD,
        
        input wire CLK,
	    input wire [127:0] s1,
        input wire [127:0] s2,
        input wire [127:0] s3,
        input wire [127:0] s4,
        input wire clear,
        input wire refresh
    );

    //Current overall state of the state machine
    reg [143:0] current_state;
    //State to go to after the SPI transmission is finished
    reg [111:0] after_state;
    //State to go to after the set page sequence
    reg [142:0] after_page_state;
    //State to go to after sending the character sequence
    reg [95:0] after_char_state;
    //State to go to after the UpdateScreen is finished
    reg [39:0] after_update_state;
    
    //Variable that contains what the screen will be after the next UpdateScreen state
    reg [7:0] current_screen[0:3][0:15];
    
    //Variable assigned to the SSD1306 interface 
    reg temp_dc = 1'b0;
    reg temp_res = 1'b1;
    reg temp_vbat = 1'b1;
    reg temp_vdd = 1'b1;
    assign DC = temp_dc;
    assign RES = temp_res;
    assign VBAT = temp_vbat;
    assign VDD = temp_vdd;
    
   //-------------- Variables used in the Delay Controller Block --------------	
	wire [11:0] temp_delay_ms; //amount of ms to delay
	reg temp_delay_en = 1'b0;  //Enable signal for the delay block
	wire temp_delay_fin;       //Finish signal for the delay block
    assign temp_delay_ms = (after_state == "DispContrast1") ? 12'h074 : 12'h014;	
    
  //-------------- Variables used in the SPI controller block ----------------	
    reg temp_spi_en = 1'b0;     //Enable signal for the SPI block
    reg [7:0] temp_spi_data = 8'h00; //Data to be sent out on SPI
    wire temp_spi_fin; //Finish signal for the SPI block
    
  //-------------- Variables used in the characters libtray  ----------------	  
    reg [7:0] temp_char;				//Contains ASCII value for character
    reg [10:0] temp_addr;			//Contains address to BYTE needed in memory
    wire [7:0] temp_dout;			//Contains byte outputted from memory
    reg [1:0] temp_page;				//Current page
    reg [3:0] temp_index;			//Current character on page
    
  //-------------- Variables used in the reset and synchronization circuitry   ----------------	   
    reg init_first_r = 1'b1;    // Initilaize only one time 
    reg clear_screen_i = 1'b1;  // Clear the screen on start up
    reg ready = 1'b0;           // Ready flag
    reg RST_internal =1'b1;
    reg[11:0] count =12'h000;
    wire RST_IN;
    wire RST=1'b0; // dummy wire - can be connected as a port to provide external reset to the circuit 
    integer i = 0;
    integer j = 0;
    assign RST_IN = (RST || RST_internal);
  
  //--------------  Core commands assignments start ----------------	 
    
    reg Clear_c = 1'b0;
    reg Display_c = 1'b0;
    always @(posedge CLK) begin
        Clear_c <= clear;
        Display_c <= refresh;
    end
  
 //--------------  Core commands assignments end ---------------- 
 

	// ===========================================================================
	// 										Implementation
	// ===========================================================================

	SpiCtrl SPI_COMP(
			.CLK(CLK),
			.RST(RST_IN),
			.SPI_EN(temp_spi_en),
			.SPI_DATA(temp_spi_data),
			.SDO(SDIN),
			.SCLK(SCLK),
			.SPI_FIN(temp_spi_fin)
	);
	
	Delay DELAY_COMP(
			.CLK(CLK),
			.RST(RST_IN),
			.DELAY_MS(temp_delay_ms),
			.DELAY_EN(temp_delay_en),
			.DELAY_FIN(temp_delay_fin)
	);


    charLib CHAR_LIB_COMP(
			.clka(CLK),
			.addra(temp_addr),
			.douta(temp_dout)
	);

	// State Machine
	always @(posedge CLK) begin
			if(RST_IN == 1'b1) begin
					current_state <= "Idle";
					temp_res <= 1'b0;
			end
			else begin
					temp_res <= 1'b1;
					
					case(current_state)

							// Idle State
							"Idle" : begin
									if(init_first_r == 1'b1) begin
										temp_dc <= 1'b0; // DC= 0 "Commands" , DC=1 "Data" 
										current_state <= "VddOn";
										init_first_r <= 1'b0; // Don't go over the initialization more than once 
									end
									
									else begin
										current_state <="WaitRequest";
									end
							end

							// Initialization Sequence
							// This should be done only one time when Zedboard starts
							"VddOn" : begin // turn the power on the logic of the display 
								temp_vdd <= 1'b0; // remember the power FET transistor for VDD is active low
								current_state <= "Wait1";
							end

							// 3
							"Wait1" : begin
								after_state <= "DispOff";
								current_state <= "Transition3";
							end

							// 4
							"DispOff" : begin
								temp_spi_data <= 8'hAE; // 0xAE= Set Display OFF
								after_state <= "SetClockDiv1";
								current_state <= "Transition1";
							end
							
							// 5
							"SetClockDiv1" : begin  
								temp_spi_data <= 8'hD5; //0xD5
								after_state <= "SetClockDiv2";
								current_state <= "Transition1";
							end

							// 6
							"SetClockDiv2" : begin 
								temp_spi_data <= 8'h80; // 0x80
								after_state <= "MultiPlex1";
								current_state <= "Transition1";
							end
							
							// 7
							"MultiPlex1" : begin  
								temp_spi_data <= 8'hA8; //0xA8
								after_state <= "MultiPlex2";
								current_state <= "Transition1";
							end

							// 8
							"MultiPlex2" : begin 
								temp_spi_data <= 8'h1F; // 0x1F
								after_state <= "ChargePump1";
								current_state <= "Transition1";
							end

							// 9
							"ChargePump1" : begin  //  Access Charge Pump Setting
								temp_spi_data <= 8'h8D; //0x8D
								after_state <= "ChargePump2";
								current_state <= "Transition1";
							end

							// 10
							"ChargePump2" : begin //  Enable Charge Pump
								temp_spi_data <= 8'h14; // 0x14
								after_state <= "PreCharge1";
								current_state <= "Transition1";
							end

							// 11
							"PreCharge1" : begin // Access Pre-charge Period Setting
								temp_spi_data <= 8'hD9; // 0xD9
								after_state <= "PreCharge2";
								current_state <= "Transition1";
							end

							// 12
							"PreCharge2" : begin //Set the Pre-charge Period 
								temp_spi_data <= 8'hFF; // 0xF1
								after_state <= "VCOMH1";
								current_state <= "Transition1";
							end
							
							// 13
							"VCOMH1" : begin //Set the Pre-charge Period 
								temp_spi_data <= 8'hDB; // 0xF1
								after_state <= "VCOMH2";
								current_state <= "Transition1";
							end
							
							
							// 14
							"VCOMH2" : begin //Set the Pre-charge Period 
								temp_spi_data <= 8'h40; // 0xF1
								after_state <= "DispContrast1";
								current_state <= "Transition1";
							end


							// 15
							"DispContrast1" : begin //Set Contrast Control for BANK0
								temp_spi_data <= 8'h81; // 0x81
								after_state <= "DispContrast2";
								current_state <= "Transition1";
							end

							// 16
							"DispContrast2" : begin
								temp_spi_data <= 8'hF1; // 0x0F
								after_state <= "InvertDisp1";
								current_state <= "Transition1";
							end
							
							
							// 17
							"InvertDisp1" : begin
								temp_spi_data <= 8'hA0; // 0xA1
								after_state <= "InvertDisp2";
								current_state <= "Transition1";
							end

							// 18
							"InvertDisp2" : begin
								temp_spi_data <= 8'hC0; // 0xC0
								after_state <= "ComConfig1";
								current_state <= "Transition1";
							end

							// 19
							"ComConfig1" : begin
								temp_spi_data <= 8'hDA; // 0xDA
								after_state <= "ComConfig2";
								current_state <= "Transition1";
							end

							// 20
							"ComConfig2" : begin
								temp_spi_data <= 8'h02; // 0x02
								after_state <= "VbatOn";
								current_state <= "Transition1";
							end

							// 21
							
							"VbatOn" : begin
								temp_vbat <= 1'b0;
								current_state <= "Wait3";
							end
							
							// 22
							"Wait3" : begin
								after_state <= "ResetOn";
								current_state <= "Transition3";
							end
							
							// 23
							"ResetOn" : begin
								temp_res <= 1'b0;
								current_state <= "Wait2";
							end

							// 24							
							"Wait2" : begin
								after_state <= "ResetOff";
								current_state <= "Transition3";
							end
							
							// 25
							"ResetOff" : begin
								temp_res <= 1'b1;
								current_state <= "WaitRequest";
							end
						   // ************ END Initialization sequence but without turnning the dispay on ************

						  // Main state 	
							"WaitRequest" : begin
								if(Display_c == 1'b1) begin
									current_state <= "ClearDC";
									after_page_state <= "ReadRegisters";
									temp_page <= 2'b00;
								end
								else if ((Clear_c==1'b1) || (clear_screen_i == 1'b1)) begin
									
									current_state <= "ClearDC";
									after_page_state <= "ClearScreen";
									temp_page <= 2'b00;
								end
								
								else begin
									current_state<="WaitRequest"; // keep looping in the WaitRequest state untill you receive a command 
									
									if ((clear_screen_i == 1'b0) && (ready ==1'b0)) begin  // this part is only executed once, on start-up 
								        temp_spi_data <= 8'hAF; // 0xAF // Dispaly ON
										after_state <= "WaitRequest"; 
										current_state <= "Transition1";
									    temp_dc<=1'b0;
									    ready <= 1'b1;
									    //Display_c <= 1'b1;
									end
								end
							
							end
							
										
							//Update Page states
							//1. Sets DC to command mode
							//2. Sends the SetPage Command
							//3. Sends the Page to be set to
							//4. Sets the start pixel to the left column
							//5. Sets DC to data mode
							"ClearDC" : begin
									temp_dc <= 1'b0;
									current_state <= "SetPage";
							end
							
							"SetPage" : begin
									temp_spi_data <= 8'b00100010;
									after_state <= "PageNum";
									current_state <= "Transition1";
							end
							
							"PageNum" : begin
									temp_spi_data <= {6'b000000,temp_page};
									after_state <= "LeftColumn1";
									current_state <= "Transition1";
							end
							
							"LeftColumn1" : begin
									temp_spi_data <= 8'b00000000;
									after_state <= "LeftColumn2";
									current_state <= "Transition1";
							end
							
							"LeftColumn2" : begin
									temp_spi_data <= 8'b00010000;
									after_state <= "SetDC";
									current_state <= "Transition1";
							end
							
							"SetDC" : begin
									temp_dc <= 1'b1;
									current_state <= after_page_state;
							end

							"ClearScreen" : begin
									for(i = 0; i <= 3 ; i=i+1) begin
										for(j = 0; j <= 15 ; j=j+1) begin
												current_screen[i][j] <= 8'h20;
										end
									end
									after_update_state <= "WaitRequest";
									current_state <= "UpdateScreen";
							  end
							  
							  
							  "ReadRegisters" : begin
							  
							     // Page0
                                  current_screen[0][15]<=s1[7:0];
                                  current_screen[0][14]<=s1[15:8];
                                  current_screen[0][13]<=s1[23:16];
                                  current_screen[0][12]<=s1[31:24];                                      
                                  current_screen[0][11]<=s1[39:32];
                                  current_screen[0][10]<=s1[47:40];
                                  current_screen[0][9]<=s1[55:48];
                                  current_screen[0][8]<=s1[63:56];                                                                                              
                                  current_screen[0][7]<=s1[71:64];  
                                  current_screen[0][6]<=s1[79:72];  
                                  current_screen[0][5]<=s1[87:80];
                                  current_screen[0][4]<=s1[95:88];                                                    
                                  current_screen[0][3]<=s1[103:96];
                                  current_screen[0][2]<=s1[111:104]; 
                                  current_screen[0][1]<=s1[119:112];
                                  current_screen[0][0]<=s1[127:120];
                                  
                                  current_screen[1][15]<=s2[7:0];
                                  current_screen[1][14]<=s2[15:8];
                                  current_screen[1][13]<=s2[23:16];
                                  current_screen[1][12]<=s2[31:24];                                      
                                  current_screen[1][11]<=s2[39:32];
                                  current_screen[1][10]<=s2[47:40];
                                  current_screen[1][9]<=s2[55:48];
                                  current_screen[1][8]<=s2[63:56];                                                                                              
                                  current_screen[1][7]<=s2[71:64];  
                                  current_screen[1][6]<=s2[79:72];  
                                  current_screen[1][5]<=s2[87:80];
                                  current_screen[1][4]<=s2[95:88];                                                    
                                  current_screen[1][3]<=s2[103:96];
                                  current_screen[1][2]<=s2[111:104]; 
                                  current_screen[1][1]<=s2[119:112];
                                  current_screen[1][0]<=s2[127:120];
                                  
                                  current_screen[2][15]<=s3[7:0];
                                  current_screen[2][14]<=s3[15:8];
                                  current_screen[2][13]<=s3[23:16];
                                  current_screen[2][12]<=s3[31:24];                                      
                                  current_screen[2][11]<=s3[39:32];
                                  current_screen[2][10]<=s3[47:40];
                                  current_screen[2][9]<=s3[55:48];
                                  current_screen[2][8]<=s3[63:56];                                                                                              
                                  current_screen[2][7]<=s3[71:64];  
                                  current_screen[2][6]<=s3[79:72];  
                                  current_screen[2][5]<=s3[87:80];
                                  current_screen[2][4]<=s3[95:88];                                                    
                                  current_screen[2][3]<=s3[103:96];
                                  current_screen[2][2]<=s3[111:104]; 
                                  current_screen[2][1]<=s3[119:112];
                                  current_screen[2][0]<=s3[127:120];
                                  
                                  current_screen[3][15]<=s4[7:0];
                                  current_screen[3][14]<=s4[15:8];
                                  current_screen[3][13]<=s4[23:16];
                                  current_screen[3][12]<=s4[31:24];                                      
                                  current_screen[3][11]<=s4[39:32];
                                  current_screen[3][10]<=s4[47:40];
                                  current_screen[3][9]<=s4[55:48];
                                  current_screen[3][8]<=s4[63:56];                                                                                              
                                  current_screen[3][7]<=s4[71:64];  
                                  current_screen[3][6]<=s4[79:72];  
                                  current_screen[3][5]<=s4[87:80];
                                  current_screen[3][4]<=s4[95:88];                                                    
                                  current_screen[3][3]<=s4[103:96];
                                  current_screen[3][2]<=s4[111:104]; 
                                  current_screen[3][1]<=s4[119:112];
                                  current_screen[3][0]<=s4[127:120];
                                  
                                  after_update_state <= "WaitRequest";
                                  current_state <= "UpdateScreen";
                           end
							  
							//UpdateScreen State
							//1. Gets ASCII value from current_screen at the current page and the current spot of the page
							//2. If on the last character of the page transition update the page number, if on the last page(3)
							//			then the updateScreen go to "after_update_state" after
							"UpdateScreen" : begin

									temp_char <= current_screen[temp_page][temp_index];

									if(temp_index == 'd15) begin

										temp_index <= 'd0;
										temp_page <= temp_page + 1'b1;
										after_char_state <= "ClearDC";

										if(temp_page == 2'b11) begin
											after_page_state <= after_update_state;
											clear_screen_i<=1'b0;
										end
										else	begin
											after_page_state <= "UpdateScreen";
										end
									end
									else begin

										temp_index <= temp_index + 1'b1;
										after_char_state <= "UpdateScreen";

									end
									
									current_state <= "SendChar1";

							end							
														
							//Send Character States
							//1. Sets the Address to ASCII value of char with the counter appended to the end
							//2. Waits a clock for the data to get ready by going to ReadMem and ReadMem2 states
							//3. Send the byte of data given by the block Ram
							//4. Repeat 7 more times for the rest of the character bytes
							"SendChar1" : begin
									temp_addr <= {temp_char, 3'b000};
									after_state <= "SendChar2";
									current_state <= "ReadMem";
							end
							
							"SendChar2" : begin
									temp_addr <= {temp_char, 3'b001};
									after_state <= "SendChar3";
									current_state <= "ReadMem";
							end
							
							"SendChar3" : begin
									temp_addr <= {temp_char, 3'b010};
									after_state <= "SendChar4";
									current_state <= "ReadMem";
							end
							
							"SendChar4" : begin
									temp_addr <= {temp_char, 3'b011};
									after_state <= "SendChar5";
									current_state <= "ReadMem";
							end
							
							"SendChar5" : begin
									temp_addr <= {temp_char, 3'b100};
									after_state <= "SendChar6";
									current_state <= "ReadMem";
							end
							
							"SendChar6" : begin
									temp_addr <= {temp_char, 3'b101};
									after_state <= "SendChar7";
									current_state <= "ReadMem";
							end
							
							"SendChar7" : begin
									temp_addr <= {temp_char, 3'b110};
									after_state <= "SendChar8";
									current_state <= "ReadMem";
							end
							
							"SendChar8" : begin
									temp_addr <= {temp_char, 3'b111};
									after_state <= after_char_state;
									current_state <= "ReadMem";
							end
							
							"ReadMem" : begin
									current_state <= "ReadMem2";
							end

							"ReadMem2" : begin
									temp_spi_data <= temp_dout;
									current_state <= "Transition1";
							end
										

							// SPI transitions
							// 1. Set SPI_EN to 1
							// 2. Waits for SpiCtrl to finish
							// 3. Goes to clear state (Transition5)
							"Transition1" : begin
								temp_spi_en <= 1'b1;
								current_state <= "Transition2";
							end

							
							"Transition2" : begin
								if(temp_spi_fin == 1'b1) begin
									current_state <= "Transition5";
								end
							end

							// Delay Transitions
							// 1. Set DELAY_EN to 1
							// 2. Waits for Delay to finish
							// 3. Goes to Clear state (Transition5)	
							"Transition3" : begin
								temp_delay_en <= 1'b1;
								current_state <= "Transition4";
							end

							
							"Transition4" : begin
								if(temp_delay_fin == 1'b1) begin
									current_state <= "Transition5";
								end
							end

							// Clear transition
							// 1. Sets both DELAY_EN and SPI_EN to 0
							// 2. Go to after state
							"Transition5" : begin
								temp_spi_en <= 1'b0;
								temp_delay_en <= 1'b0;
								current_state <= after_state;
							end

							default : current_state <= "Idle";

					endcase
			end
	end
	
	    // Internal reset generator 
		always @(posedge CLK) begin
		if (RST_IN == 1'b1)
				count<=count+1'b1;
				if (count == 12'hFFF) begin
					RST_internal <=1'b0;
				end
		end

endmodule
