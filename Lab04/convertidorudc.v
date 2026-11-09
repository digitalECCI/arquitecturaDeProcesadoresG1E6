
`ifndef CONVERTIDORUDC_V
`define CONVERTIDORUDC_V

module deceunidad(
    input  [7:0] bin,
    output [3:0] unidades,
    output [3:0] decenas,
    output [3:0] centenas
);
    reg [19:0] BCD_R;

    always @(*) begin
        BCD_R = 0;
        BCD_R[7:0] = bin;

        // Paso 1
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 2
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 3
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 4
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 5
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 6
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 7
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;

        // Paso 8
        if (BCD_R[11:8]  >= 5) BCD_R[11:8]  = BCD_R[11:8]  + 3;
        if (BCD_R[15:12] >= 5) BCD_R[15:12] = BCD_R[15:12] + 3;
        if (BCD_R[19:16] >= 5) BCD_R[19:16] = BCD_R[19:16] + 3;
        BCD_R = BCD_R << 1;
    end

    assign unidades = BCD_R[11:8];
    assign decenas  = BCD_R[15:12];
    assign centenas = BCD_R[19:16];
endmodule

`endif // CONVERTIDORUDC_V
