`include "Sumador_4bit.v"

module Resta_4bit
(
    input  [3:0] A,
    input  [3:0] B,
    output [3:0] R_mag,   // Magnitud final del resultado
    output signo           // 1 si es negativo
);

    wire [3:0] B_inv;
    wire [3:0] B_c2;
    wire carry1;

    wire [3:0] R_raw;     // Resultado directo A - B (en C2)
    wire carry2;

    // ---- Complemento a 2 de B ----
    assign B_inv = ~B;
    Sumador_4bit c2_B (
        .A(B_inv),
        .B(4'b0001),
        .Ci(1'b0),      
        .So(B_c2),
        .Co(carry1)     
    );

    // ---- Resta: A + (C2 de B) ----
    Sumador_4bit rest (
        .A(A),
        .B(B_c2),
        .Ci(1'b0),     
        .So(R_raw),
        .Co(carry2)     
    );

    // ---- Detector de signo ----
    assign signo = R_raw[3];   // 1 = negativo

    // ---- Si es negativo → segundo complemento a 2 ----
    wire [3:0] R_inv;
    wire [3:0] R_c2;
    wire carry3;

    assign R_inv = ~R_raw;

    Sumador_4bit c2_R (
        .A(R_inv),
        .B(4'b0001),
        .Ci(1'b0),      
        .So(R_c2),
        .Co(carry3)     
    );

    // Magnitud final:
    assign R_mag = (signo == 1) ? R_c2 : R_raw;

endmodule