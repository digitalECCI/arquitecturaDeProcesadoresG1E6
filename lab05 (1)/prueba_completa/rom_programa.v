// Memoria de instrucciones (ROM combinacional de 16 palabras de 16 bits)
// Programa de prueba completa: usa todas las instrucciones del set
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
            4'd0:    instr = {LI,   3'd1, 9'd12};                // LI   R1, 12
            4'd1:    instr = {LI,   3'd2, 9'd10};                // LI   R2, 10
            4'd2:    instr = {ADD,  3'd3, 3'd1, 3'd2, 3'b000};   // ADD  R3, R1, R2  -> 6  (22 mod 16)
            4'd3:    instr = {SUB,  3'd4, 3'd2, 3'd1, 3'b000};   // SUB  R4, R2, R1  -> 14 (-2 mod 16)
            4'd4:    instr = {MUL,  3'd5, 3'd1, 3'd2, 3'b000};   // MUL  R5, R1, R2  -> 120
            4'd5:    instr = {OUT,  3'd0, 3'd5, 3'd0, 3'b000};   // OUT  R5          -> "5:120"
            4'd6:    instr = {DIV,  3'd6, 3'd1, 3'd3, 3'b000};   // DIV  R6, R1, R3  -> 2
            4'd7:    instr = {SHR,  3'd7, 3'd1, 3'd6, 3'b000};   // SHR  R7, R1, R6  -> 3
            4'd8:    instr = {OUT,  3'd0, 3'd7, 3'd0, 3'b000};   // OUT  R7          -> "7:003"
            4'd9:    instr = {AND,  3'd3, 3'd1, 3'd2, 3'b000};   // AND  R3, R1, R2  -> 8
            4'd10:   instr = {OR,   3'd4, 3'd1, 3'd2, 3'b000};   // OR   R4, R1, R2  -> 14
            4'd11:   instr = {XOR,  3'd5, 3'd1, 3'd2, 3'b000};   // XOR  R5, R1, R2  -> 6
            4'd12:   instr = {MAX,  3'd6, 3'd2, 3'd1, 3'b000};   // MAX  R6, R2, R1  -> 12
            4'd13:   instr = {MOV,  3'd7, 3'd5, 3'd0, 3'b000};   // MOV  R7, R5      -> 6
            4'd14:   instr = {LI,   3'd0, 9'd99};                // LI   R0, 99      -> R0 sigue en 0
            default: instr = {HALT, 12'd0};                      // HALT
        endcase
    end
endmodule
