`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  // Driver and Monitor analysis imp ports
  uvm_analysis_imp_drv #(sequence_item, scoreboard) drv_analysis_imp;
  uvm_analysis_imp_mon #(sequence_item, scoreboard) mon_analysis_imp;

  sequence_item expected[$];
  sequence_item actual[$];
  bit fail = 0;
  int num_checks;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv_analysis_imp = new("drv_analysis_imp", this);
    mon_analysis_imp = new("mon_analysis_imp", this);
  endfunction

  // === Write method for driver (input to DUT) ===
  function void write_drv(sequence_item txn);
    reference_model(txn);
  endfunction

  // === Write method for monitor (output from DUT) ===
  function void write_mon(sequence_item txn);
    actual.push_back(txn);
  endfunction

  function void reference_model(sequence_item txn);
    if (txn.rstn == 0) begin
      txn.resultado <= 6'b000000;
      txn.carryout  <= 0;
      txn.zero      <= 1;
    end else begin
      logic [6:0] temp_result_u;
      logic signed [5:0] A_s, B_s;
      logic signed [6:0] temp_result_s;

      A_s = txn.A;
      B_s = txn.B;

      case (txn.op)
        3'b000: begin // ADD
          if (txn.modo) begin
            temp_result_s = A_s + B_s;
            txn.resultado = temp_result_s[5:0];
            txn.carryout  = temp_result_s[6];
          end else begin
            temp_result_u = txn.A + txn.B;
            txn.resultado = temp_result_u[5:0];
            txn.carryout  = temp_result_u[6];
          end
        end

        3'b001: begin // SUB
          if (txn.modo) begin
            temp_result_s = A_s - B_s;
            txn.resultado = temp_result_s[5:0];
            txn.carryout  = temp_result_s[6];
          end else begin
            temp_result_u = txn.A - txn.B;
            txn.resultado = temp_result_u[5:0];
            txn.carryout  = temp_result_u[6];
          end
        end

        3'b010: begin // AND
          txn.resultado = txn.A & txn.B;
          txn.carryout  = 0;
        end

        3'b011: begin // OR
          txn.resultado = txn.A | txn.B;
          txn.carryout  = 0;
        end

        3'b100: begin // XOR
          txn.resultado = txn.A ^ txn.B;
          txn.carryout  = 0;
        end

        3'b101: begin // NOT A
          txn.resultado = ~txn.A;
          txn.carryout  = 0;
        end

        3'b110: begin // A << 1
          temp_result_u = {txn.A, 1'b0} << 1;
          txn.resultado = temp_result_u[5:0];
          txn.carryout  = temp_result_u[6];
        end

        3'b111: begin // A >> 1
          txn.resultado = txn.A >> 1;
          txn.carryout  = txn.A[0]; // optionally capture LSB as carry-out
        end

        default: begin
          txn.resultado = 6'd0;
          txn.carryout  = 0;
        end
      endcase

      txn.zero = (txn.resultado == 6'd0);
    end
    `uvm_info("SCOREBOARD", $sformatf( "Expected: : %s", txn.convert2string()), UVM_LOW)
    expected.push_back(txn);
  endfunction

  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    num_checks = expected.size();
    for (int i = 0; i < num_checks; i++) begin
      if (!expected[i].compare(actual[i])) begin
        `uvm_error("SCOREBOARD", $sformatf("FAIL: Transaction mismatch.\nExpected: %s\nActual  : %s", expected[i].convert2string(), actual[i].convert2string()))
      end else begin
        `uvm_info("SCOREBOARD", $sformatf("PASS: Transaction matches.\nExpected: %s\nActual  : %s", expected[i].convert2string(), actual[i].convert2string()), UVM_LOW)
      end
    end
  endfunction
endclass

`endif
