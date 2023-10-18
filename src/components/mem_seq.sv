`ifndef MEM_SEQ__SV
`define MEM_SEQ__SV

class mem_seq extends uvm_sequence #(bus_seq_item);
    bus_seq_item tr;

    function new(string name= "mem_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("mem_seq", "mem_seq run", UVM_MEDIUM)
        `uvm_do(tr)

        while(1) begin
            get_response(rsp);
            `uvm_info("mem_seq", "get response", UVM_MEDIUM)

            if (rsp.req_bits_cmd == 4'b0000 || rsp.req_bits_cmd == 4'b0010)
                `uvm_do_with(tr, { is_req == 0; resp_bits_cmd == 4'b0110; })
            else
                `uvm_do_with(tr, { is_req == 0; resp_bits_cmd == 4'b0101; })
            `uvm_info("mem_seq", "send transaction", UVM_MEDIUM)
        end
    endtask

    `uvm_object_utils(mem_seq)
 endclass

`endif
