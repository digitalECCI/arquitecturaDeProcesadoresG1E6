module sumador_un_bit (
    input A,       // Entrada A
    input B,       // Entrada B
    input Ci,      // Entrada Acarreo 
    output So,     // Salida Suma
    output Co      // Salida Acarreo 
);

    wire x_ab;    // Resultado de A XOR B
    wire cout_t;  // Acarreo temporal
    wire a_ab;    // Acarreo generado por A y B 

    xor (x_ab, A, B);
    xor (So, x_ab, Ci);
    and (cout_t, x_ab, Ci);
    and (a_ab, A, B);
    or (Co, cout_t, a_ab);

endmodule