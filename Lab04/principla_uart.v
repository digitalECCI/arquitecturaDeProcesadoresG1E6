// ============================================================================
// principla (DE10-Lite, version con 9 switches externos)
//   Entradas de la placa : A = SW3..SW0, B = SW7..SW4, selec[1:0] = SW8,SW9
//                          guardar = KEY0, reset = KEY1 (activo en bajo)
//   Entradas externas (9): selec[2], selectora[3:0], selectorb[3:0]
//   - selec        : operacion (000 suma, 001 resta, 010 OR, 011 NOT A, 100 EXNOR,
//                    101 A<<1, 110 comparador, 111 multiplicar)
//   - selectora    : registro que se muestra en el display A  Y  donde se guarda
//   - selectorb    : registro que se muestra en el display B
//   - guardar(KEY0): guarda el resultado en el registro 'selectora'
//                    (con selec=111 primero ejecuta la multiplicacion)
//   Display A = HEX5..HEX3, Display B = HEX2..HEX0, punto de HEX5 = signo negativo
// ============================================================================
module principla_uart #(parameter LOCK = 1000000,            // LOCK ~20 ms a 50 MHz
                   parameter CLK_FREQ = 50_000_000,
                   parameter BAUD = 115200) (
    input        clk,
    input        reset,          // KEY1, activo en bajo
    input        guardar,        // KEY0, activo en bajo
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] selec,
    input  [3:0] selectora,
    input  [3:0] selectorb,
    output       segSigno,
    output [6:0] segRa_cen,
    output [6:0] segRa_dec,
    output [6:0] segRa_uni,
    output [6:0] segRb_cen,
    output [6:0] segRb_dec,
    output [6:0] segRb_uni,
    output [2:0] estado,
    output       tx              // UART hacia el CP2102 (pin RXD del adaptador)
);
    reg [1:0] rs = 2'b11, gs = 2'b11;
    always @(posedge clk) begin
        rs <= {rs[0], reset};
        gs <= {gs[0], guardar};
    end
    wire rst_n = rs[1];

    reg g_prev = 1'b1;
    reg [20:0] lg = 0;
    wire g_press = ~gs[1] & g_prev & (lg == 0);
    always @(posedge clk) begin
        g_prev <= gs[1];
        if (g_press) lg <= LOCK; else if (lg != 0) lg <= lg - 1'b1;
    end

    localparam IDLE = 0, START = 1, WAIT = 2, WRITE = 3;
    reg [1:0] st = IDLE;
    reg [5:0] cnt = 0;
    reg       start_r = 0, act_r = 0, msg_go = 0;
    reg [3:0] waddr = 0;
    always @(posedge clk) begin
        if (!rst_n) begin
            st <= IDLE; cnt <= 0; start_r <= 0; act_r <= 0; waddr <= 0; msg_go <= 0;
        end else begin
          msg_go <= 1'b0;
          case (st)
            IDLE:  if (g_press) begin
                       cnt <= 0; waddr <= selectora;      // fija el destino al pulsar
                       if (selec == 3'b111) begin start_r <= 1; st <= START; end
                       else                 begin act_r   <= 1; st <= WRITE; end
                   end
            START: begin cnt <= cnt + 1'b1;
                       if (cnt == 6'd5) begin start_r <= 0; cnt <= 0; st <= WAIT; end end
            WAIT:  begin cnt <= cnt + 1'b1;
                       if (cnt == 6'd40) begin cnt <= 0; act_r <= 1; st <= WRITE; end end
            WRITE: begin cnt <= cnt + 1'b1;
                       if (cnt == 6'd2) begin act_r <= 0; st <= IDLE; msg_go <= 1'b1; end end
          endcase
        end
    end

    wire [7:0] R_byte;
    alus_principal nucleo (
        .A(A), .B(B), .selec(selec), .start(start_r),
        .selectorbanco(waddr), .clk(clk), .reset(rst_n),
        .selectora(selectora), .activaciones(act_r), .selectorb(selectorb),
        .segSigno(segSigno),
        .segRa_cen(segRa_cen), .segRa_dec(segRa_dec), .segRa_uni(segRa_uni),
        .segRb_cen(segRb_cen), .segRb_dec(segRb_dec), .segRb_uni(segRb_uni),
        .estado(estado), .R_byte(R_byte)
    );

    // Al guardar, manda el resultado por UART como texto (para PuTTY)
    uart_msg #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) serial (
        .clk(clk), .rst_n(rst_n), .start(msg_go),
        .addr(waddr), .val(R_byte), .tx(tx), .busy()
    );
endmodule
