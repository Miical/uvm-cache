`ifndef CACHE__IF
`define CACHE__IF

interface cache_if(input clk);
    logic       rst;
    logic       io_empty;
    logic [1:0] io_flush;
endinterface

`endif
