// Memoria de instrucciones (ROM combinacional de 16 palabras de 16 bits)
// Programa de ejemplo: calcula (5 + 3) * 5 = 40 y lo envia por UART
//
//   Tipo R: | opcode(4) | rd(3) | rs(3) | rt(3) | 000 |
//   Tipo I: | opcode(4) | rd(3) |     inmediato(9)     |
module rom_programa (
    input  wire [3:0]  addr,
    output reg  [15:0] instr
);
    localparam ADD = 4'b0000, SUB = 4'b0001, MUL = 4'b0010, MAX  = 4'b0011,
               SHR = 4'b0100, AND = 4'b0101, OR  = 4'b0110, XOR  = 4'b0111,
               LI  = 4'b1000, MOV = 4'b1001, OUT = 4'b1010, DIV  = 4'b1011,
               HALT = 4'b1111;

    always @(*) begin
        case (addr)
            4'd0:    instr = {LI,   3'd1, 9'd5};                 // LI   R1, 5
            4'd1:    instr = {LI,   3'd2, 9'd3};                 // LI   R2, 3
            4'd2:    instr = {ADD,  3'd3, 3'd1, 3'd2, 3'b000};   // ADD  R3, R1, R2  -> 8
            4'd3:    instr = {MUL,  3'd4, 3'd3, 3'd1, 3'b000};   // MUL  R4, R3, R1  -> 40
            4'd4:    instr = {OUT,  3'd0, 3'd4, 3'd0, 3'b000};   // OUT  R4          -> "4:040"
            default: instr = {HALT, 12'd0};                      // HALT
        endcase
    end
endmodule
