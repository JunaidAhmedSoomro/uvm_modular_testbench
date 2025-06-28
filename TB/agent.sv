`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif
class agent extends uvm_agent;

    `uvm_component_utils(agent);

    monitor   mon_h;
    driver    drv_h;

    //----------------------------------------------
    //create handle of build in uvm_ sequencer class
    //----------------------------------------------
    uvm_sequencer #(sequence_item) seq_h;

    //------------------------
    //CONSTRUCTOR PHASE
    //------------------------
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    //------------------------
    //BUILD PHASE
    //------------------------
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_h  = monitor ::type_id::create("mon_h",this);
      drv_h  = driver  ::type_id::create("drv_h",this);

      //get object of uvm_sequencer
      seq_h  = uvm_sequencer#(sequence_item)::type_id::create("seq_h",this);
    endfunction

    //------------------------
    //CONNECT PHASE
    //------------------------
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      //connect sequener with driver
      drv_h.seq_item_port.connect(seq_h.seq_item_export);

    endfunction


  endclass