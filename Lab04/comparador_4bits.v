
`ifndef COMPARADOR_4BITS_V
`define COMPARADOR_4BITS_V


module comparador_4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire Ma,   // 1 si A > B
    output wire I,    // 1 si A == B
    output wire Mb    // 1 si A < B
);
    wire Ma3, I3, Mb3;
    wire Ma2, I2, Mb2;
    wire Ma1, I1, Mb1;
    wire Ma0, I0, Mb0;

    comparador_1 cmp_bit3 (
        .A(A[3]), .B(B[3]),
        .Ma(Ma3), .I(I3), .Mb(Mb3)
    );

    comparador_1 cmp_bit2 (
        .A(A[2]), .B(B[2]),
        .Ma(Ma2), .I(I2), .Mb(Mb2)
    );

    comparador_1 cmp_bit1 (
        .A(A[1]), .B(B[1]),
        .Ma(Ma1), .I(I1), .Mb(Mb1)
    );

    comparador_1 cmp_bit0 (
        .A(A[0]), .B(B[0]),
        .Ma(Ma0), .I(I0), .Mb(Mb0)
    );

    assign Ma = Ma3 | (I3 & Ma2) | (I3 & I2 & Ma1) | (I3 & I2 & I1 & Ma0);
    assign Mb = Mb3 | (I3 & Mb2) | (I3 & I2 & Mb1) | (I3 & I2 & I1 & Mb0);
    assign I  = I3 & I2 & I1 & I0;

endmodule

`endif // COMPARADOR_4BITS_V
