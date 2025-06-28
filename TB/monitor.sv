`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

`ifndef MONITOR_SV
`define MONITOR_SV

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual alu_bfm bfm;
  uvm_analysis_port #(sequence_item) monitor_analysis_port;
  sequence_item alu_data;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      alu_data = sequence_item::type_id::create("alu_data");
      if (!uvm_config_db #(virtual alu_bfm)::get(this, "*", "bfm", bfm))
      `uvm_fatal("MONITOR", "Failed to get bfm from config DB")

    monitor_analysis_port = new("monitor_analysis_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(negedge bfm.clk);
      alu_data.rstn = bfm.rstn;
      alu_data.modo = bfm.modo;
      alu_data.op   = bfm.op;
      alu_data.A    = bfm.A;
      alu_data.B    = bfm.B;
      alu_data.resultado = bfm.resultado;
      alu_data.carryout  = bfm.carryout;
      alu_data.zero      = bfm.zero;
      `uvm_info("MONITOR", $sformatf("SENDING TXN TO SCB: MONITOR  : %s", alu_data.convert2string()), UVM_LOW)
      monitor_analysis_port.write(alu_data);
    end
  endtask

endclass

`endif
