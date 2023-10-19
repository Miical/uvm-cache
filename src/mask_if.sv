`ifndef MASK__IF
`define MASK__IF

interface mask_if(input clk, input rst);
    logic victim_way_mask_valid;
    logic [3:0] victim_way_mask;

    task get_mask();
        while (1) begin
            @(posedge clk)
                if (victim_way_mask_valid) break;
        end
    endtask
endinterface

`endif
