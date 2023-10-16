`ifndef BUS_DRIVER__SV
`define BUS_DRIVER__SV

class bus_driver extends uvm_driver#(bus_seq_item);

    virtual simplebus_if bif;

    int is_req;

    `uvm_component_utils(bus_driver)
    function new(string name = "bus_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual simplebus_if)::get(this, "", "bif", bif))
            `uvm_fatal("bus_driver", "No virtual interface set up.")
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task drive_one_pkt(bus_seq_item tr);
endclass


task bus_driver::main_phase(uvm_phase phase);
    bus_seq_item tr;
    phase.raise_objection(this);

    while(top_tb.rst)
        @(posedge top_tb.clk);

    for (int i = 0; i < 100; i++) begin
        tr = new("tr");
        if (is_req)
            assert(tr.randomize() with { is_req == 1; req_bits_cmd == 4'b0000; });
        else
            assert(tr.randomize() with { is_req == 0; });
        drive_one_pkt(tr);
    end

    phase.drop_objection(this);
endtask

task bus_driver::drive_one_pkt(bus_seq_item tr);
    @(posedge bif.clk)
    if (is_req) begin
        bif.put_req(
            tr.req_bits_addr,
            tr.req_bits_size,
            tr.req_bits_cmd,
            tr.req_bits_wmask,
            tr.req_bits_wdata,
            tr.req_bits_user);
        $display("%s", get_full_name());
        `uvm_info("bus_driver", "put req successfully", UVM_LOW)
        tr.print();
    end
    /*
    else
        `uvm_info("bus_driver", "driver resp", UVM_LOW)
    */
endtask

`endif
