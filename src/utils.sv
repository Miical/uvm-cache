`ifndef UTILS__SV
`define UTILS__SV

function bit [63:0] bytesmask2bitsmask(bit [8:0] bytesmask);
    bit [63:0] bitsmask;
    for (int i = 0; i < 8; i++) begin
        for (int j = i * 8; j < i * 8 + 8; j++) begin
            bitsmask[j] = (bytesmask >> i) & 1;
        end
    end
    return bitsmask;
endfunction

function int mask2index(bit [3:0] mask);
    for (int i = 0; i < 4; i++)
        if ((1 << i) & mask)
            return i;
    return -1;
endfunction

`endif
