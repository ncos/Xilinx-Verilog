`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2016 15:29:31
// Design Name: 
// Module Name: queue
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


module queue #
    (
    parameter integer WIDTH = 108,
    parameter integer LENGTH = 4
    )
    (
    input wire GCLK,
    input wire RES,
    input wire get,
    input wire put,
    output reg full = 1'b0,
    output reg empty = 1'b1,
    input wire [WIDTH-1:0] DIN,
    output reg [WIDTH-1:0] DOUT
    );
    
    reg [WIDTH-1:0] q[0:LENGTH-1];
    reg [63:0] head = 64'd0; // Number of stored elements
    
    reg get_release = 1'b1;
    reg put_release = 1'b1;
    
    wire to_get;
    wire to_put;
    assign to_get = get & get_release;
    assign to_put = put & put_release;

    // Block get/put if not returned to zero
    always @(posedge GCLK) begin
        if (RES == 1'b1) begin
            get_release <= 1'b1;
        end
        else if (get == 1'b0) begin
            get_release <= 1'b1;
        end
        else if (to_get == 1'b1) begin
            get_release <= 1'b0;
        end
        
        if (RES == 1'b1) begin
            put_release <= 1'b1;
        end
        else if (put == 1'b0) begin
            put_release <= 1'b1;
        end
        else if (to_put == 1'b1) begin
            put_release <= 1'b0;
        end
    end

    // Queue
    integer i = 0;
    always @(posedge GCLK) begin
        if (to_put & !to_get) begin
            for (i = LENGTH - 1; i > 0; i = i - 1) begin
                q[i] <= q[i - 1];
            end
            q[0] <= DIN;
        end
        
        if (to_get &  !to_put & !empty) begin
            DOUT <= q[head - 64'd1];
        end
        else if (to_get & to_put) begin
            DOUT <= DIN;
        end
    end
    
    // HEAD pointer, Full/Empty circuits
    always @(posedge GCLK) begin
        if (RES == 1'b1) begin
            head <= 64'd0;
            full <= 1'b0;
            empty <= 1'b1;
        end
        else if (!full & to_put & !to_get) begin
            head <= head + 64'd1;
            empty <= 1'b0; // Now not empty for sure
            // head will be LENGTH by the end of this clock
            if (head == LENGTH - 1) begin
                full <= 1'b1;
            end
        end
        else if (!empty & to_get & !to_put) begin
            head <= head - 64'd1;
            full <= 1'b0; // Now not full for sure
            // head will be 0 by the end of this clock
            if (head == 64'd1) begin
                empty <= 1'b1;
            end
        end
        else begin
            head <= head;
            full <= full;
            empty <= empty;
        end
    end
    
    
endmodule
