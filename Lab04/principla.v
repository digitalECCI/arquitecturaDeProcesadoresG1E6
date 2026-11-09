// Top-level: ALU (calculadora) + banco de registros + displays de 7 segmentos.

module alus_principal (
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] selec,
    input        start,          // pulso para iniciar la multiplicacion (selec = 111)
    input  [3:0] selectorbanco,  // direccion de escritura en el banco
    input        clk,
    input        reset,
    input  [3:0] selectora,      // direccion de lectura Ra
    input        activaciones,   // RegWrite
    input  [3:0] selectorb,      // direccion de lectura Rb
    output       segSigno,
    output [6:0] segRa_cen,
    output [6:0] segRa_dec,
    output [6:0] segRa_uni,
    output [6:0] segRb_cen,
    output [6:0] segRb_dec,
    output [6:0] segRb_uni,
    output [2:0] estado,
    output [7:0] R_byte          // resultado crudo de la ALU (para UART u otros usos)
);

    wire [7:0] RR;
    assign R_byte = RR;

    wire [3:0] cena, deca, unia;
    wire [3:0] cenb, decb, unib;
    wire [7:0] salidaa;
    wire [7:0] salidab;

    assign estado = selec;

    calculadora solucion(
        .clk(clk),
        .AA(A),
        .BB(B),
        .op(selec),
        .start(start),
        .R(RR),
        .segSignos(segSigno)
    );

    BancoRegistro banco(
        .clk(clk),
        .rst(reset),
        .RegWrite(activaciones),
        .addrRa(selectora),
        .addrRb(selectorb),
        .addrW(selectorbanco),
        .datW(RR),
        .datOutRa(salidaa),
        .datOutRb(salidab)
    );

    deceunidad convertidora (
        .bin(salidaa),
        .unidades(unia),
        .decenas(deca),
        .centenas(cena)
    );
    deceunidad convertidorb (
        .bin(salidab),
        .unidades(unib),
        .decenas(decb),
        .centenas(cenb)
    );

    Segmentos centenassa (cena, segRa_cen);
    Segmentos decenassa  (deca, segRa_dec);
    Segmentos unidadessa (unia, segRa_uni);

    Segmentos centenassb (cenb, segRb_cen);
    Segmentos decenassb  (decb, segRb_dec);
    Segmentos unidadessb (unib, segRb_uni);
endmodule

