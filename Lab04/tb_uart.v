`timescale 1ns/1ps
module tb_uart;
  localparam BAUDT = 1_000_000;           // rapido solo para simular
  localparam BIT_NS = 1000000000/BAUDT;
  reg clk=0; always #10 clk=~clk;
  reg reset=1, guardar=1; reg [3:0] A=0,B=0,sa=0,sb=0; reg [2:0] selec=0;
  wire sg; wire [6:0] ac,ad,au,bc,bd,bu; wire [2:0] est; wire tx;
  principla #(.LOCK(4),.BAUD(BAUDT)) dut(.clk(clk),.reset(reset),.guardar(guardar),.A(A),.B(B),.selec(selec),
    .selectora(sa),.selectorb(sb),.segSigno(sg),.segRa_cen(ac),.segRa_dec(ad),.segRa_uni(au),
    .segRb_cen(bc),.segRb_dec(bd),.segRb_uni(bu),.estado(est),.tx(tx));
  // receptor UART de prueba
  reg [7:0] rxb; reg [8*9-1:0] linea; integer nb=0;
  task rx_byte; integer k; begin
    @(negedge tx); #(BIT_NS*3/2);
    for (k=0;k<8;k=k+1) begin rxb[k]=tx; #(BIT_NS); end
    if (tx!==1'b1) $display("ERROR: bit de parada invalido");
  end endtask
  task recibe_linea; integer j; begin
    linea=0; for (j=0;j<9;j=j+1) begin rx_byte; linea={linea[8*8-1:0],rxb}; end
  end endtask
  integer err=0;
  task gd; begin guardar=0; repeat(8) @(negedge clk); guardar=1; end endtask
  task prueba(input [2:0] o, input [3:0] a, input [3:0] b, input [3:0] dest, input [8*9-1:0] esperado);
    begin
      selec=o; A=a; B=b; sa=dest; repeat(4) @(negedge clk);
      fork gd; recibe_linea; join
      if (linea===esperado) $display("OK    PuTTY recibe: %0s", linea[8*7-1:0]);
      else begin err=err+1; $display("FALLA: recibido '%0s' esperado '%0s'", linea, esperado); end
      repeat(1000) @(negedge clk);
    end endtask
  initial begin
    repeat(3) @(negedge clk); reset=0; repeat(5) @(negedge clk); reset=1; repeat(5) @(negedge clk);
    prueba(0,5,3,3,  {"R03=008",8'h0D,8'h0A});
    prueba(2,5,3,12, {"R12=007",8'h0D,8'h0A});
    prueba(7,15,15,7,{"R07=225",8'h0D,8'h0A});
    prueba(7,4,3,15, {"R15=012",8'h0D,8'h0A});
    if(err==0) $display("=== TODO OK ==="); else $display("=== %0d FALLAS ===",err);
    $finish;
  end
  initial begin #20000000; $display("TIMEOUT"); $finish; end
endmodule
