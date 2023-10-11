`ifndef TOP_ENV__SV
`define TOP_ENV__SV

class top_env extends uvm_env;

    cache_env in_env;
    cache_env mem_env;

    function new(string name = "cache_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        in_env = cache_env::type_id::create("in_env", this);
        mem_env = cache_env::type_id::create("mem_env", this);
        in_env.is_in = 1;
        mem_env.is_in = 0;
    endfunction

    `uvm_component_utils(top_env)
endclass

`endif
