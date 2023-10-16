VCS	 = vcs
VCS_OPTS = -full64 -debug_all -sverilog +define+UVM_NO_DEPRECATED -CFLAGS -DVCS -timescale=1ns/1ps -f filelist.f

BUILD_SRC = dut/ src/ filelist.f

.PHONY: clean comp run

all: comp run

comp:
	rm -rf build/ && mkdir build && cp -r $(BUILD_SRC) build/
	cd build/ && $(VCS) $(VCS_OPTS)

gui: comp
	cd build/ && ./simv -gui

run:
	cd build/ && ./simv

clean:
	rm -rf build/
