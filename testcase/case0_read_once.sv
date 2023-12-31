`ifndef CASE0__SV
`define CASE0__SV
class case0_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case0_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

            `uvm_do_with(tr, {
                tr_type              == bus_seq_item::REQ;
                rst                  == 1'b0;
                io_flush             == 2'b00;
                req_bits_cmd         == 4'b0000;
                req_bits_addr[31:30] != 2'b01;
                req_bits_addr[31:28] != 4'b0011;
            })
            `uvm_info("in_seq", "send transaction", UVM_HIGH)

            get_response(rsp);
            `uvm_info("in_seq", "get response", UVM_HIGH)

        #100
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case0_sequence)
endclass


class case0_read_once extends base_test;
    function new(string name = "case0_read_once", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case0_read_once)
endclass


function void case0_read_once::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case0_sequence::type_id::get());
endfunction

`endif
