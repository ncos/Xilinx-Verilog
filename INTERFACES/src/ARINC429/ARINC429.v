`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 16:25:28
// Design Name: 
// Module Name: ARINC429
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


module ARINC429(
    input wire [1 : 0] nvel,
    input wire [7 : 0] adr,
    input wire [22 : 0] dat,
    input wire GCLK,
    output wire TXD0,
    output wire TXD1,
    input wire RXD0,
    input wire RXD1,
    input wire st,
    output reg [7:0] sr_adr,
    output reg [22:0] sr_dat,
    output reg ce_wr,
    input wire rec_disp, // reciever dispatcher
    input wire reset
    );
    
   
    AR_TXD TX
        (
        .clk(GCLK), 
        .Nvel(nvel), 
        .ADR(adr), 
        .DAT(dat), 
        .st(st), 
        .TXD0(TXD0),
        .TXD1(TXD1),
        .reset(reset)
        );
        
    wire [7:0] sr_adr_1;
    wire [22:0] sr_dat_1;
    wire ce_wr_1;
    AR_RXD RX
        (
        .clk(GCLK),
        .in0(RXD0),
        .in1(RXD1),
        .sr_dat(sr_dat_1),
        .sr_adr(sr_adr_1),
        .ce_wr(ce_wr_1)
        );

    wire [7:0] sr_adr_2;
    wire [22:0] sr_dat_2;
    wire ce_wr_2;
    AR_RXD_2 RX_2
        (
        .clk(GCLK),
        .in0(RXD0),
        .in1(RXD1),
        .sr_dat(sr_dat_2),
        .sr_adr(sr_adr_2),
        .ce_wr(ce_wr_2)
        );
        
    always @(posedge GCLK) 
    begin
        sr_dat <= rec_disp ? sr_dat_1 : sr_dat_2;
        sr_adr <= rec_disp ? sr_adr_1 : sr_adr_2;
        ce_wr <= rec_disp ? ce_wr_1 : ce_wr_2;
    end

endmodule
