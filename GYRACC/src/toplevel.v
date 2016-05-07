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
    
    inout wire JB1;
    inout wire JB2;
    inout wire JB3;
    inout wire JB4;
    inout wire JB7;
    inout wire JB8;
    inout wire JB9;
    inout wire JB10;

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

    wire [15:0]  temp_data;
    wire [15:0]  x_axis_data;
    wire [15:0]  y_axis_data;
    wire [15:0]  z_axis_data;

    PmodGYRO GYRO_0
        (
        .clk(GCLK),
        .RST(BTND),
        .JA({JA4, JA3, JA2, JA1}),      
        .temp_data(temp_data),
        .x_axis_data(x_axis_data),
        .y_axis_data(y_axis_data),
        .z_axis_data(z_axis_data)
        );
  
    wire ready;
    reg [3:0] tr_count = 0;
    reg [7:0] tr_data = 0;
    reg prev_ready = 0;
    
    UART_TX uart_tx 
        (
        .clk(GCLK),
        .data_in(tr_data),
        .out(JB1),
        .start(1'b1),
        .reset(~BTNU),
        .ready(ready)
        );  
  
    always @(posedge GCLK) begin
        tr_count <= ready && ~prev_ready ? (tr_count == 11 ? 0 : tr_count + 4'd1) : tr_count;
        prev_ready <= ready;
        tr_data <= x_axis_data [7:0];
        case (tr_count)
            4'd0: begin
                tr_data <= x_axis_data [7:0];
            end
            4'd1: begin
                tr_data <= x_axis_data [15:8];
            end
            4'd2: begin
                tr_data <= y_axis_data [7:0];
            end
            4'd3: begin
                tr_data <= y_axis_data [15:8];
            end
            4'd4: begin
                tr_data <= z_axis_data [7:0];
            end
            4'd5: begin
                tr_data <= z_axis_data [15:8];
            end
            default: begin
                tr_data <= 8'b01010101;
            end
        endcase
    end
endmodule