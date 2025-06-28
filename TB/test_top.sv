`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)

  environment           env_h;
  main_sequence         seq;
  reset_sequence        rst_seq;
  uvm_cmdline_processor clp;
  int num_req=5;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h     = environment::type_id::create("env_h", this);
    rst_seq   = reset_sequence::type_id::create("rst_seq");
    seq       = main_sequence::type_id::create("seq");
    clp       = uvm_cmdline_processor::get_inst();
    seq.clp     = clp;
    rst_seq.clp = clp;
    get_arguments();
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting reset seq from reset_phase...", UVM_LOW)
    rst_seq.start(env_h.ag_h.seq_h);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting main_sequence from main_phase...", UVM_LOW)
    repeat(num_req)begin
      seq.start(env_h.ag_h.seq_h);
    end
    #5;
    phase.drop_objection(this);
  endtask

  // task run_phase(uvm_phase phase);
  //   super.run_phase(phase);
  //   phase.raise_objection(this);

  //   `uvm_info("TEST", "Starting reset seq from reset_phase...", UVM_LOW)
  //   rst_seq.start(env_h.ag_h.seq_h);

  //   `uvm_info("TEST", "Starting main_sequence from main_phase...", UVM_LOW)
  //   seq.start(env_h.ag_h.seq_h);

  //   #30;
  //   phase.drop_objection(this);
  // endtask

  function void get_arguments();
    string val_str;

    if (clp.get_arg_value("+num_req=", val_str)) begin
      num_req = val_str.atoi();
      `uvm_info("CMDLINE", $sformatf("Received num_req = %0d", num_req), UVM_LOW)
    end

  endfunction
endclass
