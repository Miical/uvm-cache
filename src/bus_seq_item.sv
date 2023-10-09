`ifndef BUS_SEQ_ITEM__SV
`define BUS_SEQ_ITEM__SV

class bus_seq_item extends uvm_sequence_item;
    rand bit [1:0]  io_flush;
    rand bit        io_empty;

    rand bit        req_ready;
    rand bit        req_valid;
    rand bit [31:0] req_bits_addr;
    rand bit [2:0]  req_bits_size;
    rand bit [3:0]  req_bits_cmd;
    rand bit [7:0]  req_bits_wmask;
    rand bit [63:0] req_bits_wdata;
    rand bit [15:0] req_bits_user;

    rand bit        resp_ready;
    rand bit        resp_valid;
    rand bit [3:0]  resp_bits_cmd;
    rand bit [63:0] resp_bits_rdata;
    rand bit [15:0] resp_bits_user;

    rand bit        is_inreq;    // Whether to input to the bus.
    rand bit        is_upstream; // Whether to interact with upstream.

    `uvm_object_utils_begin(bus_seq_item)
        if (is_inreq) begin
            if (is_upstream) begin
                `uvm_field_int(req_bits_user, UVM_ALL_ON)
                `uvm_field_int(io_flush, UVM_ALL_ON)
            end
            `uvm_field_int(resp_ready, UVM_ALL_ON)
            `uvm_field_int(req_valid, UVM_ALL_ON)
            `uvm_field_int(req_bits_addr, UVM_ALL_ON)
            `uvm_field_int(req_bits_size, UVM_ALL_ON)
            `uvm_field_int(req_bits_cmd, UVM_ALL_ON)
            `uvm_field_int(req_bits_wmask, UVM_ALL_ON)
            `uvm_field_int(req_bits_wdata, UVM_ALL_ON)
        end
        else begin
            if (is_upstream) begin
                `uvm_field_int(resp_bits_user, UVM_ALL_ON)
                `uvm_field_int(io_empty, UVM_ALL_ON)
            end
            `uvm_field_int(req_ready, UVM_ALL_ON)
            `uvm_field_int(resp_valid, UVM_ALL_ON)
            `uvm_field_int(resp_bits_cmd, UVM_ALL_ON)
            `uvm_field_int(resp_bits_rdata, UVM_ALL_ON)
        end
        `uvm_field_int(is_inreq, UVM_NOPACK)
        `uvm_field_int(is_upstream, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "bus_seq_item");
        super.new();
    endfunction

endclass

`endif
