`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 16:25:28
// Design Name: 
// Module Name: SPI
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


module SPI#
    (
    parameter integer m = 15, // Data packet size
    parameter integer Tbit = 100 // Clocks for 1 bit
    )
    (
    // External interfaces
    output reg [127:0] str0 = "                ",
    output reg [127:0] str1 = "                ",
    output reg [127:0] str2 = "                ",
    output reg [127:0] str3 = "                ",
    input wire GCLK,
    input wire RST,
    input wire [7:0] SW,
    // Transmission start switch
    input wire st,
    // SPI Master bus
    input wire MASTER_MISO,
    output wire MASTER_MOSI,
    output wire MASTER_SS,
    output wire MASTER_SCLK,
    // SPI Slave bus
    input wire SLAVE_MOSI,
    output wire SLAVE_MISO,
    input wire SLAVE_SS,
    input wire SLAVE_SCLK
    );
    
    // I/O buffers
    wire [m-1:0] MASTER_RX;
    reg [m-1:0] MASTER_TX = 15'b010110000110110;
    wire [m-1:0] SLAVE_RX;
    reg [m-1:0] SLAVE_TX = 15'b110101100110110;
    
    wire clk_Tbit; // Clock for bit timing
    
    SPI_MASTER #(.m(m)) spi_master
        (
        .clk(GCLK),
        .ce(clk_Tbit),
        .st(st),
        .SCLK(MASTER_SCLK),
        .MISO(MASTER_MISO),
        .MOSI(MASTER_MOSI),
        .LOAD(MASTER_SS),
        .TX_MD(MASTER_TX),
        .RX_SD(MASTER_RX),
        .RST(RST),
        .LEFT(1'b1),
        .R(1'b1)
        );

    SPI_SLAVE #(.m(m)) spi_slave 
        (
        .GCLK(GCLK),
        .RST(RST),
        .SCLK(SLAVE_SCLK),
        .MISO(SLAVE_MISO),
        .MOSI(SLAVE_MOSI),
        .SS(SLAVE_SS),
        .DIN(SLAVE_TX),
        .DOUT(SLAVE_RX)
        );
   
    CLK_DIV clk_div
        (
        .GCLK(GCLK),
        .out(clk_Tbit),
        .T(Tbit)
        );
        
    // Display
    wire [127:0] str_m_tx;
    wire [127:0] str_s_tx;
    wire [127:0] str_m_rx;
    wire [127:0] str_s_rx;

    always @(posedge clk_Tbit) begin
        if (SW[6] == 1'b1) begin
            str0 <= "SPI Interface   ";
            str1 <= SW[7] ? " M-R TX/SLAVE RX" : " SLAVE TX/M-R RX";
            str2 <= SW[7] ? str_m_tx : str_s_tx;
            str3 <= SW[7] ? str_s_rx : str_m_rx;
        end
    end
    
    D2STR_B #(.len(m)) oled_d2b_0
        (
        .str(str_m_tx),
        .d(MASTER_TX)
        );
       
    D2STR_B #(.len(m)) oled_d2b_1
        (
        .str(str_s_tx),
        .d(SLAVE_TX)
        );   
   
    D2STR_B #(.len(m)) oled_d2b_2
        (
        .str(str_m_rx),
        .d(MASTER_RX)
        );   
    
    D2STR_B #(.len(m)) oled_d2b_3
        (
        .str(str_s_rx),
        .d(SLAVE_RX)
        );  
endmodule