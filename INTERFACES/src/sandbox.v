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
    output reg [127:0] OLED_S0,
    output reg [127:0] OLED_S1,
    output reg [127:0] OLED_S2,
    output reg [127:0] OLED_S3,
    input wire GCLK,
    output reg [7:0] LD,
    input wire [7:0] SW,
    inout wire [7:0] JA,
    output reg [7:0] JB,
    input wire BTNC,
    input wire BTND,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU
    );
    
    parameter integer WIDTH = 128;  // Packet width
    parameter integer QUANTA = 39;  // Level hold time
    parameter integer SP = 30;      // Sample point

    reg [WIDTH-1:0] DIN1 = "DIN1 -> DOUT2";
    reg [WIDTH-1:0] DIN2 = "DIN2 -> DOUT1";
    wire [WIDTH-1:0] DOUT1;
    wire [WIDTH-1:0] DOUT2;

    wire tx_ready1;
    wire rx_ready1;
    wire tx_ready2;
    wire rx_ready2;
    

    reg start = 1'b0;
    reg RES = 1'b0;
    always @(posedge GCLK) begin
        start <= BTNC;
        RES <= BTND;
    end

    can_controller#
    (
        .WIDTH(WIDTH),
        .QUANTA(QUANTA),
        .SP(SP)
    ) CC1
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(JA[0]),
        .DIN(DIN1),
        .DOUT(DOUT1),
        .tx_start(start),
        .tx_ready(tx_ready1),
        .rx_ready(rx_ready1)
    );

    can_controller#
    (
        .WIDTH(WIDTH),
        .QUANTA(QUANTA),
        .SP(SP)
    ) CC2
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(JA[1]),
        .DIN(DIN2),
        .DOUT(DOUT2),
        .tx_start(start),
        .tx_ready(tx_ready2),
        .rx_ready(rx_ready2)
    );    
       
    CLK_DIV clk_div
    (
        .GCLK(GCLK),
        .out(clk_Tbit),
        .T(100)
    );
    
    always @(posedge clk_Tbit) begin
        OLED_S0 <= "CAN Interface   ";
        OLED_S1 <= {DOUT1}; 
        OLED_S2 <= {DOUT2};
        OLED_S3 <= "CAN Interface   ";
        LD[0] <= tx_ready1;
        LD[1] <= rx_ready1;
        LD[2] <= tx_ready2;
        LD[3] <= rx_ready2;
    end    
    
endmodule
