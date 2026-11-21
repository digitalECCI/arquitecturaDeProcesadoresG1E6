/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module top (
    input clk,

    output tx,
    input  rx,

    input  [3:0] sw,    // 4 switches físicos
    output [3:0] led    // 4 LEDs físicos
);

  // Clock buffer (puedes usar BUFG si quieres)
  wire clk_bufg;
  bufg_opt bufg (
    .dat_in(clk),
    .dat_out(clk_bufg)
  );

  // Power-on reset counter
  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt;

  always @(posedge clk_bufg) begin
    reset_cnt <= reset_cnt + !resetn;
  end

  // PicoSoC bus
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;

  // GPIO registers (LEDs)
  reg  [31:0] gpio;

  // LEDs: solo los 4 LSB
  assign led = gpio[3:0];

  // ------------------------------
  // Memory-mapped I/O block
  //   0x03000000 → LEDs (RW)
  //   0x03000004 → Switches (RO)
  // ------------------------------
  always @(posedge clk_bufg) begin
    if (!resetn) begin
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
    end else begin
      iomem_ready <= 1'b0;

      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1;

        case (iomem_addr[7:0])

          // --------------------
          // 0x03000000 → LEDs OUT
          // --------------------
          8'h00: begin
            iomem_rdata <= gpio;   // lectura GPIO (opcional)
            if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
            if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
            if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
            if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
          end

          // --------------------
          // 0x03000004 → Switches IN
          // --------------------
          8'h04: begin
            iomem_rdata <= {28'b0, sw};  // switches en bits [3:0]
          end

          default: begin
            iomem_rdata <= 32'b0;
          end

        endcase
      end
    end
  end

  // Instantiate PicoSoC + PicoRV32 CPU
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(resetn),

      .ser_tx(tx),
      .ser_rx(rx),

      .irq_5(1'b0),
      .irq_6(1'b0),
      .irq_7(1'b0),

      .iomem_valid(iomem_valid),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr (iomem_addr),
      .iomem_wdata(iomem_wdata),
      .iomem_rdata(iomem_rdata)
  );

endmodule

// Simple clock passthrough
module bufg_opt (
  input dat_in,
  output reg dat_out
);
  always @* begin
    dat_out <= dat_in;
  end
endmodule
