module restadors(
    input [3:0] EntradA,
    input [3:0] EntradB,
    input selec,
    output [3:0] SALIDA,
    output COUT,
    output C4
);

wire C0, C1, C2, C3;
wire Sal0, Sal1, Sal2, Sal3;
wire Ca0, Ca1, Ca2;

sumador modulo1(
    .entradaa(EntradA[0]),
    .entradab(EntradB[0] ^ selec),
    .entradac(selec),  
    .sa1(Sal0),
    .sa2(C0)
);
sumador modulo2(
    .entradaa(EntradA[1]),
    .entradab(EntradB[1] ^ selec),
    .entradac(C0),  
    .sa1(Sal1),
    .sa2(C1)
);
sumador modulo3(
    .entradaa(EntradA[2]),
    .entradab(EntradB[2]  ^ selec),
    .entradac(C1),  
    .sa1(Sal2),
    .sa2(C2)
);
sumador modulo4(
    .entradaa(EntradA[3]),
    .entradab(EntradB[3]  ^ selec),
    .entradac(C2),  
    .sa1(Sal3),
    .sa2(C3)
);

assign C4 = ~C3 & selec;

sumador sumador1(
    .entradaa(Sal0 ^ C4),
    .entradab(C4),
    .entradac(1'b0),  
    .sa1(SALIDA[0]),
    .sa2(Ca0)
);

sumador sumador2(
    .entradaa(Sal1 ^ C4),
    .entradab(1'b0),
    .entradac(Ca0),  
    .sa1(SALIDA[1]),
    .sa2(Ca1)
);

sumador sumador3(
    .entradaa(Sal2 ^ C4),
    .entradab(1'b0),
    .entradac(Ca1),  
    .sa1(SALIDA[2]),
    .sa2(Ca2)
);

sumador sumador4(
    .entradaa(Sal3 ^ C4),
    .entradab(1'b0),
    .entradac(Ca2),  
    .sa1(SALIDA[3])
);

assign COUT = (selec == 1'b0) ? C3 : 1'b0;
endmodule