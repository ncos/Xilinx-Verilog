`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2016 23:02:44
// Design Name: 
// Module Name: can_controller_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module can_controller_testbench();
    reg GCLK;
    reg RES;
    wire CAN;
    reg [107:0] DIN1;
    wire [107:0] DOUT1;
    reg tx_start1;
    wire tx_ready1;
    wire rx_ready1;
    reg [107:0] DIN2;
    wire [107:0] DOUT2;
    reg tx_start2;
    wire tx_ready2;
    wire rx_ready2;

    pullup(CAN);
        
    always
        #10 GCLK = ~GCLK;
      
    
    initial
 begin
        GCLK = 1'b0;
        RES = 1'b0;
        #20
        DIN1 = "HI";
        DIN2 = "LOL";
        #100
        tx_start1 = 1'b1;
        tx_start2 = 1'b1;
        #46000
        tx_start1 = 1'b0;
        tx_start2 = 1'b0;
        #100000
        $finish;
    end

    can_controller CC1
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(CAN),
        .DIN(DIN1),
        .DOUT(DOUT1),
        .tx_start(tx_start1),
        .tx_ready(tx_ready1),
        .rx_ready(rx_ready1)
    );
    
    can_controller CC2
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(CAN),
        .DIN(DIN2),
        .DOUT(DOUT2),
        .tx_start(tx_start2),
        .tx_ready(tx_ready2),
        .rx_ready(rx_ready2)
    );
endmodule