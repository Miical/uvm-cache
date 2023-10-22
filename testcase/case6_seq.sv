`ifndef CASE6__SV
`define CASE6__SV
class case6_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case6_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        repeat(3) begin
            for (int i = 0; i < 20000; i++) begin
                `uvm_do_with(tr, {
                    tr_type            == bus_seq_item::REQ;
                    rst                == 1'b0;
                    io_flush           == 2'b00;
                    req_bits_cmd[3:1]  == 3'b000;
                    req_bits_addr      == i;
                })
                get_response(rsp);
            end
        end

        `uvm_do_with(tr, {
            tr_type            == bus_seq_item::REQ;
            rst                == 1'b1;
            io_flush           == 2'b00;
        })

        repeat(3) begin
            for (int i = 0; i < 20000; i++) begin
                `uvm_do_with(tr, {
                    tr_type            == bus_seq_item::REQ;
                    rst                == 1'b0;
                    io_flush           == 2'b00;
                    req_bits_cmd[3:1]  == 3'b000;
                    req_bits_addr      == i;
                })
                get_response(rsp);
            end
        end

        repeat(50000) begin
            `uvm_do_with(tr, {
                tr_type            == bus_seq_item::REQ;
                rst                == 1'b0;
                io_flush           == 2'b00;
                req_bits_cmd[3:1]  == 3'b000;
            })
            get_response(rsp);
        end

        #100
        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(case6_sequence)
endclass


class case6_seq extends base_test;
    function new(string name = "case6_seq", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case6_seq)
endclass


function void case6_seq::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case6_sequence::type_id::get());
endfunction

`endif
