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
    
    reg [127:0] str0;
    reg [127:0] str1;
    reg [127:0] str2;
    reg [127:0] str3;

    assign OLED_S0 = str0;
    assign OLED_S1 = str1;
    assign OLED_S2 = str2;
    assign OLED_S3 = str3;
   
   
    always @(posedge GCLK) begin
        str0 <= "SPI interface";
        str1 <= ".";
        str2 <= ".";
        str3 <= "----------------";
    end

endmodule
