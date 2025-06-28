`ifndef UVM_MACROS_INCLUDED
  import uvm_pkg::*;
  `include "uvm_macros.svh"
`endif
class environment extends uvm_env;
    `uvm_component_utils(environment);

    scoreboard scb_h;
    agent 	   ag_h;

    //------------------------
    //CONSTRUCTOR
    //------------------------
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    //------------------------
    //BUILD PHASE
    //------------------------
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      scb_h = scoreboard::type_id::create("scb_h",this);
      ag_h  = agent     ::type_id::create("ag_h",this);
    endfunction

    //------------------------
    //CONNECT PHASE
    //------------------------
   // Connect Phase
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      // Monitor → Scoreboard (output)
      ag_h.mon_h.monitor_analysis_port.connect(scb_h.mon_analysis_imp);

      // Driver → Scoreboard (input)
      ag_h.drv_h.driver_analysis_port.connect(scb_h.drv_analysis_imp);
    endfunction

  endclass