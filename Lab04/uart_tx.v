// Transmisor UART 8N1 (1 bit de inicio, 8 datos LSB primero, 1 bit de parada)
module uart_tx #(parameter CLK_FREQ = 50_000_000, parameter BAUD = 115200) (
    input        clk,
    input        rst_n,
    input        send,          // pulso de 1 ciclo (solo se acepta si busy = 0)
    input  [7:0] data,
    output reg   tx = 1'b1,
    output       busy
);
    localparam CPB = CLK_FREQ / BAUD;       // ciclos de reloj por bit
    reg [15:0] cnt = 0;
    reg [3:0]  bitn = 0;
    reg [9:0]  sh = 10'h3FF;
    reg        act = 1'b0;
    assign busy = act;

    always @(posedge clk) begin
        if (!rst_n) begin
            act <= 1'b0; tx <= 1'b1; cnt <= 0; bitn <= 0;
        end else if (!act) begin
            tx <= 1'b1;
            if (send) begin
                sh   <= {1'b1, data, 1'b0};  // parada, datos, inicio
                act  <= 1'b1; cnt <= 0; bitn <= 0;
                tx   <= 1'b0;                // bit de inicio
            end
        end else begin
            if (cnt == CPB - 1) begin
                cnt <= 0;
                if (bitn == 4'd9) begin act <= 1'b0; tx <= 1'b1; end
                else begin bitn <= bitn + 1'b1; tx <= sh[bitn + 1'b1]; end
            end else cnt <= cnt + 1'b1;
        end
    end
endmodule
