`ifndef CASE3__SV
`define CASE3__SV
class case3_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case3_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        repeat (100000) begin
            `uvm_do_with(tr, {
                tr_type              == bus_seq_item::REQ;
                rst                  == 1'b0;
                io_flush             == 2'b00;
                req_bits_cmd[3:1]    == 3'b000;
                req_bits_addr[31:30] != 2'b01;
                req_bits_addr[31:28] != 4'b0011;
            })
            get_response(rsp);
        end

        #100
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case3_sequence)
endclass


class case3_readwrite_memory extends base_test;
    function new(string name = "case3_readwrite_memory", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case3_readwrite_memory)
endclass


function void case3_readwrite_memory::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case3_sequence::type_id::get());
endfunction

`endif
