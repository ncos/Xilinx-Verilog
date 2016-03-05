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

    inout wire JA1;
    inout wire JA2;
    inout wire JA3;
    inout wire JA4;
    inout wire JA7;
    inout wire JA8;
    inout wire JA9;
    inout wire JA10;    
    
    input wire JB1;
    input wire JB2;
    input wire JB3;
    input wire JB4;
    input wire JB7;
    input wire JB8;
    input wire JB9;
    input wire JB10;

    input wire BTNC;
    input wire BTND;
    input wire BTNL;
    input wire BTNR;
    input wire BTNU;

    output wire DC;
    output wire RES;
    output wire SCLK;
    output wire SDIN;
    output wire VBAT;
    output wire VDD;

    input wire SW0;
    input wire SW1;
    input wire SW2;
    input wire SW3;
    input wire SW4;
    input wire SW5;
    input wire SW6;
    input wire SW7;
    
    output wire LD0;
    output wire LD1;
    output wire LD2;
    output wire LD3;
    output wire LD4;
    output wire LD5;
    output wire LD6;
    output wire LD7;

    reg [127:0] str0 = "----------------";
    reg [127:0] str1 = "----------------";
    reg [127:0] str2 = "----------------";
    reg [127:0] str3 = "----------------";

    reg oled_ready = 1'b0;
    assign LD7 = oled_ready;
    ZedboardOLED OLED
        (
        .clear(BTND),
        .refresh(oled_ready),
        .s1(str0),
        .s2(str1),
        .s3(str2),
        .s4(str3),
        .DC(DC),
        .RES(RES),
        .SCLK(SCLK),
        .SDIN(SDIN),
        .VBAT(VBAT),
        .VDD(VDD),
        .CLK(GCLK)
        );
  
    wire [15:0]  temp_data;
    wire [15:0]  x_axis_data;
    wire [15:0]  y_axis_data;
    wire [15:0]  z_axis_data;
    wire [15:0]  ang_x;

    PmodGYRO GYRO_0
        (
        .sw({SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0}),
        .clk(GCLK),
        .JA({JA4, JA3, JA2, JA1}),      
        .temp_data_out(temp_data),
        .x_axis_out(x_axis_data),
        .y_axis_out(y_axis_data),
        .z_axis_out(z_axis_data),
        .ang_x(ang_x)
        );
  
    wire [127:0] w_str_x;
    wire [127:0] w_str_y;
    wire [127:0] w_str_z;
    wire [127:0] w_str_t;
    wire [127:0] w_str_ax;


    D2STR_D#(.len(4)) d2str0
        (
            .GCLK(GCLK),
            .str(w_str_x),
            .d(x_axis_data)
        );
    D2STR_D#(.len(4)) d2str1
        (
            .GCLK(GCLK),
            .str(w_str_y),
            .d(y_axis_data)
        );  
    D2STR_D#(.len(4)) d2str2
        (
            .GCLK(GCLK),
            .str(w_str_z),
            .d(z_axis_data)
        );  
    D2STR_D#(.len(4)) d2str3
        (
            .GCLK(GCLK),
            .str(w_str_t),
            .d(temp_data)
        );

    D2STR_D#(.len(4)) d2str4
        (
            .GCLK(GCLK),
            .str(w_str_ax),
            .d(ang_x)
        );


    
    wire oled_refresh_clk;
    CLK_DIV oled_refresh_clk 
        (
        .GCLK(GCLK),
        .out(oled_refresh_clk),
        .T(64'd3333333)
        );
        
    always @(posedge GCLK) begin
        if (BTNC) begin
            oled_ready <= 1'b1;
        end
    end
    
    always @(posedge oled_refresh_clk) begin
        str0 <= w_str_x;
        str1 <= w_str_y;
        str2 <= w_str_z;
        str3 <= w_str_t;
    end
endmodule