`ifndef BUS_MONITOR__SV
`define BUS_MONITOR__SV

class bus_monitor extends uvm_monitor;

    virtual simplebus_if bif;

    bus_seq_item::Type tr_type;

    uvm_analysis_port #(bus_seq_item) ap;

    `uvm_component_utils(bus_monitor)
    function new(string name = "bus_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual simplebus_if)::get(this, "", "bif", bif))
            `uvm_fatal("bus_monitor", "No virtual interface set up.")
        ap = new("ap", this);
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(bus_seq_item tr);
endclass

task bus_monitor::main_phase(uvm_phase phase);
    bus_seq_item tr;
    tr = new("tr");
    if (tr_type == bus_seq_item::REQ)
        tr.tr_type = bus_seq_item::REQ;
    else
        tr.tr_type = bus_seq_item::RESP;

    while (bif.rst)
        @(posedge bif.clk);

    while(1) begin
        collect_one_pkt(tr);
    end
endtask

task bus_monitor::collect_one_pkt(bus_seq_item tr);
    bus_seq_item mtr;
    if (tr_type == bus_seq_item::REQ) begin
        while (1) begin
            @(posedge bif.clk)
                if (!bif.req_valid) break;
        end
        bif.get_req();
        tr.rst = bif.rst;
        tr.io_flush = bif.io_flush;
        tr.req_bits_addr = bif.req_bits_addr;
        tr.req_bits_size = bif.req_bits_size;
        tr.req_bits_cmd = bif.req_bits_cmd;
        tr.req_bits_wmask = bif.req_bits_wmask;
        tr.req_bits_wdata = bif.req_bits_wdata;
        tr.req_bits_user = bif.req_bits_user;
        `uvm_info("bus_monitor",
            $sformatf("%s : monitor req", get_full_name()), UVM_HIGH)
        ap.write(tr);
    end
    else begin
        while (1) begin
            @(posedge bif.clk)
                if (!bif.resp_valid) break;
        end
        bif.get_resp();
        tr.io_empty = bif.io_empty;
        tr.resp_bits_cmd = bif.resp_bits_cmd;
        tr.resp_bits_rdata = bif.resp_bits_rdata;
        tr.resp_bits_user = bif.resp_bits_user;
        `uvm_info("bus_monitor",
            $sformatf("%s : monitor resp", get_full_name()), UVM_HIGH)
        ap.write(tr);

        if (tr.resp_bits_cmd == 4'b0000 && tr_type == bus_seq_item::MEM_RESP) begin
            mtr = new("mtr");
            mtr.tr_type = bus_seq_item::MEM_RESP;
            mtr.mem_resp_rdata[0] = bif.resp_bits_rdata;
            for (int i = 1; i < 8; i++) begin
                @(posedge bif.clk);
                mtr.mem_resp_rdata[i] = bif.resp_bits_rdata;
            end
            ap.write(mtr);
        end
    end
endtask

`endif
