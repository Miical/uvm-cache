`ifndef TOP_ENV__SV
`define TOP_ENV__SV

class top_env extends uvm_env;

    in_env  i_env;
    mem_env m_env;
    // cache_model refmodel;

    function new(string name = "cache_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        i_env = in_env::type_id::create("i_env", this);
        m_env = mem_env::type_id::create("m_env", this);
        // refmodel = cache_model::type_id::create("cache_model", this);
    endfunction

    `uvm_component_utils(top_env)
endclass

`endif
