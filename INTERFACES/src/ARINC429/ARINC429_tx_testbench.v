`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 18:12:16
// Design Name: 
// Module Name: ARINC429txtestbench
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


module ARINC429_tx_testbench ();
    
    reg clk;
    reg ce;
        AR_TXD TX(
        .clk(clk), 
        .Nvel(2'd2), 
        .ADR(8'h8D), 
        .DAT(23'h702D00), 
        .st(ce), 
        .TXD0(TXD0),           //                0
        .TXD1(TXD1)           //                1
        
    /*    output wire ce,             //          (Tce=1/Vel)
        output wire SLP,            //                 
        output reg en_tx =0,        //                         
        output wire T_cp,           //                       
        output reg FT_cp=0,         //                          
        output wire SDAT,           //                        
        output reg QM=0,            //          
        output reg[5:0]cb_bit=0,    //           
        output reg en_tx_word=0     //                       */
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
                ce = 0;
                #95;
                ce = 1;
                # 30;
                ce=0;
            end
endmodule