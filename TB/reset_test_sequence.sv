`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

`ifndef RESET_SEQUENCE_SV
`define RESET_SEQUENCE_SV

class reset_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(reset_sequence)

  int unsigned reset_cycles = 5;
  sequence_item req;
  uvm_cmdline_processor clp;

  function new(string name = "reset_sequence");
    super.new(name);
    req = sequence_item::type_id::create("reset_req");
endfunction

  task body();
    get_arguments();
    for (int i = 0; i < reset_cycles; i++) begin
      start_item(req);
      if (!req.randomize() with {
        req.rstn == 0;
        req.A == 0;
        req.B == 0;
        req.op == 0;
        req.rstn == 0;
      })
      begin
       `uvm_error(get_type_name(), "Randomization failed for req with A == 2")
      end
      finish_item(req);
    end
  endtask

  function void get_arguments();
    string val_str;

    if (clp.get_arg_value("+reset_cycles=", val_str)) begin
      reset_cycles = val_str.atoi();
      `uvm_info("CMDLINE", $sformatf("Received reset_cycles = %0d", reset_cycles), UVM_LOW)
    end
  endfunction
endclass
`endif
