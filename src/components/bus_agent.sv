`ifndef BUS_AGENT__SV
`define BUS_AGENT__SV

class bus_agent extends uvm_agent;
    bus_driver drv;
    bus_monitor mon;

    int is_req;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);

    `uvm_component_utils(bus_agent)
endclass;

function void bus_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (is_active == UVM_ACTIVE) begin
       drv = bus_driver::type_id::create("drv", this);
       drv.is_req = is_req;
    end
    mon = bus_monitor::type_id::create("mon", this);
    mon.is_req = is_req;
    mon.is_active = is_active == UVM_ACTIVE;
 endfunction

`endif
