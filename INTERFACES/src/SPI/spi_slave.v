`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 16:25:28
// Design Name: 
// Module Name: SPI_SLAVE
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


module SPI_SLAVE#
    (
    parameter integer m = 15 // Data packet size
    )
    (
    input wire RST,
    input wire SCLK,
    output wire MISO,
    input wire MOSI,
    input wire SS,
    input wire [m-1:0] DIN,
    output reg [m-1:0] DOUT
    );
    
    reg [m-1:0] RXSHIFT = 0;
    reg [m-1:0] TXSHIFT = 0;

    assign MISO = TXSHIFT[m-1];

    always @(negedge SS) begin
        TXSHIFT <= DIN;
    end

    always @(negedge SCLK) begin
        TXSHIFT <= TXSHIFT<<1;
    end
    
    always @(posedge SS) begin
        DOUT <= RXSHIFT;
        RXSHIFT <= 0;
    end
    
    always @(posedge SCLK) begin
        RXSHIFT <= RXSHIFT<<1 | MOSI;
    end
endmodule