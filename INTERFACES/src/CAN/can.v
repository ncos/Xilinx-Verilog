`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 18:40:36
// Design Name: 
// Module Name: can
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


module can
    (
    input wire GCLK,
    inout wire CANH,
    inout wire CANL,
    input wire RES,
    // Input queue
    input wire [107:0] tx_q,
    input wire tx_q_push,
    output wire tx_q_ovf,
    // Output qeue
    output reg [107:0] rx_q,
    input wire rx_q_pull,
    output wire rx_q_ovf
    );
    
    assign CANL = ~CANH;
    
    reg [107:0] to_transmit_buf;
    reg [107:0] to_receive_buf;

    wire refresh_tx;
    wire refresh_rx;
    
    queue Q_TX (
        .GCLK(GCLK),
        .RES(RES),
        .get(refresh_tx),
        .put(tx_q_push),
        .full(tx_q_ovf),
        .DIN(tx_q),
        .DOUT(to_transmit_buf)
    );
    
    queue Q_RX (
        .GCLK(GCLK),
        .RES(RES),
        .get(rx_q_pull),
        .put(refresh_rx),
        .full(rx_q_ovf),
        .DIN(to_receive_buf),
        .DOUT(rx_q)
    );
    
    
    
    
endmodule
