`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:04:20 04/14/2015 
// Design Name: 
// Module Name:    toplevel_pl 
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
module toplevel_pl(
    output reg [7:0] JA,
    output reg [7:0] JB,
    inout [7:0] JC,
    inout [7:0] JD,
    output reg [7:0] led,
    input [7:0] sw,
    input BTNL,
    input BTNR,
    input BTNU,
    input BTND,
    input BTNC,
    input GCLK
    );
    
    wire clk;
    clk_div cdiv (
        .clk_in(GCLK),
        .clk_out(clk),
        .div(8'd15)
        );
       
    reg [7:0] sw_reg;
    wire [7:0] digit_data;
    wire [4:0] digit_select;
    always @(posedge GCLK)
    begin 
        sw_reg <= sw;
        led <= sw;
        JA <= digit_data;
        JB <= {3'd0, digit_select[4], 
                     digit_select[0],
                     digit_select[1],
                     digit_select[2],
                     digit_select[3]};
    end
    
    
    digital_display_4 (
        .data({16'h1234}),
        .format_select(BTNC), // 0 = hex, 1 = decimal
        .digit(digit_data),
        .select(digit_select[3:0]),
        .clk(clk)
        ); 

    
        
            
endmodule
