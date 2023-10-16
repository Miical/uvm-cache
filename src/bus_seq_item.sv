`ifndef BUS_SEQ_ITEM__SV
`define BUS_SEQ_ITEM__SV

class bus_seq_item extends uvm_sequence_item;
    rand bit [1:0]  io_flush;
    rand bit        io_empty;

    rand bit [31:0] req_bits_addr;
    rand bit [2:0]  req_bits_size;
    rand bit [3:0]  req_bits_cmd;
    rand bit [7:0]  req_bits_wmask;
    rand bit [63:0] req_bits_wdata;
    rand bit [15:0] req_bits_user;

    rand bit [3:0]  resp_bits_cmd;
    rand bit [63:0] resp_bits_rdata;
    rand bit [15:0] resp_bits_user;

    rand bit        is_req;

    `uvm_object_utils_begin(bus_seq_item)
        if (is_req) begin
            `uvm_field_int(req_bits_user, UVM_ALL_ON)
            // `uvm_field_int(io_flush, UVM_ALL_ON)
            `uvm_field_int(req_bits_addr, UVM_ALL_ON)
            `uvm_field_int(req_bits_size, UVM_ALL_ON)
            `uvm_field_int(req_bits_cmd, UVM_ALL_ON)
            `uvm_field_int(req_bits_wmask, UVM_ALL_ON)
            `uvm_field_int(req_bits_wdata, UVM_ALL_ON)
        end
        else begin
            `uvm_field_int(resp_bits_user, UVM_ALL_ON)
            `uvm_field_int(io_empty, UVM_ALL_ON)
            `uvm_field_int(resp_bits_cmd, UVM_ALL_ON)
            `uvm_field_int(resp_bits_rdata, UVM_ALL_ON)
        end
        `uvm_field_int(is_req, UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "bus_seq_item");
        super.new();
    endfunction

    constraint default_cons {
        req_bits_addr >= 32'h80000000;
    }

endclass

`endif
