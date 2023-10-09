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

    function new(string name = "bus_seq_item");
        super.new();
    endfunction

endclass

`endif
