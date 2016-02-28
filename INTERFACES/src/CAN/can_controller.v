`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2016 17:26:53
// Design Name: 
// Module Name: can_controller
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


module can_controller
    (
    input wire GCLK,
    input wire RES,
    inout wire CAN,
    input wire [107:0] DIN,
    output reg [107:0] DOUT,
    input wire tx_start,
    output reg tx_ready = 1'b0,
    output reg rx_ready = 1'b0
    );
    
    wire tx;
    wire rx;
    wire cntmn;
    wire cntmn_ready;
    wire tsync;
    
    reg [107:0] DIN_BUF = 108'd0;
    
    reg timeslot_start  = 1'b0;         // 1 at the start of every frame
    reg timeslot_finish = 1'b0;         // 1 at the end of every frame
    reg have_arb = 1'b1;                // 1 if we have the arbitration
    reg tx_requested = 1'b0;            // 1 if DIN_BUF contains untransmitted data
    reg [127:0] can_state = "RECEIVING";  // RECEIVING/TRANSMITTING
    
    always @(posedge GCLK) begin
        if (RES) begin
            DIN_BUF <= 108'd0;
            tx_ready <= 1'b0;
            rx_ready <= 1'b0;
            tx_requested <= 1'b0;
        end 
    end
    
    // Capture input data
    always @(posedge timeslot_start) begin
        if (tx_start & !RES) begin
            DIN_BUF <= DIN;
            tx_ready <= 1'b0;
            tx_requested <= 1'b1;
        end
        
        if (!RES & !cntmn_ready) begin
            have_arb <= 1'b1; // Assume we have arbitration
            can_state <= "TRANSMITTING";
        end
    end
    
    // Arbitration circuit
    always @(posedge GCLK) begin
        if (RES) begin
            have_arb <= 1'b0; // Do not mess up the bus
            can_state <= "RECEIVING"; // Passively listen during the first timeslot
        end
        else if (cntmn_ready & cntmn) begin
            have_arb <= 1'b0;
            can_state <= "RECEIVING";
        end
    end
    
    // Data transmitting circuit
    reg [63:0] bit_cnt = 64'd0;
    reg [107:0] rx_buf = 108'd0;
    always @(posedge tsync) begin
        if (bit_cnt == 64'd106) begin
            timeslot_finish <= 1'b1;
            timeslot_start <= 1'b0;
        end 
        else if (bit_cnt == 64'd107) begin
            timeslot_finish <= 1'b0;
            timeslot_start <= 1'b1;
        end
        else begin
            timeslot_start <= 1'b0;
            timeslot_finish <= 1'b0;
        end

        if (RES) begin
            bit_cnt <= 64'b0;
        end
        else if (timeslot_finish) begin
            bit_cnt <= 64'd0;
        end else begin
            bit_cnt <= bit_cnt + 64'd1;
        end
    end
    
    assign tx = (have_arb & tx_requested) ? DIN_BUF[bit_cnt] : 1'b1;

    always @(posedge GCLK) begin
        if (timeslot_finish & cntmn_ready & cntmn) begin
            rx_ready <= 1'b1;
            DOUT <= rx_buf;
        end
        else if (timeslot_finish & cntmn_ready & !cntmn) begin
            tx_ready <= 1'b1;
            tx_requested <= 1'b0;
        end
        
        // Receive data
        rx_buf[bit_cnt] <= rx;
    end
 
    can_qsampler CQS
    (
        .GCLK(GCLK),
        .RES(RES),  
        .CAN(CAN),  
        .din(tx),  
        .dout(rx),   
        .cntmn(cntmn),
        .cntmn_ready(cntmn_ready),
        .sync(tsync) 
    );
        
    
endmodule
