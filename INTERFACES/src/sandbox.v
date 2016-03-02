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
    output wire [7:0] JA,
    input wire [7:0] JB,
    input wire BTNC,
    input wire BTND,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU
    );
    
    wire MISO;
    wire MOSI;
    wire SS;
    wire SCLK;
   
    SPI spi
        (
        // External interfaces
        .str0(OLED_S0),
        .str1(OLED_S1),
        .str2(OLED_S2),
        .str3(OLED_S3),
        .GCLK(GCLK),
        .RST(BTND),
        .SW(SW),
        // Transmission start switch
        .st(BTNC),
        // SPI Master bus
        .MASTER_MISO(MISO),
        .MASTER_MOSI(MOSI),
        .MASTER_SS(SS),
        .MASTER_SCLK(SCLK),
        // SPI Slave bus
        .SLAVE_MOSI(MOSI),
        .SLAVE_MISO(MISO),
        .SLAVE_SS(SS),
        .SLAVE_SCLK(SCLK)
        );

endmodule
