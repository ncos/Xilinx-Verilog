`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2016 18:21:15
// Design Name: 
// Module Name: toplevelv
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

module toplevel
    (
    GCLK,
    DC,
    RES,
    SCLK,
    SDIN,
    VBAT,
    VDD,
    JA1,
    JA2,
    JA3,
    JA4,
    JA7,
    JA8,
    JA9,
    JA10,
    JB1,
    JB2,
    JB3,
    JB4,
    JB7,
    JB8,
    JB9,
    JB10,
    SW0,
    SW1,
    SW2,
    SW3,
    SW4,
    SW5,
    SW6,
    SW7,
    BTNC,
    BTND,
    BTNL,
    BTNR,
    BTNU,
    LD0,
    LD1,
    LD2,
    LD3,
    LD4,
    LD5,
    LD6,
    LD7
    );

    input wire GCLK;
    output wire DC;
    output wire RES;
    output wire SCLK;
    output wire SDIN;
    output wire VBAT;
    output wire VDD;
    inout wire JA1;
    inout wire JA2;
    inout wire JA3;
    inout wire JA4;
    inout wire JA7;
    inout wire JA8;
    inout wire JA9;
    inout wire JA10;
    output wire JB1;
    output wire JB2;
    output wire JB3;
    output wire JB4;
    output wire JB7;
    output wire JB8;
    output wire JB9;
    output wire JB10;
    input wire SW0;
    input wire SW1;
    input wire SW2;
    input wire SW3;
    input wire SW4;
    input wire SW5;
    input wire SW6;
    input wire SW7;
    input wire BTNC;
    input wire BTND;
    input wire BTNL;
    input wire BTNR;
    input wire BTNU;
    output wire LD0;
    output wire LD1;
    output wire LD2;
    output wire LD3;
    output wire LD4;
    output wire LD5;
    output wire LD6;
    output wire LD7;



wire [127:0] s1;
wire [127:0] s2;
wire [127:0] s3;
wire [127:0] s4;
ZedboardOLED OLED
        (
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4),
        .DC(DC),
        .RES(RES),
        .SCLK(SCLK),
        .SDIN(SDIN),
        .VBAT(VBAT),
        .VDD(VDD),
        .CLK(GCLK)
        );

sandbox SANDBOX
        (
        .OLED_S0(s1),
        .OLED_S1(s2),
        .OLED_S2(s3),
        .OLED_S3(s4),
        .GCLK(GCLK),
        .LD({LD7, LD6, LD5, LD4, LD3, LD2, LD1, LD0}),
        .SW({SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0}),
        .JA({JA10, JA9, JA8, JA7, JA4, JA3, JA2, JA1}),
        .JB({JB10, JB9, JB8, JB7, JB4, JB3, JB2, JB1}),
        .BTNC(BTNC),
        .BTND(BTND),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNU(BTNU)
        );
        
endmodule