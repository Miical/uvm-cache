VCS	 = vcs
VCS_OPTS = -full64 -debug_all -sverilog +define+UVM_NO_DEPRECATED -CFLAGS -DVCS -timescale=1ns/1ps -f filelist.f

BUILD_SRC = dut/ src/ filelist.f

ifdef GUI
GUI_FLAG := -gui
else
GUI_FLAG :=
endif

.PHONY: clean comp run

all: comp run

comp:
	rm -rf build/ && mkdir build && cp -r $(BUILD_SRC) build/
	cd build/ && $(VCS) $(VCS_OPTS)

run:
	cd build/ && ./simv $(GUI_FLAG)

clean:
	rm -rf build/
