module UART_TX #
(
        parameter CLOCK_FREQUENCY = 100_000_000,
        parameter BAUD_RATE       = 9600
)
(
        (* mark_debug = "true" *) input  clk,
        (* mark_debug = "true" *) input  reset,
        (* mark_debug = "true" *) input  [7:0] data_in,
        (* mark_debug = "true" *) input  start,
        (* mark_debug = "true" *) output wire idle,
        (* mark_debug = "true" *) output wire ready,
        (* mark_debug = "true" *) output wire out
);

localparam HALF_BAUD_CLK_REG_VALUE = (CLOCK_FREQUENCY / BAUD_RATE / 2 - 1);
localparam HALF_BAUD_CLK_REG_SIZE  = 64;

reg [HALF_BAUD_CLK_REG_SIZE-1:0] clk_counter = 0;
reg baud_clk      = 1'b0;
reg [9:0] tx_reg  = 10'h001;
reg [3:0] counter = 4'h0; 

assign ready = !counter[3:1];
assign idle  = ready & (~counter[0]);
assign out   = tx_reg[0];

always @(posedge clk) begin 
        if(idle & (~start)) begin
                clk_counter <= 0;
                baud_clk    <= 1'b0;
        end
        else if(clk_counter == 0) begin
                clk_counter <= HALF_BAUD_CLK_REG_VALUE;
                baud_clk    <= ~baud_clk;
        end
        else begin
                clk_counter <= clk_counter - 1'b1;
        end
end

always @(posedge baud_clk or negedge reset) begin
        if(~reset) begin
                counter <= 4'h0;
                tx_reg[0]  <= 1'b1;
        end
        else if(~ready) begin
                tx_reg  <= {1'b0, tx_reg[9:1]};
                counter <= counter - 1'b1;
        end
        else if(start) begin
                tx_reg  <= {1'b1, data_in[7:0], 1'b0};
                counter <= 4'hA;
        end
        else begin
                counter <= 4'h0;
        end
end

endmodule