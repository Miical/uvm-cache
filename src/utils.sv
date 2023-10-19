`ifndef UTILS__SV
`define UTILS__SV

function int mask2index(bit [3:0] mask);
    for (int i = 0; i < 4; i++)
        if ((1 << i) & mask)
            return i;
    return -1;
endfunction

`endif
