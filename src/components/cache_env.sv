`ifndef CACHE_ENV__SV
`define CACHE_ENV__SV

class cache_env extends uvm_env;

    bus_driver drv;
    bus_monitor mon;

    function new(string name = "cache_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = bus_driver::type_id::create("drv", this);
        mon = bus_monitor::type_id::create("mon", this);
    endfunction

    `uvm_component_utils(cache_env)
endclass


`endif
