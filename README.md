# UVM Testbench Simulation Instructions

This project uses a UVM-based SystemVerilog testbench with a command-line processor to enable modular and configurable test execution. By leveraging command-line arguments, the testbench allows sequences, testcases, and other UVM components to access variable data at runtime. This makes the environment scalable and reusable, as a single test can behave differently based on values passed at runtime.

## 📁 Directory Structure

- filelist.f — List of source files and include directories
- regression.txt — Contains simulation command-line arguments for running tests
- sknobs/ — Contains simulation knob files (sim.knobs, debug.knobs)
- results/ — Logs of all simulations are saved here

## ⚙️ Prerequisites

- QuestaSim installed and accessible from terminal
- UVM 1.2 library available at: /home/**/questasim/uvm-1.2

## All in one command
- make
- this will build, run tests, logs result and wave forms

## 🚀 Compilation

To compile the design and testbench:
make build
This creates the work/ library and compiles all files listed in filelist.f using vlog.

## 🧪 Running Simulations

To run all tests listed in regression.txt:
make run_tests
This:
- Reads each simulation line from regression.txt
- Extracts test name from +UVM_TESTNAME=... (or from knobs files)
- Runs each simulation and saves logs in results/<test_name>_<count>.log

### 🔁 Example of One Testcase with Multiple Command-Line Arguments

A single testcase can read multiple runtime parameters passed via command-line, such as:

 - vsim -f sknobs/sim.knobs +modo=0 +op=1 +num_req=10 +vcd_name=test_1.vcd
 - vsim -f sknobs/sim.knobs +modo=0 +op=1 +num_req=10 +vcd_name=test_2.vcd
 - vsim -f sknobs/sim.knobs +modo=0 +op=2 +num_req=10 +vcd_name=test_3.vcd
 - vsim -f sknobs/sim.knobs +modo=0 +op=3 +num_req=10 +vcd_name=test_4.vcd
 - vsim -f sknobs/sim.knobs +modo=0 +op=4 +num_req=10 +vcd_name=test_5.vcd
 - vsim -f sknobs/sim.knobs +modo=0 +op=5 +num_req=10 +vcd_name=test_6.vcd

This allows the same test to execute with different configurations, improving coverage and test reuse.

## 🔧 Knob Files

Knob files are used to organize simulation options, debug settings, and verbosity levels in a modular way.

### sknobs/sim.knobs

Contains general simulation options:

-c
-suppress 144
-L /home/junaid/questasim/uvm-1.2
+UVM_TESTNAME=alu_test
work.tb_top
-do "run -all; quit"
-f sknobs/debug.knobs

### sknobs/debug.knobs

Sets UVM verbosity levels for different components of the testbench:

- +uvm_set_verbosity=uvm_test_top.env_h,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.seq,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.rst_seq.scb_h,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.env_h.scb_h,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.env_h.ag_h,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.env_h.ag_h.mon_h,_ALL_,UVM_LOW,time,0
- +uvm_set_verbosity=uvm_test_top.env_h.ag_h.drv_h,_ALL_,UVM_LOW,time,0

This allows centralized control of simulation behavior and debug visibility without editing the testbench code.

## 📊 Reporting Results

To generate a summary of all test outcomes:
make report
This:
- Parses each log file in the results/ directory
- Counts UVM_ERROR and UVM_FATAL messages
- Displays pass/fail summary like:
  ✅ my_test_1: PASS
  ❌ my_test_2: FAIL (UVM_ERROR=2, UVM_FATAL=1)
  Summary: 3 / 5 tests passed.

## 🧹 Clean Up

To clean generated files:
make clean
This removes:
- Compilation results (work/)
- Logs, .vcd, .log, .ucdb, and vsim.wlf

## 📝 Notes

- This testbench supports command-line configurability using +args and -f knobs files.
- Each test line in regression.txt must include +UVM_TESTNAME=... or refer to a knobs file that contains it.
- If a test is repeated, logs are numbered automatically (e.g., testname_1.log, testname_2.log).
- Knobs help organize options for simulation, debug control, and test selection in a clean and reusable manner.
