`ifndef CACHE_CASE0__SV
`define CACHE_CASE0__SV
class case0_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case0_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        repeat (128) begin
            `uvm_do_with(tr, { is_req == 1; req_bits_cmd == 4'b0001; })
            `uvm_info("in_seq", "send transaction", UVM_HIGH)
            get_response(rsp);
            `uvm_info("in_seq", "get response", UVM_HIGH)
        end

        #100;
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case0_sequence)
endclass


class cache_case0 extends base_test;
    function new(string name = "cache_case0", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(cache_case0)
endclass


function void cache_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case0_sequence::type_id::get());
endfunction

`endif
