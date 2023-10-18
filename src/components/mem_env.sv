`ifndef MEM_ENV__SV
`define MEM_ENV__SV

class mem_env extends uvm_env;

    bus_agent i_agt;
    bus_agent o_agt;

    function new(string name = "mem_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(this,
                                                "i_agt.sqr.main_phase",
                                                "default_sequence",
                                                mem_seq::type_id::get());

        i_agt = bus_agent::type_id::create("i_agt", this);
        o_agt = bus_agent::type_id::create("o_agt", this);
        i_agt.is_active = UVM_ACTIVE;
        o_agt.is_active = UVM_PASSIVE;
        i_agt.is_req = 0;
        o_agt.is_req = 1;
    endfunction

    `uvm_component_utils(mem_env)
endclass


`endif
