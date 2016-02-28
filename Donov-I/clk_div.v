`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:00:27 04/14/2015 
// Design Name: 
// Module Name:    clk_div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div(
    input wire clk_in,
    output wire clk_out,
    input wire [7:0] div
    ); 

    reg [31:0] clk_cnt;

    always @ (posedge clk_in)
    begin
        clk_cnt <= clk_cnt + 32'b1;
    end

    assign clk_out = clk_cnt [div];

endmodule
