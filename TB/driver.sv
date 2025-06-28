`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif

`ifndef DRIVER_SV
`define DRIVER_SV

class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver)

  virtual alu_bfm bfm;
 int count = 0;
 sequence_item alu_data;
  // Add analysis port to broadcast driven transaction
  uvm_analysis_port #(sequence_item) driver_analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    driver_analysis_port = new("driver_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      alu_data = sequence_item::type_id::create("alu_data");
      if (!uvm_config_db #(virtual alu_bfm)::get(this, "*", "bfm", bfm))
      `uvm_fatal("DRIVER", "Failed to get bfm from config DB")
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    count++;
    forever begin
      seq_item_port.get_next_item(alu_data);
      @(posedge bfm.clk);
      bfm.rstn <= alu_data.rstn;
      bfm.modo <= alu_data.modo;
      bfm.op   <= alu_data.op;
      bfm.A    <= alu_data.A;
      bfm.B    <= alu_data.B;
      seq_item_port.item_done();
      `uvm_info(" DR_IVER", $sformatf("SENDING TXN TO SCB: DR_IVER  : %s", alu_data.convert2string()), UVM_LOW)
      driver_analysis_port.write(alu_data);
    end
    `uvm_info(" DR_IVER", $sformatf("ouot of forever count  : %d", count), UVM_NONE)
  endtask

endclass

`endif
