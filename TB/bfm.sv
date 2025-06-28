
`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif
`ifndef COUNTER_BFM_SV
`define COUNTER_BFM_SV

interface alu_bfm(input bit clk);

  logic rstn;
  logic modo;
  logic [2:0] op;
  logic [5:0] A;
  logic [5:0] B;

  // Outputs from DUT
  logic [5:0] resultado;
  logic carryout;
  logic zero;

endinterface

`endif
