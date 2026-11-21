// Traza de ejecucion por UART: por cada instruccion ejecutada envia una linea.
// Hay tres formatos:
//   LI (tipo I):           LI    000000101
//                          mnem  inmediato
//   ALU, DIV y MOV:        MUL  0010   rd=015 rs=005 rt=003
//                          mnem opcd   valores en decimal
//   OUT y HALT (completo): OUT  1010 000 011 000 000         rs=015
//                          mnem opcd rd  rs  rt  ---
// Cada linea termina en CR LF.
module uart_traza (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,      // pulso de 1 ciclo: captura la instruccion y los valores
    input  wire [15:0] instr,
    input  wire [7:0]  rd_val,     // valor escrito en rd
    input  wire [7:0]  rs_val,     // operando rs
    input  wire [7:0]  rt_val,     // operando rt
    input  wire        tx_busy,    // desde uart_tx
    output wire        tx_start,   // hacia uart_tx
    output reg  [7:0]  tx_data,    // hacia uart_tx
    output wire        busy
);
    localparam IDLE = 2'd0, SEND = 2'd1, WAIT = 2'd2;

    localparam ADD = 4'b0000, SUB = 4'b0001, MUL = 4'b0010, MAX  = 4'b0011,
               SHR = 4'b0100, AND = 4'b0101, OR  = 4'b0110, XOR  = 4'b0111,
               LI  = 4'b1000, MOV = 4'b1001, OUT = 4'b1010, DIV  = 4'b1011,
               HALT = 4'b1111;

    reg [1:0]  state;
    reg [5:0]  idx;
    reg [15:0] ir_r;
    reg [7:0]  rd_r, rs_r, rt_r;

    wire [3:0] op = ir_r[15:12];

    // Que valores se muestran segun la instruccion
    wire es_alu  = (op[3] == 1'b0) || (op == DIV);         // ADD..XOR, MUL y DIV
    wire show_rs = es_alu || (op == MOV) || (op == OUT);
    wire show_rt = es_alu;

    // Formato de la linea y posicion del ultimo caracter (LF)
    localparam F_I = 2'd0, F_ALU = 2'd1, F_FULL = 2'd2;
    wire [1:0] fmt    = (op == LI)               ? F_I   :
                        (es_alu || (op == MOV))  ? F_ALU : F_FULL;
    wire [5:0] ultimo = (fmt == F_I)   ? 6'd16 :
                        (fmt == F_ALU) ? 6'd33 : 6'd48;

    // Mnemonico de 4 caracteres
    reg [31:0] mnem;
    always @(*) begin
        case (op)
            ADD:     mnem = "ADD ";
            SUB:     mnem = "SUB ";
            MUL:     mnem = "MUL ";
            MAX:     mnem = "MAX ";
            SHR:     mnem = "SHR ";
            AND:     mnem = "AND ";
            OR:      mnem = "OR  ";
            XOR:     mnem = "XOR ";
            LI:      mnem = "LI  ";
            MOV:     mnem = "MOV ";
            OUT:     mnem = "OUT ";
            DIV:     mnem = "DIV ";
            HALT:    mnem = "HALT";
            default: mnem = "????";
        endcase
    end

    // Campos de valor "rd=DDD", "rs=DDD", "rt=DDD": cual toca en la posicion idx
    reg       en_campo;
    reg [2:0] rel;        // posicion dentro del campo (0..5)
    reg [7:0] letra;      // 'd', 's' o 't'
    reg [7:0] val;
    always @(*) begin
        en_campo = 1'b0; rel = 3'd0; letra = "d"; val = rd_r;
        if (fmt == F_ALU) begin
            if (idx >= 6'd12 && idx <= 6'd17) begin
                en_campo = 1'b1; rel = idx - 6'd12; letra = "d"; val = rd_r;
            end else if (idx >= 6'd19 && idx <= 6'd24) begin
                en_campo = 1'b1; rel = idx - 6'd19; letra = "s"; val = rs_r;
            end else if (show_rt && idx >= 6'd26 && idx <= 6'd31) begin
                en_campo = 1'b1; rel = idx - 6'd26; letra = "t"; val = rt_r;
            end
        end else if (fmt == F_FULL) begin
            if (show_rs && idx >= 6'd34 && idx <= 6'd39) begin
                en_campo = 1'b1; rel = idx - 6'd34; letra = "s"; val = rs_r;
            end
        end
    end

    wire [3:0] d_cen = val / 8'd100;
    wire [3:0] d_dec = (val % 8'd100) / 8'd10;
    wire [3:0] d_uni = val % 8'd10;

    // Caracter de la posicion idx
    always @(*) begin
        tx_data = 8'h20;                                          // espacio por defecto
        if (idx == ultimo)
            tx_data = 8'h0A;                                      // LF
        else if (idx == ultimo - 1'b1)
            tx_data = 8'h0D;                                      // CR
        else if (idx <= 6'd3)
            tx_data = mnem[(3 - idx)*8 +: 8];                     // mnemonico
        else if (en_campo)
            case (rel)
                3'd0:    tx_data = "r";
                3'd1:    tx_data = letra;
                3'd2:    tx_data = "=";
                3'd3:    tx_data = 8'h30 + d_cen;
                3'd4:    tx_data = 8'h30 + d_dec;
                default: tx_data = 8'h30 + d_uni;
            endcase
        else if (fmt == F_I) begin
            if (idx >= 6'd6 && idx <= 6'd14)
                tx_data = 8'h30 + ir_r[14 - idx];                 // inmediato [8:0]
        end
        else if (fmt == F_ALU) begin
            if (idx >= 6'd5 && idx <= 6'd8)
                tx_data = 8'h30 + ir_r[20 - idx];                 // opcode [15:12]
        end
        else begin                                                // F_FULL
            if (idx >= 6'd5 && idx <= 6'd8)
                tx_data = 8'h30 + ir_r[20 - idx];                 // opcode [15:12]
            else if (idx >= 6'd10 && idx <= 6'd12)
                tx_data = 8'h30 + ir_r[21 - idx];                 // rd     [11:9]
            else if (idx >= 6'd14 && idx <= 6'd16)
                tx_data = 8'h30 + ir_r[22 - idx];                 // rs     [8:6]
            else if (idx >= 6'd18 && idx <= 6'd20)
                tx_data = 8'h30 + ir_r[23 - idx];                 // rt     [5:3]
            else if (idx >= 6'd22 && idx <= 6'd24)
                tx_data = 8'h30 + ir_r[24 - idx];                 // ---    [2:0]
        end
    end

    assign tx_start = (state == SEND);
    assign busy     = (state != IDLE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; idx <= 0; ir_r <= 0; rd_r <= 0; rs_r <= 0; rt_r <= 0;
        end else begin
            case (state)
                IDLE: if (start) begin
                    ir_r  <= instr;
                    rd_r  <= rd_val;
                    rs_r  <= rs_val;
                    rt_r  <= rt_val;
                    idx   <= 0;
                    state <= SEND;
                end
                SEND: state <= WAIT;              // la UART acepta el byte en este ciclo
                WAIT: if (!tx_busy) begin         // termino el byte actual
                    if (idx == ultimo) state <= IDLE;
                    else begin idx <= idx + 1'b1; state <= SEND; end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
