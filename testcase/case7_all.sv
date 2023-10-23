`ifndef case7__SV
`define case7__SV
class case7_sequence extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "case7_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        // sequence read / write, test hit
        repeat(3) begin
            for (int i = 0; i < 40000; i++) begin
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

        // reset
        `uvm_do_with(tr, {
            tr_type            == bus_seq_item::REQ;
            rst                == 1'b1;
            io_flush           == 2'b00;
        })

        // sequence
        repeat(3) begin
            for (int i = 0; i < 40000; i++) begin
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

        // random read / write
        repeat(100000) begin
            `uvm_do_with(tr, {
                tr_type            == bus_seq_item::REQ;
                rst                == 1'b0;
                io_flush           == 2'b00;
                req_bits_cmd[3:1]  == 3'b000;
            })
            get_response(rsp);
        end

        // random read / write with reset
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

    `uvm_object_utils(case7_sequence)
endclass


class case7_all extends base_test;
    function new(string name = "case7_all", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case7_all)
endclass


function void case7_all::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            case7_sequence::type_id::get());
endfunction

`endif
