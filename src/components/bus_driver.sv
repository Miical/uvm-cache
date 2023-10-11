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

    for (int i = 0; i < 32; i++) begin
        tr = new("tr");
        if (is_req)
            assert(tr.randomize() with { is_req == 1; });
        else
            assert(tr.randomize() with { is_req == 0; });
        // `uvm_info("bus_driver", $sformatf("addr = %d", bif.req_bits_addr), UVM_LOW)
        drive_one_pkt(tr);
    end

    phase.drop_objection(this);
endtask

task bus_driver::drive_one_pkt(bus_seq_item tr);
    @(posedge bif.clk)
    if (is_req) begin
        `uvm_info("bus_driver", "driver req", UVM_LOW)

        // tr.print();
        /*
        bif.put_req(
            tr.req_bits_addr,
            tr.req_bits_size,
            tr.req_bits_cmd,
            tr.req_bits_wmask,
            tr.req_bits_wdata,
            tr.req_bits_user);
            */
            /*
        bif.put_req(
            32'h00007000,
            2'h3,
            4'b0000,
            8'h00,
            64'h0000000000000000,
            16'haaaa
        );
        */
    end
    else
        `uvm_info("bus_driver", "driver resp", UVM_LOW)
endtask

`endif
