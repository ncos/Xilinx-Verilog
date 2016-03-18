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
    
    wire SS;
    wire SCLK;
    
    reg SS_REG = 1'b0;
    reg SCLK_REG = 1'b0;
    reg LDAC_REG = 1'b1;
    reg MOSI_REG = 1'b0;
    reg GCLK;
    reg snd; 
    reg set;
    reg LEFT;
    reg RST;
    wire LDAC;
    wire LCLK;
    wire pulse;
    
    reg [11:0] TX = 12'd0;
    reg cstate = 0;
    reg ostate = 0;
    
    assign JA[1] = SS_REG;
    assign JA[2] = SCLK_REG;
    assign JA[3] = MOSI_REG;
    assign JA[4] = LDAC_REG;
    assign JA[5] = LCLK;
    assign JA[6] = pulse;
    assign JA[7] = set;
    
    always @(posedge GCLK) begin
        SS_REG <= SS;
        SCLK_REG <= SCLK;
        MOSI_REG <= MOSI;
        LDAC_REG <= LDAC;
        set <= pulse;
        snd <= pulse;
    end
    
    always @(posedge LCLK) begin
        TX <= 16'd771;
    end    
    

        DAC dac
            (
            .CLK(GCLK),
            .DIV(64'd1000),
            .DATA(TX),
            .SEND(snd),
            .SET(set),
            .SCK(SCLK),
            .MOSI(MOSI),
            .CS(SS),
            .LDAC(LDAC)
            );
        
        CLK_DIV clk_div
            (
            .GCLK(GCLK),
            .out(LCLK),
            .T(64'd100000),
            .PULSE(pulse)
            );        
            
        MEMORY memory
            (
            .ADDR(10'd123),
            .CLK(GCLK),
            .RE(1'b1),
            .INIT(1'b1)
            );
        
endmodule
