module uart_tx #(
    parameter CLK_FREQ  = 50000000, // Reloj de 50 MHz (DE10-Lite)
    parameter BAUD_RATE = 9600     // 9600 Baudios
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] tx_data,     // Byte a enviar (data_out del banco)
    input  wire       tx_start,    // Pulso para iniciar envío
    output reg        tx,          // Pin físico TX (PIN_W10 / GPIO[1])
    output wire       tx_busy      // 1 mientras transmite
);

    localparam BIT_CNT_MAX = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0]  state = IDLE;
    reg [15:0] clk_cnt = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  tx_shift_reg = 0;

    assign tx_busy = (state != IDLE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            clk_cnt      <= 0;
            bit_index    <= 0;
            tx_shift_reg <= 0;
            tx           <= 1'b1; // Línea en alto en reposo
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    clk_cnt <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        state        <= START;
                    end
                end

                START: begin
                    tx <= 1'b0; // Bit de Start
                    if (clk_cnt < BIT_CNT_MAX - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end else begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end
                end

                DATA: begin
                    tx <= tx_shift_reg[bit_index];
                    if (clk_cnt < BIT_CNT_MAX - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end else begin
                        clk_cnt <= 0;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1; // Bit de Stop
                    if (clk_cnt < BIT_CNT_MAX - 1) begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end else begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule