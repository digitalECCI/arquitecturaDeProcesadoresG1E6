module Sumador_1bit(
    input  A,
    input  B,
    input  Ci,
    output So,
    output Co
);

wire AxorB;

xor (AxorB, A, B);     // suma parcial
xor (So, AxorB, Ci);   // suma final

// Acarreo
wire AB, ACi, BCi;
and (AB, A, B);                                                                                                         and (ACi, A, Ci);
and (BCi, B, Ci);
or  (Co, AB, ACi, BCi);

endmodule