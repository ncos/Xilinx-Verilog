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
    output wire JA1;
    output wire JA2;
    output wire JA3;
    output wire JA4;
    output wire JA7;
    output wire JA8;
    output wire JA9;
    output wire JA10;
    input wire JB1;
    input wire JB2;
    input wire JB3;
    input wire JB4;
    input wire JB7;
    input wire JB8;
    input wire JB9;
    input wire JB10;
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




sandbox SANDBOX
        (
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