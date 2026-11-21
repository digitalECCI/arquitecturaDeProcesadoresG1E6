// Sumador/restador de 4 bits. sel=0: A+B   sel=1: A-B (complemento a 2, modulo 16)
module sumador_restador_4b (
    input  [3:0] a_4b,
    input  [3:0] b_4b,
    input        sel,
    output [3:0] s_4b,
    output       cout
);
    wire c1, c2, c3;
    wire [3:0] bXOr = b_4b ^ {4{sel}};

    sumador_1b uut0 (.a(a_4b[0]), .b(bXOr[0]), .cin(sel), .s(s_4b[0]), .cout(c1));
    sumador_1b uut1 (.a(a_4b[1]), .b(bXOr[1]), .cin(c1),  .s(s_4b[1]), .cout(c2));
    sumador_1b uut2 (.a(a_4b[2]), .b(bXOr[2]), .cin(c2),  .s(s_4b[2]), .cout(c3));
    sumador_1b uut3 (.a(a_4b[3]), .b(bXOr[3]), .cin(c3),  .s(s_4b[3]), .cout(cout));
endmodule
