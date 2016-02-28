`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2016 19:15:37
// Design Name: 
// Module Name: ARINC429_testbench
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


module ARINC429_testbench();

    wire X0;
    wire X1;
    reg st;
    wire [7:0] adr;
    wire [22:0] dat;
    wire ce_wr;
    reg clk;
    reg [1:0] nvel;
    reg [7:0] adr1;
    reg [22:0] dat1;
    
    ARINC429 uut(
        .nvel(nvel),
        .adr(adr1),
        .dat(dat1),
        .GCLK(clk),
        .TXD0(X0),
        .TXD1(X1),
        .RXD0(X0),
        .RXD1(X1),
        .st(st),
        .sr_adr(adr),
        .sr_dat(dat),
        .ce_wr(ce_wr)
    );
    
    always
        begin
            clk = 0;
            #10;
            clk = 1;
            #10;
        end
        
        
    initial
        begin
            nvel = 2'd2;
            adr1 = 8'haf;
            dat1 = 22'habcde;
            st = 0;
            #95;
            st = 1;
            # 30;
            st = 0;
        end
    
endmodule
