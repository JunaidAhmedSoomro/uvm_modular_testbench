SHELL := /bin/bash
UVM_LIB_PATH = /home/junaid/questasim/uvm-1.2
TOP_MODULE   = tb_top
FLIST        = filelist.f
ARGS_FILE    = regression.txt

all: build run_tests move_vcd

clean:
	rm -rf transcript vsim.wlf *.log *.vcd *.ucdb results work waveform vsim_stacktrace.vstf

build:
	vlib work
	vlog -sv -mfcu -f $(FLIST) -L $(UVM_LIB_PATH)

move_vcd:
	mkdir -p waveform
	mv -v *.vcd waveform/

run_tests:
	@mkdir -p results
	@echo "Starting batch simulations from $(ARGS_FILE)..."
	@declare -A name_count; \
	i=1; \
	while read -r line; do \
		if [ -n "$$line" ]; then \
			test_name=$$(echo "$$line" | grep -oP '\+UVM_TESTNAME=\K[^ ]+'); \
			if [ -z "$$test_name" ]; then \
				for f in $$(echo "$$line" | grep -oP '(?<=-f )[^ ]+'); do \
					if [ -f "$$f" ]; then \
						test_name=$$(grep -oP '\+UVM_TESTNAME=\K[^ ]+' "$$f"); \
						if [ -n "$$test_name" ]; then break; fi; \
					fi; \
				done; \
			fi; \
			if [ -z "$$test_name" ]; then test_name="unnamed_test"; fi; \
			name_key=$$test_name; \
			count=$${name_count[$$name_key]}; \
			if [ -z "$$count" ]; then count=1; else count=$$((count+1)); fi; \
			name_count[$$name_key]=$$count; \
			log_file="results/$$test_name\_$$count.log"; \
			echo "Running Test $$i: $$line"; \
			(cd . && eval "$$line" > "$$log_file"); \
			echo "Finished Test $$i (log: $$log_file)"; \
			i=$$((i+1)); \
		fi; \
	done < $(ARGS_FILE)

report:
	@echo "Generating final UVM test report..."
	@pass=0; fail=0; \
	for f in results/*.log; do \
		test_name=$$(basename $$f .log); \
		uvm_error=$$(grep -w "UVM_ERROR" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		uvm_fatal=$$(grep -w "UVM_FATAL" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		if [ "$$uvm_error" = "" ]; then uvm_error=0; fi; \
		if [ "$$uvm_fatal" = "" ]; then uvm_fatal=0; fi; \
		if [ "$$uvm_error" = "0" ] && [ "$$uvm_fatal" = "0" ]; then \
			echo "✅ $$test_name: PASS"; \
			pass=$$((pass+1)); \
		else \
			echo "❌ $$test_name: FAIL (UVM_ERROR=$$uvm_error, UVM_FATAL=$$uvm_fatal)"; \
			fail=$$((fail+1)); \
		fi; \
	done; \
	total=$$((pass+fail)); \
	echo "-----------------------------------------"; \
	echo "Summary: $$pass / $$total tests passed."; \
	if [ "$$fail" -eq 0 ]; then echo "🎉 All tests passed!"; else echo "⚠️  $$fail test(s) failed."; fi
