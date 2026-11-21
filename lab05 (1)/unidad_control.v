// Unidad de control: FSM fetch - decode - execute - (wait) - writeback - print
// Recibe el opcode de la instruccion y genera las senales del datapath.
// Despues de cada instruccion pasa por PRINT, donde espera a que la traza
// de esa instruccion termine de salir por la UART.
module unidad_control (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] opcode,
    input  wire       mul_done,    // done del multiplicador
    input  wire       div_done,    // done del divisor
    input  wire       uart_busy,   // 1 mientras se transmite la linea de traza
    output wire       ir_load,     // carga la instruccion en el IR
    output wire       pc_inc,      // incrementa el PC
    output wire       mul_start,   // pulso de inicio al multiplicador
    output wire       div_start,   // pulso de inicio al divisor
    output wire       out_start,   // OUT: guarda rs en el registro de salida (LEDs)
    output wire       trace_start, // pulso de inicio de la linea de traza por UART
    output wire       reg_we,      // escritura en el banco de registros
    output wire       flag_we,     // actualiza la bandera de cero
    output reg  [1:0] wr_sel,      // fuente del dato a escribir en rd
    output wire       halt,
    output wire [2:0] estado       // para depuracion / simulacion
);
    // Opcodes (los de la ALU coinciden con su selop: opcode[2:0])
    localparam ADD = 4'b0000, SUB = 4'b0001, MUL = 4'b0010, MAX  = 4'b0011,
               SHR = 4'b0100, AND = 4'b0101, OR  = 4'b0110, XOR  = 4'b0111,
               LI  = 4'b1000, MOV = 4'b1001, OUT = 4'b1010, DIV  = 4'b1011,
               HALT = 4'b1111;

    // Estados
    localparam FETCH     = 3'd0,
               DECODE    = 3'd1,
               EXECUTE   = 3'd2,
               WAIT      = 3'd3,   // espera done de MUL o DIV
               WRITEBACK = 3'd4,
               HALTED    = 3'd5,
               PRINT     = 3'd6;   // espera a que salga la linea de traza

    // Fuentes del mux de escritura
    localparam WR_ALU = 2'd0, WR_IMM = 2'd1, WR_DIV = 2'd2, WR_RS = 2'd3;

    reg [2:0] state, next_state;

    wire es_alu  = (opcode[3] == 1'b0);                // ADD..XOR (incluye MUL)
    wire es_mul  = (opcode == MUL);
    wire es_div  = (opcode == DIV);
    wire es_out  = (opcode == OUT);
    wire es_halt = (opcode == HALT);
    wire valida  = es_alu || (opcode == LI) || (opcode == MOV) || es_div || es_out;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= FETCH;
        else     state <= next_state;
    end

    always @(*) begin
        case (state)
            FETCH:   next_state = DECODE;
            DECODE:  begin
                if (es_halt)     next_state = PRINT;       // imprime HALT y se detiene
                else if (valida) next_state = EXECUTE;
                else             next_state = FETCH;       // opcode no usado: se ignora
            end
            EXECUTE: begin
                if (es_mul || es_div) next_state = WAIT;
                else if (es_out)      next_state = PRINT;  // OUT no escribe registro
                else                  next_state = WRITEBACK;
            end
            WAIT:    begin
                if      (es_mul && mul_done) next_state = WRITEBACK;
                else if (es_div && div_done) next_state = WRITEBACK;
                else                         next_state = WAIT;
            end
            WRITEBACK: next_state = PRINT;
            PRINT:     begin
                if (uart_busy)    next_state = PRINT;
                else if (es_halt) next_state = HALTED;
                else              next_state = FETCH;
            end
            HALTED:    next_state = HALTED;
            default:   next_state = FETCH;
        endcase
    end

    // Salidas (Moore, salvo los start que dependen tambien del opcode)
    assign ir_load     = (state == FETCH);
    assign pc_inc      = (state == FETCH);
    assign mul_start   = (state == EXECUTE) && es_mul;
    assign div_start   = (state == EXECUTE) && es_div;
    assign out_start   = (state == EXECUTE) && es_out;
    assign trace_start = (state == WRITEBACK) ||
                         ((state == EXECUTE) && es_out) ||
                         ((state == DECODE)  && es_halt);
    assign reg_we      = (state == WRITEBACK);
    assign flag_we     = (state == WRITEBACK) && (es_alu || es_div);
    assign halt        = (state == HALTED);
    assign estado      = state;

    always @(*) begin
        case (opcode)
            LI:      wr_sel = WR_IMM;
            MOV:     wr_sel = WR_RS;
            DIV:     wr_sel = WR_DIV;
            default: wr_sel = WR_ALU;
        endcase
    end
endmodule
