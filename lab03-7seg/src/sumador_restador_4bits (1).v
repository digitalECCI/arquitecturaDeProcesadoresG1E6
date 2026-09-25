module sumador_restador_4_bits (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Sel, // 0 para suma, 1 para resta
    output wire [3:0] So,
    output wire       Co
);

    wire [3:0] B_xor;
    wire c1, c2, c3;

    // Compuertas XOR para invertir B cuando Sel es 1 (Resta)
    assign B_xor[0] = B[0] ^ Sel;
    assign B_xor[1] = B[1] ^ Sel;
    assign B_xor[2] = B[2] ^ Sel;
    assign B_xor[3] = B[3] ^ Sel;

    // Instanciacion de los 4 sumadores de 1 bit
    sumador_un_bit sum0 (.A(A[0]), .B(B_xor[0]), .Ci(Sel), .So(So[0]), .Co(c1));
    sumador_un_bit sum1 (.A(A[1]), .B(B_xor[1]), .Ci(c1),  .So(So[1]), .Co(c2));
    sumador_un_bit sum2 (.A(A[2]), .B(B_xor[2]), .Ci(c2),  .So(So[2]), .Co(c3));
    sumador_un_bit sum3 (.A(A[3]), .B(B_xor[3]), .Ci(c3),  .So(So[3]), .Co(Co));

endmodule