`ifndef SIMPLEBUS__IF
`define SIMPLEBUS__IF

interface simplebus_if(input clk, input rst, input[1:0] io_flush, input io_empty);
    logic        req_ready;
    logic        req_valid;
    logic [31:0] req_bits_addr;
    logic [2:0]  req_bits_size;
    logic [3:0]  req_bits_cmd;
    logic [7:0]  req_bits_wmask;
    logic [63:0] req_bits_wdata;
    logic [15:0] req_bits_user;

    logic        resp_ready;
    logic        resp_valid;
    logic [3:0]  resp_bits_cmd;
    logic [63:0] resp_bits_rdata;
    logic [15:0] resp_bits_user;
endinterface

`endif
