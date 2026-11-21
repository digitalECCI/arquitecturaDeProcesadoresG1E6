`include "Sumador_1bit.v"

module Sumador_4bit_r
(
    input  [3:0] A,
    input  [3:0] B,
    input        Ci,
    output [3:0] So,
    output       Co
);

wire c1, c2, c3;

Sumador_1bit S0 ( .A(A[0]), .B(B[0]), .Ci(Ci), .So(So[0]), .Co(c1) );
Sumador_1bit S1 ( .A(A[1]), .B(B[1]), .Ci(c1), .So(So[1]), .Co(c2) );
Sumador_1bit S2 ( .A(A[2]), .B(B[2]), .Ci(c2), .So(So[2]), .Co(c3) );
Sumador_1bit S3 ( .A(A[3]), .B(B[3]), .Ci(c3), .So(So[3]), .Co(Co) );

endmodule