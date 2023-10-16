`ifndef BUS_MONITOR__SV
`define BUS_MONITOR__SV

class bus_monitor extends uvm_monitor;

    virtual simplebus_if bif;

    int is_req;
    int is_active;

    `uvm_component_utils(bus_monitor)
    function new(string name = "bus_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual simplebus_if)::get(this, "", "bif", bif))
            `uvm_fatal("bus_monitor", "No virtual interface set up.")
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(bus_seq_item tr);
endclass

task bus_monitor::main_phase(uvm_phase phase);
    bus_seq_item tr;
    tr = new("tr");
    if (is_req)
        assert(tr.randomize() with { is_req == 1; });
    else
        assert(tr.randomize() with { is_req == 0; });

    while(top_tb.rst)
        @(posedge top_tb.clk);

    /*
    while(1) begin
        collect_one_pkt(tr);
    end
    */

    for (int i = 0; i < 2; i += 1) begin
        collect_one_pkt(tr);
        $display("%s", get_full_name());
        `uvm_info("bus_monitor", "monitor req", UVM_LOW)
        tr.print();
    end
    $finish();
endtask

task bus_monitor::collect_one_pkt(bus_seq_item tr);
    if (is_req) begin
        bif.get_req();
        tr.io_flush = bif.io_flush;
        tr.req_bits_addr = bif.req_bits_addr;
        tr.req_bits_size = bif.req_bits_size;
        tr.req_bits_cmd = bif.req_bits_cmd;
        tr.req_bits_wmask = bif.req_bits_wmask;
        tr.req_bits_wdata = bif.req_bits_wdata;
        tr.req_bits_user = bif.req_bits_user;
    end
    else begin
        bif.get_resp();
        tr.io_empty = bif.io_empty;
        tr.resp_bits_cmd = bif.resp_bits_cmd;
        tr.resp_bits_rdata = bif.resp_bits_rdata;
        tr.resp_bits_user = bif.resp_bits_user;
        `uvm_info("bus_monitor", "monitor resp", UVM_LOW)
        tr.print();
    end
endtask

`endif
