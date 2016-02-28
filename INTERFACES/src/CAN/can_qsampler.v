`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2016 19:07:10
// Design Name: 
// Module Name: can_qsampler
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


module can_qsampler
    (
    input wire GCLK,    // Main clock
    input wire RES,     // Reset module
    inout wire CAN,     // CAN bus inout
    input wire din,     // Bit to transmit
    output reg dout,    // Received bit
    output reg cntmn,   // Contamination detector
    output reg cntmn_ready, // See if cntmn is valid
    output reg sync     // Timeslot start flag 
    );
    
    parameter QUANTA = 20;  // Level hold time
    parameter SP = 15;      // Sample point
    
    reg din_latch = 1'b0;    // Latch din at timeslot start   
    reg [63:0] qcnt = 64'd0; // Timeslot counter
    
    // CAN Read with resync
    reg can_sample;
    always @(posedge GCLK) begin
        can_sample <= CAN;
        
        // Sample data
        if (qcnt == SP) begin
            dout <= CAN;
            cntmn_ready <= 1'b1;
            // Contamination flag:
            if (din_latch != CAN) begin
                cntmn <= 1'b1;
            end 
            else begin
                cntmn <= 1'b0;
            end
        end
        else if (qcnt < SP) begin
            cntmn_ready <= 1'b0;
        end
        
        // Reset circuit
        else if (RES == 1'b1) begin
            dout <= 1'b0;
            cntmn <= 1'b0;
        end
        
        // Reset circuit
        if (RES == 1'b1) begin
            qcnt <= 64'd0;
            sync <= 1'b0;
        end
        // Reset counter
        else if (qcnt == QUANTA) begin
            qcnt <= 64'd0;
            sync <= 1'b1; // Hold for 1 tact
            cntmn <= 1'b0;
            cntmn_ready <= 1'b0;
        end 
        // Resync circuit
        else if ((qcnt > SP) & (can_sample != dout)) begin
            qcnt <= 64'd0;
            sync <= 1'b1; // Hold for 1 tact
            cntmn <= 1'b0;
            cntmn_ready <= 1'b0;
        end        
        // Counter
        else begin
            qcnt <= qcnt + 64'd1;
            sync <= 1'b0;
        end
    end
    
    // CAN Write
    assign CAN = (din_latch == 1'b0) ? 1'b0 : 1'bZ;
    
    always @(negedge GCLK) begin
        if (qcnt == 64'd0) begin
            din_latch <= din; // CAN Write
        end
    end
    
    
endmodule
