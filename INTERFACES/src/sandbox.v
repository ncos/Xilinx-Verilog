`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 14:56:48
// Design Name: 
// Module Name: sandbox
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


module sandbox
    (
    output wire [127:0] OLED_S0,
    output wire [127:0] OLED_S1,
    output wire [127:0] OLED_S2,
    output wire [127:0] OLED_S3,
    input wire GCLK,
    output wire [7:0] LD,
    input wire [7:0] SW,
    inout wire [7:0] JA,
    inout wire [7:0] JB,
    input wire BTNC,
    input wire BTND,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU
    );

    reg [107:0] DIN1;
    reg [107:0] DIN2;
    wire [107:0] DOUT1;
    wire [107:0] DOUT2;

    reg tx_start1;
    wire tx_ready1;
    wire rx_ready1;
    reg tx_start2;
    wire tx_ready2;
    wire rx_ready2;

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
        .DIN(DIN1),
        .DOUT(DOUT1),
        .tx_start(tx_start1),
        .tx_ready(tx_ready1),
        .rx_ready(rx_ready1)
    );    
    
    
    
endmodule
