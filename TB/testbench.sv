`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

module tb_top;

  // Clock generation
  bit clk = 0;
  always #5 clk = ~clk;

  // BFM instantiation
  alu_bfm bfm(clk);

  // DUT instantiation
  ULA DUT (
    .clock    (clk),
    .reset    (bfm.rstn),
    .modo     (bfm.modo),
    .op       (bfm.op),
    .A        (bfm.A),
    .B        (bfm.B),
    .resultado(bfm.resultado),
    .carryout (bfm.carryout),
    .zero     (bfm.zero)
  );

  // Simulation control
  initial begin
    uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
    run_test("alu_test");
  end

  // Optional waveform dump
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars(0, tb_top);
  // end

  string dumpfile_name;

initial begin
  // Check for +vcd_name=... argument
  if (!$value$plusargs("vcd_name=%s", dumpfile_name)) begin
    dumpfile_name = "dump.vcd"; // default fallback
  end

  $dumpfile(dumpfile_name);
  $dumpvars(0, tb_top);
end
endmodule
