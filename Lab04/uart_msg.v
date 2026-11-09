// Manda por UART el texto  "Rnn=vvv\r\n"  (nn = registro 00..15, vvv = valor 000..255)
module uart_msg #(parameter CLK_FREQ = 50_000_000, parameter BAUD = 115200) (
    input        clk,
    input        rst_n,
    input        start,         // pulso de 1 ciclo
    input  [3:0] addr,
    input  [7:0] val,
    output       tx,
    output       busy
);
    reg [3:0] a_l = 0; reg [7:0] v_l = 0;
    reg [3:0] idx = 0;
    reg [1:0] st  = 0;                 // 0 libre, 1 cargar, 2 pausa, 3 esperar
    reg       send = 0; reg [7:0] data = 0;
    wire      tx_busy;
    assign busy = (st != 0);

    function [7:0] byte_at(input [3:0] i, input [3:0] a, input [7:0] v);
        reg [3:0] at, ao, vh, vt, vo;
        begin
            at = (a >= 4'd10) ? 4'd1 : 4'd0;
            ao = (a >= 4'd10) ? (a - 4'd10) : a;
            vh = v / 100; vt = (v / 10) % 10; vo = v % 10;
            case (i)
                0: byte_at = "R";
                1: byte_at = 8'h30 + at;
                2: byte_at = 8'h30 + ao;
                3: byte_at = "=";
                4: byte_at = 8'h30 + vh;
                5: byte_at = 8'h30 + vt;
                6: byte_at = 8'h30 + vo;
                7: byte_at = 8'h0D;      // \r
                default: byte_at = 8'h0A; // \n
            endcase
        end
    endfunction

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) u (
        .clk(clk), .rst_n(rst_n), .send(send), .data(data), .tx(tx), .busy(tx_busy));

    always @(posedge clk) begin
        if (!rst_n) begin st <= 0; idx <= 0; send <= 0; end
        else case (st)
            0: if (start) begin a_l <= addr; v_l <= val; idx <= 0; st <= 1; end
            1: begin data <= byte_at(idx, a_l, v_l); send <= 1; st <= 2; end
            2: begin send <= 0; st <= 3; end
            3: if (!tx_busy) begin
                   if (idx == 4'd8) st <= 0;
                   else begin idx <= idx + 1'b1; st <= 1; end
               end
        endcase
    end
endmodule
