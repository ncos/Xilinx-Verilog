`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2016 08:56:07
// Design Name: 
// Module Name: clk_div
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


module CLK_DIV
    (
    input wire GCLK,
    output reg out = 1'b0,
    input wire [63:0] T
    );
    
    reg [63:0] cnt = 64'd0;
    always @(posedge GCLK) begin
        if (cnt == 64'd0) begin
            cnt <= T;
            out <= ~out;
        end
        else begin
            cnt <= cnt - 64'd1;
        end
    
    end
endmodule
