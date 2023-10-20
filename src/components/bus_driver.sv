`ifndef BUS_DRIVER__SV
`define BUS_DRIVER__SV

class bus_driver extends uvm_driver#(bus_seq_item);

    virtual simplebus_if bif;

    bus_seq_item::Type tr_type;

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
    extern task get_response(bus_seq_item tr);
endclass


task bus_driver::main_phase(uvm_phase phase);
    while (bif.rst)
        @(posedge bif.clk);

    // Receive a empty req without sending it, and wait for rsp,
    if (tr_type != bus_seq_item::REQ) begin
        seq_item_port.get_next_item(req);
        rsp = new("rsp");
        rsp.tr_type = tr_type;
        rsp.set_id_info(req);
        get_response(rsp);
        seq_item_port.put_response(rsp);
        seq_item_port.item_done();
    end

    while (1) begin
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);

        rsp = new("rsp");
        rsp.tr_type = tr_type;
        rsp.set_id_info(req);
        get_response(rsp);

        seq_item_port.put_response(rsp);
        seq_item_port.item_done();
    end
endtask

task bus_driver::drive_one_pkt(bus_seq_item tr);
    if (tr.tr_type == bus_seq_item::REQ) begin
        bif.put_req(
            tr.req_bits_addr,
            tr.req_bits_size,
            tr.req_bits_cmd,
            tr.req_bits_wmask,
            tr.req_bits_wdata,
            tr.req_bits_user);
        `uvm_info("bus_driver",
            $sformatf("%s : put req successfully", get_full_name()), UVM_HIGH)
    end
    else if (tr.tr_type == bus_seq_item::RESP) begin
        bif.put_resp(
            tr.resp_bits_cmd,
            tr.resp_bits_rdata,
            tr.resp_bits_user);
        `uvm_info("bus_driver",
            $sformatf("%s : put resp successfully", get_full_name()), UVM_HIGH)
    end
    else if (tr.tr_type == bus_seq_item::MEM_RESP) begin
        bif.put_mem_resp(
            tr.mem_resp_rdata,
            tr.req_bits_addr);
        `uvm_info("bus_driver",
            $sformatf("%s : put mem_resp successfully", get_full_name()), UVM_HIGH)
    end
endtask

task bus_driver::get_response(bus_seq_item tr);
    if (tr_type == bus_seq_item::RESP || tr_type == bus_seq_item::MEM_RESP) begin
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
    end
endtask

`endif
