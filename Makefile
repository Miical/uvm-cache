# TESTCASE = case0_read_once
# TESTCASE = case1_read_memory
# TESTCASE = case2_write_memory
# TESTCASE = case3_readwrite_memory
# TESTCASE = case4_mmio
# TESTCASE = case5_reset
# TESTCASE = case6_seq
TESTCASE = case7_all
VERBOSITY = UVM_MEDIUM

# code coverage command
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name simv
CM_DIR = -cm_dir ./covdir.vdb

VCS_OPTS = -full64 -debug_all -sverilog +define+UVM_NO_DEPRECATED -CFLAGS -DVCS \
		   -timescale=1ns/1ps -f filelist.f -fsdb \
		   $(CM) $(CM_NAME) $(CM_DIR)
SIMV_OPTS = +UVM_VERBOSITY=$(VERBOSITY) \
		   $(CM) $(CM_NAME) $(CM_DIR) \
		   +UVM_TESTNAME=$(TESTCASE)

BUILD_SRC = dut/ src/ filelist.f

.PHONY: clean comp run run_gui run_cli show_cov cov


all: comp run
cov: comp run show_cov
gui: comp run_gui

comp:
	rm -rf build/ && mkdir build && cp -r $(BUILD_SRC) build/
	cd build/ && vcs $(VCS_OPTS)

run:
	cd build/ && ./simv $(SIMV_OPTS)

run_gui:
	cd build/ && ./simv -gui $(SIMV_OPTS) &

show_cov:
	cd build/ && dve -full64 -covdir *.vdb &

clean:
	rm -rf build/
