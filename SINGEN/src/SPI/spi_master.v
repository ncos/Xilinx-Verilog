`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 16:25:28
// Design Name: 
// Module Name: SPI_MASTER
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


module SPI_MASTER#    
    (
    parameter integer m = 15 // Data packet size
    )
    (
    input clk,
    input wire RST,
    output reg EN_TX=0,
    input ce, 
    output wire LOAD,
    input st, 
    output wire SCLK,
    input MISO, 
    output wire MOSI,
    input [m-1:0] TX_MD,
    output reg [m-1:0] RX_SD=0,
    input LEFT,
    output wire CEfront,
    output wire CEspad
    );
    reg [m-1:0] MQ=0 ; //Регистр сдвига выходных данных MASTER-а
    reg [m-1:0] MRX=0 ; //Регистр сдвига входных данных MASTER-а
    reg ss = 0;
    reg [5:0] T_del = 0;
    reg [3:0] cb_bit=0; //Счетчик бит
    assign MOSI = LEFT ? MQ[m-1] : MQ[0] ; // Выходные данные MASTER-а
    assign LOAD = !EN_TX; // Интервал передачи/приема
    
    assign SCLK = EN_TX & ce;
    
    reg st_buf = 1'b0;
    always @(posedge ce) begin
        if (!EN_TX & st) begin
            st_buf <= 1'b1;
        end
        else begin
            st_buf <= 1'b0;
        end
    end
    
    always @(negedge ce) begin
        MQ <= st_buf? TX_MD : LEFT ? MQ<<1 : MQ>>1;
        EN_TX <= (cb_bit == (m-1))? 0 : st_buf? 1'b1 : EN_TX;
        cb_bit <= st_buf? 0 : cb_bit + 4'd1 ;
    end
    
    reg wready = 1'b0;
    always @(posedge ce) begin
        MRX <= (EN_TX == 1'b1) ? MRX<<1 | MISO : 0;
        if (RST == 1'b1) begin
            RX_SD <= 0;
            wready <= 1'b0;
        end
        else if (EN_TX == 1'b0) begin
            if (wready == 1'b0) begin
                RX_SD <= MRX;
            end
            wready <= 1'b1;
        end
        else begin
            wready <= 1'b0;
            RX_SD <= RX_SD;
        end
    end
    
    //always @(posedge LOAD) begin
        
    //end
    
endmodule