`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2016 20:20:22
// Design Name: 
// Module Name: data_formatter
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


module data_formatter
    (
        input wire GCLK,
        input wire RST,
        input wire dec,
        input wire [7:0] temp_data_in,
        input wire [15:0] x_axis_in,
        input wire [15:0] y_axis_in,
        input wire [15:0] z_axis_in,
        output wire [15:0] x_axis_out,
        output wire [15:0] y_axis_out,
        output wire [15:0] z_axis_out,
        output wire [15:0] temp_data_out,
        //input wire tx_end,
        output wire [15:0] ang_x,
        output wire [15:0] ang_y,
        output wire [15:0] ang_z        
    );
    
    //---------------------------------------------------
    //           Clock for Pmod components
    //---------------------------------------------------
    wire dclk;
    display_clk C1(
                .clk(GCLK),
                .RST(RST),
                .dclk(dclk)
    );
    
	//---------------------------------------------------
    //         Formats data received from PmodGYRO
    //---------------------------------------------------

    data_controller C0_X(
                .clk(GCLK),
                .dclk(dclk),
                .rst(RST),
                .display_sel(dec),
                .sel(2'b00),
                .data(x_axis_in),
                .frmt(x_axis_out)
    );
    
    data_controller C0_Y(
                .clk(GCLK),
                .dclk(dclk),
                .rst(RST),
                .display_sel(dec),
                .sel(2'b01),
                .data(y_axis_in),
                .frmt(y_axis_out)
    );
    
    data_controller C0_Z(
                .clk(GCLK),
                .dclk(dclk),
                .rst(RST),
                .display_sel(dec),
                .sel(2'b10),
                .data(z_axis_in),
                .frmt(z_axis_out)
    );
    
    data_controller C0_T(
                .clk(GCLK),
                .dclk(dclk),
                .rst(RST),
                .display_sel(dec),
                .sel(2'b11),
                .data({8'd0, temp_data_in}),
                .frmt(temp_data_out)
    );
      
      
    reg [15:0] ax_acc = 0;
    reg [15:0] ay_acc = 0;
    reg [15:0] az_acc = 0;
    always @(ang_x) begin
        ax_acc <= RST ? 0 : ax_acc + ang_x;
    end
    
    data_controller C0_X_ACC(
                .clk(GCLK),
                .dclk(dclk),
                .rst(RST),
                .display_sel(dec),
                .sel(2'b00),
                .data(ax_acc),
                .frmt(ang_x)
    );    
    
                
endmodule
