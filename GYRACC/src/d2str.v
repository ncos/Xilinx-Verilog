`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2016 13:08:19
// Design Name: 
// Module Name: d2str
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


module D2STR_B#
    (
    parameter integer len = 16 // Symbols to show
    )
    (
        output wire [127:0] str,
        input wire [len-1:0] d
    );
    genvar i;
    generate
    for (i = 0; i < len; i = i + 1) begin
        assign str[8*i+7:8*i] = d[i]? "1" : "0";
    end
    for (i = len; i < 16; i = i + 1) begin
        assign str[8*i+7:8*i] = " ";
    end
    endgenerate
endmodule


module D2STR_H#
    (
    parameter integer len = 16 // Symbols to show
    )
    (
        input wire GCLK,
        output reg [127:0] str = "????????????????",
        input wire [4*len-1:0] d
    );
    
    genvar i;
    generate
    for (i = 0; i < len; i = i + 1) begin: test
        always @(posedge GCLK) begin
            case (d[4*i+3:4*i])
            4'd0: str[8*i+7:8*i] <= "0";
            4'd1: str[8*i+7:8*i] <= "1";
            4'd2: str[8*i+7:8*i] <= "2";
            4'd3: str[8*i+7:8*i] <= "3";
            4'd4: str[8*i+7:8*i] <= "4";
            4'd5: str[8*i+7:8*i] <= "5";
            4'd6: str[8*i+7:8*i] <= "6";
            4'd7: str[8*i+7:8*i] <= "7";
            4'd8: str[8*i+7:8*i] <= "8";
            4'd9: str[8*i+7:8*i] <= "9";
            4'd10: str[8*i+7:8*i] <= "A";
            4'd11: str[8*i+7:8*i] <= "B";
            4'd12: str[8*i+7:8*i] <= "C";
            4'd13: str[8*i+7:8*i] <= "D";
            4'd14: str[8*i+7:8*i] <= "E";
            4'd15: str[8*i+7:8*i] <= "F";
            default: str[8*i+7:8*i] <= " ";
            endcase            
        end
    end
    for (i = len; i < 16; i = i + 1) begin
        always @(posedge GCLK) begin
            str[8*i+7:8*i] <= " ";
        end
    end
    endgenerate

endmodule



module D2STR_D#
    (
    parameter integer len = 4 // Symbols to show
    )
    (
        input wire GCLK,
        output reg [127:0] str = "????????????????",
        input wire [4*len-1:0] d
    );
    
    genvar i;
    generate
    for (i = 0; i < len; i = i + 1) begin: test
        always @(posedge GCLK) begin
            case (d[4*i+3:4*i])
            4'd0: str[8*i+7:8*i] <= "0";
            4'd1: str[8*i+7:8*i] <= "1";
            4'd2: str[8*i+7:8*i] <= "2";
            4'd3: str[8*i+7:8*i] <= "3";
            4'd4: str[8*i+7:8*i] <= "4";
            4'd5: str[8*i+7:8*i] <= "5";
            4'd6: str[8*i+7:8*i] <= "6";
            4'd7: str[8*i+7:8*i] <= "7";
            4'd8: str[8*i+7:8*i] <= "8";
            4'd9: str[8*i+7:8*i] <= "9";
            4'd10: str[8*i+7:8*i] <= " ";
            4'd11: str[8*i+7:8*i] <= " ";
            4'd12: str[8*i+7:8*i] <= " ";
            4'd13: str[8*i+7:8*i] <= " ";
            4'd14: str[8*i+7:8*i] <= " ";
            4'd15: str[8*i+7:8*i] <= "-";
            default: str[8*i+7:8*i] <= " ";
            endcase            
        end
    end
    for (i = len; i < 16; i = i + 1) begin
        always @(posedge GCLK) begin
            str[8*i+7:8*i] <= " ";
        end
    end
    endgenerate

endmodule




