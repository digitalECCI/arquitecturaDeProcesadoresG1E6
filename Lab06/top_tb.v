`timescale 1ns/1ps

module top_tb();

  reg clk;

  top uut (
    .clk(clk)
  );

  // Generar clock
  initial clk = 0;
  always #5 clk = ~clk;  // clock 100 MHz (periodo 10 ns)

  initial begin
    // Dump para archivo VCD
    $dumpfile("waveform.vcd");
    $dumpvars(0, top_tb);

    #1000;

    $finish;
  end

endmodule
