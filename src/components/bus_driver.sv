`ifndef BUS_DRIVER__SV
`define BUS_DRIVER__SV

class bus_driver extends uvm_driver#(bus_seq_item);

    virtual simplebus_if bif;

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

    while(!top_tb.rst)
        @(posedge top_tb.clk);

    for (int i = 0; i < 16; i++) begin
        tr = new("tr");
        assert(tr.randomize() with { is_inreq == 1; is_upstream == 1; });
        `uvm_info("bus_driver", $sformatf("addr = %x", tr.req_bits_addr), UVM_LOW)
        tr.print();
        drive_one_pkt(tr);
    end

    phase.drop_objection(this);
endtask

task bus_driver::drive_one_pkt(bus_seq_item tr);
    @(posedge bif.clk);
    bif.req_valid <= tr.req_valid;
    bif.req_bits_addr <= tr.req_bits_addr;
    bif.req_bits_size <= tr.req_bits_size;
    bif.req_bits_cmd <= tr.req_bits_cmd;
    bif.req_bits_wmask <= tr.req_bits_wmask;
    bif.req_bits_wdata <= tr.req_bits_wdata;
    bif.req_bits_user <= tr.req_bits_user;
    bif.resp_ready <= tr.resp_ready;
    bif.io_flush <= tr.io_flush;
endtask

`endif
