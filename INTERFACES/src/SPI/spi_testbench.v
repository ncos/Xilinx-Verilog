`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2016 19:15:37
// Design Name: 
// Module Name: SPI_testbench
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


module SPI_testbench();
    parameter integer m = 15;
    reg GCLK;
    reg st;
    reg LEFT;
    reg R;
    reg RST;
    wire MISO;
    wire MOSI;
    wire SS;
    wire SCLK;
    
    // I/O buffers
    wire [m-1:0] MASTER_RX;
    reg [m-1:0] MASTER_TX = 15'b010110000110110;
    wire [m-1:0] SLAVE_RX;
    reg [m-1:0] SLAVE_TX = 15'b110101100110110;
    
    wire clk_Tbit; // Clock for bit timing
        
    SPI_MASTER spi_master
        (
        .clk(GCLK),
        .ce(clk_Tbit),
        .st(st),
        .SCLK(SCLK),
        .MISO(MISO),
        .MOSI(MOSI),
        .LOAD(SS),
        .TX_MD(MASTER_TX),
        .RX_SD(MASTER_RX),
        .LEFT(LEFT),
        .R(R)
        );
    
    SPI_SLAVE spi_slave 
        (
        .RST(RST),
        .SCLK(SCLK),
        .MISO(MISO),
        .MOSI(MOSI),
        .SS(SS),
        .DIN(SLAVE_TX),
        .DOUT(SLAVE_RX)
        );
    
    CLK_DIV clk_div
        (
        .GCLK(GCLK),
        .out(clk_Tbit),
        .T(64'd10)
        );
    
    always begin
        GCLK = 1'b0;
        #10;
        GCLK = 1'b1;
        #10;
    end
    
    initial begin
        GCLK = 1'b0;
        st = 1'b0;
        LEFT = 1'b1;
        R = 1'b0;
        RST = 1'b0;
        #100
        st = 1'b1;
        #200
        st = 1'b0;
        #10000
        $finish;
    end
endmodule