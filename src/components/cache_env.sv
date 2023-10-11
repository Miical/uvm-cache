`ifndef CACHE_ENV__SV
`define CACHE_ENV__SV

class cache_env extends uvm_env;

    bus_agent i_agt;
    bus_agent o_agt;

    int is_in;

    function new(string name = "cache_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = bus_agent::type_id::create("i_agt", this);
        o_agt = bus_agent::type_id::create("o_agt", this);
        i_agt.is_active = UVM_ACTIVE;
        o_agt.is_active = UVM_PASSIVE;
        i_agt.is_req = is_in;
        o_agt.is_req = !is_in;
    endfunction

    `uvm_component_utils(cache_env)
endclass


`endif
