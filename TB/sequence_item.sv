`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

class sequence_item extends uvm_sequence_item;
  `uvm_object_utils(sequence_item)

  // Inputs to DUT
  rand bit rstn;
  rand  bit modo;
  rand  bit [2:0] op;
  randc bit [5:0] A;
  randc bit [5:0] B;

  // Outputs from DUT
  bit [5:0] resultado;
  bit carryout;
  bit zero;

  function new(string name = "sequence_item");
    super.new(name);
  endfunction

  // Optional: for easier printing/debugging
  function string convert2string();
    return $sformatf("rstn=%0b modo=%0b op=%0b A=%0h B=%0h => resultado=%0h carryout=%0b zero=%0b",
                     rstn, modo, op, A, B, resultado, carryout, zero);
  endfunction
endclass
