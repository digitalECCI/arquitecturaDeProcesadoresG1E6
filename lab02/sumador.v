module sumador(
    input entradaa, 
    input entradab, 
    input entradac,
    output sa1, 
    output sa2
);
    wire y1, y2, y3;
    assign y1 = entradaa ^ entradab;
    assign sa1 = y1 ^ entradac;
    assign y2 = y1 & entradac;
    assign y3 = entradaa & entradab;
    assign sa2 = y2 | y3;
endmodule