`ifndef BUS_MONITOR__SV
`define BUS_MONITOR__SV

class bus_monitor extends uvm_monitor;

    virtual simplebus_if bif;

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
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        tr.print();
    end
endtask

task bus_monitor::collect_one_pkt(bus_seq_item tr);
    @(posedge bif.clk)
    tr.is_inreq <= 0;
    tr.is_upstream <= 1;

    tr.resp_bits_user <= bif.resp_bits_user;
    tr.io_empty <= bif.io_empty;
    tr.req_ready <= bif.req_ready;
    tr.resp_valid <= bif.resp_valid;
    tr.resp_bits_cmd <= bif.resp_bits_cmd;
    tr.resp_bits_rdata <= bif.resp_bits_rdata;
endtask

`endif
