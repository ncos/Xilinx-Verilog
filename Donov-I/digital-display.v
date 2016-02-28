`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:42:54 04/15/2015 
// Design Name: 
// Module Name:    digital_display_4 
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
module digital_display_4(
    input [15:0] data,
    input format_select, // 0 = hex, 1 = decimal
    output reg [7:0] digit,
    output reg [3:0] select,
    input clk
    );
    
    reg [31:0] data_reg_formatted;
    wire [31:0] data_formatted_dec;
    wire [31:0] data_formatted_hex;
    
    always @(posedge clk)
    begin
        if (format_select == 1'b0) data_reg_formatted <= data_formatted_hex;
        if (format_select == 1'b1) data_reg_formatted <= data_formatted_dec;
    end

    // separate clock for each digit
    always @(posedge clk)
    begin
        select <= select << 1;
        if (select == 0) select <= 4'b1;
        if (select == 4'b0001)
            digit <= data_reg_formatted[7:0];
        if (select == 4'b0010)
            digit <= data_reg_formatted[15:8];    
        if (select == 4'b0100)
            digit <= data_reg_formatted[23:16];
        if (select == 4'b1000)
            digit <= data_reg_formatted[31:24];    
    end

    // get formatted data from plain number
    display_to_dec d2dec(
        .number(data),
        .result(data_formatted_dec)
        );
    display_to_hex d2hex(
        .number(data),
        .result(data_formatted_hex)
        );

endmodule
