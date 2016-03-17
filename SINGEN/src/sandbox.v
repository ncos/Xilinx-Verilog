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
    
    reg SS_REG = 1'b0;
    reg SCLK_REG = 1'b0;
    assign JA[2] = SS_REG;
    assign JA[3] = SCLK_REG;
    
    always @(posedge GCLK) begin
        SS_REG <= SS;
        SCLK_REG <= SCLK;
    end
    
    //assign JA[3] = SCLK;
   
    SPI #(.m(15), .Tbit(100)) spi
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
        //.MASTER_MISO(MISO),
        //.MASTER_MOSI(MOSI),
        .MASTER_SS(SS),
        .MASTER_SCLK(SCLK),
        .MASTER_MISO(JB[0]),
        .MASTER_MOSI(JA[1]),
        //.MASTER_SS(JA[2]),
        //.MASTER_SCLK(JA[3]),
        // SPI Slave bus
        //.SLAVE_MISO(MISO),
        //.SLAVE_MOSI(MOSI),
        .SLAVE_SS(SS),
        .SLAVE_SCLK(SCLK),
        .SLAVE_MOSI(JB[1]),
        .SLAVE_MISO(JA[0])
        //.SLAVE_SS(JB[2])
        //.SLAVE_SCLK(JB[3])
        );

endmodule
