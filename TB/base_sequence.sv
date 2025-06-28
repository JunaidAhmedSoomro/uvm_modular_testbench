`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

`ifndef BASE_SEQUENCE_SV
`define BASE_SEQUENCE_SV

class main_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(main_sequence)

  //command line argumets
  //NOTE : the name of command line argument must differ from the name of sequence item. if same then to use the value of knob local::modo
  bit modo;
  bit [2:0] op;

  uvm_cmdline_processor clp;
  sequence_item req;

  function new(string name = "main_sequence");
    super.new(name);
    req = sequence_item::type_id::create("req");
  endfunction

  virtual task pre_body();
    get_arguments();
  endtask

  task body();
      start_item(req);
      if (!req.randomize() with {
      req.rstn == 1;
      req.modo == local::modo;   //since name of sequence item "modo" is same as the name of the knob "modo", otherwise a radom value will generated not the value passed from knob
      req.op   == local::op;
    })
    begin
      `uvm_error("SEQ", "Randomization failed")
    end
    `uvm_info(get_type_name(), $sformatf("SENT item   : %s", req.convert2string()), UVM_LOW)

    finish_item(req);
  endtask

  function void get_arguments();
    string val_str;
    if (clp.get_arg_value("+modo=", val_str)) begin
      modo = val_str.atoi();
      `uvm_info("CMDLINE", $sformatf("Received modo = %0d", modo), UVM_LOW)
    end
    if (clp.get_arg_value("+op=", val_str)) begin
      op = val_str.atoi();
      `uvm_info("CMDLINE", $sformatf("Received op = %0d", op), UVM_LOW)
    end
  endfunction
endclass

`endif
