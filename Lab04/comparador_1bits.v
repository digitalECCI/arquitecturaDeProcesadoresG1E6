
`ifndef COMPARADOR_1BITS_V
`define COMPARADOR_1BITS_V

module comparador_1 (
    input  wire A,
    input  wire B,
    output wire Ma,
    output wire I,
    output wire Mb 
);
    wire notA, notB;

    assign notA = ~A;
    assign notB = ~B;

    assign Ma = A & notB;
    assign Mb = notA & B;
    assign I  = ~(A ^ B);

endmodule
`endif // COMPARADOR_1BITS_V
