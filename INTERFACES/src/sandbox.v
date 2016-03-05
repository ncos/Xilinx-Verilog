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


module sandbox#
    (
    parameter integer Tbit = 100 // Clocks
    )
    (
    output reg [127:0] OLED_S0,
    output reg [127:0] OLED_S1,
    output reg [127:0] OLED_S2,
    output reg [127:0] OLED_S3,
    input wire GCLK,
    output reg [7:0] LD,
    input wire [7:0] SW,
    inout wire [7:0] JA,
    inout wire [7:0] JB,
    input wire BTNC,
    input wire BTND,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU
    );

    reg [107:0] DIN1 = "HI";
    reg [107:0] DIN2 = "LOL";
    wire [107:0] DOUT1;
    wire [107:0] DOUT2;

    wire tx_ready1;
    wire rx_ready1;
    wire tx_ready2;
    wire rx_ready2;

    can_controller CC1
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(JA[0]),
        .DIN(DIN1),
        .DOUT(DOUT1),
        .tx_start(BTNC),
        .tx_ready(tx_ready1),
        .rx_ready(rx_ready1)
    );

    can_controller CC2
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(JA[1]),
        .DIN(DIN2),
        .DOUT(DOUT2),
        .tx_start(BTNC),
        .tx_ready(tx_ready2),
        .rx_ready(rx_ready2)
    );    
       
    CLK_DIV clk_div
    (
        .GCLK(GCLK),
        .out(clk_Tbit),
        .T(Tbit)
    );
    always @(posedge clk_Tbit) begin
            OLED_S0 <= "CAN Interface   ";
            OLED_S1 <= {DOUT1,20'd0}; 
            OLED_S2 <= {DOUT2,20'd0};
            OLED_S3 <= "CAN Interface   ";
            LD[0] <= tx_ready1;
            LD[1] <= rx_ready1;
            LD[2] <= tx_ready2;
            LD[3] <= rx_ready2;
    end    
    
endmodule
