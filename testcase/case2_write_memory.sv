`ifndef CASE2__SV
`define CASE2__SV
class case2_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case2_sequence");
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
                req_bits_cmd         == 4'b0001;
                req_bits_addr[31:30] != 2'b01;
                req_bits_addr[31:28] != 4'b0011;
            })
            get_response(rsp);
        end

        #100
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case2_sequence)
endclass


class case2_write_memory extends base_test;
    function new(string name = "case2_write_memory", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case2_write_memory)
endclass


function void case2_write_memory::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case2_sequence::type_id::get());
endfunction

`endif
