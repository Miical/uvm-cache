`ifndef CASE5__SV
`define CASE5__SV
class case5_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case5_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        for (int i = 0; i < 100000; i++) begin
            `uvm_do_with(tr, {
                tr_type            == bus_seq_item::REQ;
                rst                == (i % 100 == 0);
                io_flush           == 2'b00;
                req_bits_cmd[3:1]  == 3'b000;
            })
            if (i % 100 != 0) get_response(rsp);
        end

        #100
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case5_sequence)
endclass


class case5_reset extends base_test;
    function new(string name = "case5_reset", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case5_reset)
endclass


function void case5_reset::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case5_sequence::type_id::get());
endfunction

`endif
