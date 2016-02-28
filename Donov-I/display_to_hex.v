`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:08 04/19/2015 
// Design Name: 
// Module Name:    display_to_hex 
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
module display_to_hex(
    input [15:0] number,
    output [31:0] result
    );
    bin2digit b2d1 (
        .number(number[3:0]),
        .result(result[7:0])
        );
    bin2digit b2d2 (
        .number(number[7:4]),
        .result(result[15:8])
        );
    bin2digit b2d3 (
        .number(number[11:8]),
        .result(result[23:16])
        );
    bin2digit b2d4 (
        .number(number[15:12]),
        .result(result[31:24])
        );
endmodule


module bin2digit(
    input [3:0] number,
    output [7:0] result
    );
    
    assign result = (number == 4'd0)  ? 8'b00000011: // 0
                    (number == 4'd1)  ? 8'b10011111: // 1
                    (number == 4'd2)  ? 8'b00100101: // 2
                    (number == 4'd3)  ? 8'b00001101: // 3
                    (number == 4'd4)  ? 8'b10011001: // 4
                    (number == 4'd5)  ? 8'b01001001: // 5
                    (number == 4'd6)  ? 8'b01000001: // 6
                    (number == 4'd7)  ? 8'b00011111: // 7
                    (number == 4'd8)  ? 8'b00000001: // 8
                    (number == 4'd9)  ? 8'b00001001: // 9
                    (number == 4'd10) ? 8'b00010001: // A
                    (number == 4'd11) ? 8'b00000000: // B
                    (number == 4'd12) ? 8'b01100011: // C
                    (number == 4'd13) ? 8'b00000010: // D
                    (number == 4'd14) ? 8'b01100001: // E
                    8'b01110001;                     // F
    
endmodule
