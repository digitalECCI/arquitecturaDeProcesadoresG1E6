module unificador(
	 input  [3:0] entradaab,
	 input  [3:0] entradaba,
	 input  [1:0] selecd,
	 output [6:0] entradaAU,
	 output [6:0] entradaAD,
    output [6:0] decena,
    output [6:0] unidad,
	 output [6:0] entradaBU,
	 output [6:0] entradaBD,
	 output signo,
	 output menos,
	 output estado
);
      
    wire [4:0] seleccion;
	 wire [3:0] decenasx;
	 wire [3:0] unidadesx;
	 wire [3:0] sumare;
	 wire [3:0] entradaU;
	 wire [3:0] entradaD;
	 wire [3:0] entradbU;
	 wire [3:0] entradbD;
	 wire signor;
	 wire estador;

	operaciones moduloselector(
			.selec(selecd),
			.A(entradaab),
			.B(entradaba),
			.salida(seleccion),
			.negativo(signor)
	);

	decenayunidad salidafinal(
		.bin(seleccion),
		.unidadyx(unidadesx),
		.decenayx(decenasx)
	);
	decenayunidad entradaA1(
		.bin(entradaab),
		.unidadyx(entradaU),
		.decenayx(entradaD)
	);
	decenayunidad entradaB1(
		.bin(entradaba),
		.unidadyx(entradbU),
		.decenayx(entradbD)
	);

	multiplexor_7seg entradaAunidades(
		.BCD(entradaU),
		.SSeg(entradaAU)
	);
	multiplexor_7seg entradaAdecenas(
		.BCD(entradaD),
		.SSeg(entradaAD)
	);
	multiplexor_7seg entradaBunidades(
		.BCD(entradbU),
		.SSeg(entradaBU)
	);
	multiplexor_7seg entradaBdecenas(
		.BCD(entradbD),
		.SSeg(entradaBD)
	);
	multiplexor_7seg salidadecenas(
		.BCD(decenasx),
		.SSeg(decena)
	);
	
	multiplexor_7seg salidaunidades(
		.BCD(unidadesx),
		.SSeg(unidad)
	);
	
	assign signo = signor;
	assign menos= ~estador;
	assign estador = selecd;
	assign estado = estador;
	
endmodule