// Procesador del Lab 5: unidad de control + ROM + banco de registros + ALU
// (con multiplicador) + divisor + UART.
// Al soltar el reset ejecuta el programa de la ROM hasta llegar a HALT.
module top #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600      // en simulacion se sube para acelerar
) (
    input  wire       clk,          // 50 MHz DE10-Lite
    input  wire       rst_n,        // KEY[0], activo en bajo
    output wire       tx,           // UART hacia el PC
    output wire [9:0] LEDR          // [7:0] ultimo dato de OUT, [8] bandera Z, [9] HALT
);
    wire rst = ~rst_n;

    // ---------------- Senales de control ----------------
    wire       ir_load, pc_inc, mul_start, div_start, out_start, trace_start;
    wire       reg_we, flag_we, halt;
    wire [1:0] wr_sel;
    wire [2:0] estado;
    wire       mul_done, div_done, trace_busy;

    // ---------------- PC e IR ----------------
    reg  [3:0]  pc;
    reg  [15:0] ir;
    wire [15:0] rom_data;

    rom_programa inst_rom (.addr(pc), .instr(rom_data));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 4'd0;
            ir <= 16'hF000;                 // HALT (no se ejecuta, solo valor de reset)
        end else begin
            if (ir_load) ir <= rom_data;
            if (pc_inc)  pc <= pc + 1'b1;
        end
    end

    // Campos de la instruccion
    wire [3:0] opcode = ir[15:12];
    wire [2:0] rd     = ir[11:9];
    wire [2:0] rs     = ir[8:6];
    wire [2:0] rt     = ir[5:3];
    wire [7:0] imm    = ir[7:0];            // del inmediato de 9 bits se usan 8 (ancho del dato)

    // ---------------- Unidad de control ----------------
    unidad_control inst_uc (
        .clk(clk), .rst(rst), .opcode(opcode),
        .mul_done(mul_done), .div_done(div_done), .uart_busy(trace_busy),
        .ir_load(ir_load), .pc_inc(pc_inc),
        .mul_start(mul_start), .div_start(div_start), .out_start(out_start),
        .trace_start(trace_start),
        .reg_we(reg_we), .flag_we(flag_we), .wr_sel(wr_sel),
        .halt(halt), .estado(estado)
    );

    // ---------------- Banco de registros ----------------
    wire [7:0] rs_data, rt_data;
    reg  [7:0] wr_data;

    banco_registro inst_banco (
        .clk(clk), .rst(rst),
        .we(reg_we), .addr_rd(rd), .data_in(wr_data),
        .addr_rs(rs), .addr_rt(rt),
        .data_rs(rs_data), .data_rt(rt_data)
    );

    // ---------------- ALU (Lab 4, sin cambios) ----------------
    // La ALU opera con 4 bits: usa el nibble bajo de cada registro.
    wire [7:0] alu_result;
    wire       alu_zero;

    ALU inst_alu (
        .A(rs_data[3:0]), .B(rt_data[3:0]), .selop(opcode[2:0]), .Cin(1'b0),
        .init(mul_start), .clk(clk), .reset(rst),
        .done(mul_done), .result(alu_result), .flag(alu_zero)
    );

    // ---------------- Divisor ----------------
    wire [3:0] div_q, div_r;

    divisor_fsm inst_div (
        .clk(clk), .rst(rst), .init(div_start),
        .DV(rs_data[3:0]), .DR(rt_data[3:0]),
        .done(div_done), .cociente(div_q), .residuo(div_r)
    );

    // ---------------- Mux de escritura ----------------
    always @(*) begin
        case (wr_sel)
            2'd0:    wr_data = alu_result;         // operaciones de la ALU (incluye MUL)
            2'd1:    wr_data = imm;                // LI
            2'd2:    wr_data = {4'b0000, div_q};   // DIV
            default: wr_data = rs_data;            // MOV
        endcase
    end

    // ---------------- Bandera de cero y registro de salida ----------------
    reg       flag_z;
    reg [7:0] out_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            flag_z  <= 1'b0;
            out_reg <= 8'd0;
        end else begin
            if (flag_we)   flag_z  <= (wr_data == 8'd0);
            if (out_start) out_reg <= rs_data;
        end
    end

    // ---------------- UART ----------------
    // Por cada instruccion ejecutada se envia una linea con sus campos en
    // binario y los valores usados, por ejemplo:
    //   MUL  0010 100 011 001 000  rd=040 rs=008 rt=005
    wire       uart_start, uart_busy;
    wire [7:0] uart_data;

    uart_traza inst_traza (
        .clk(clk), .rst(rst),
        .start(trace_start), .instr(ir),
        .rd_val(wr_data), .rs_val(rs_data), .rt_val(rt_data),
        .tx_busy(uart_busy), .tx_start(uart_start), .tx_data(uart_data),
        .busy(trace_busy)
    );

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) inst_uart_tx (
        .clk(clk), .rst(rst),
        .tx_data(uart_data), .tx_start(uart_start),
        .tx(tx), .tx_busy(uart_busy)
    );

    assign LEDR[7:0] = out_reg;
    assign LEDR[8]   = flag_z;
    assign LEDR[9]   = halt;
endmodule
