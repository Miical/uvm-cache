`ifndef IN_ENV__SV
`define IN_ENV__SV

class in_env extends uvm_env;
    bus_agent i_agt;
    bus_agent o_agt;

    function new(string name = "in_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = bus_agent::type_id::create("i_agt", this);
        o_agt = bus_agent::type_id::create("o_agt", this);
        i_agt.is_active = UVM_ACTIVE;
        o_agt.is_active = UVM_PASSIVE;
        i_agt.is_req = 1;
        o_agt.is_req = 0;
    endfunction

    `uvm_component_utils(in_env)
endclass

`endif
