`ifndef MEM_SCOREBOARD__SV
`define MEM_SCOREBOARD__SV
class mem_scoreboard extends uvm_scoreboard;
    bus_seq_item  expect_queue[$];
    uvm_blocking_get_port #(bus_seq_item)  exp_port;
    uvm_blocking_get_port #(bus_seq_item)  act_port;
    `uvm_component_utils(mem_scoreboard)

    extern function new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

    extern function bit tr_compare(bus_seq_item a, bus_seq_item b);
endclass

function mem_scoreboard::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

function void mem_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
    act_port = new("act_port", this);
endfunction

function bit mem_scoreboard::tr_compare(bus_seq_item a, bus_seq_item b);
    if (a.req_bits_cmd != b.req_bits_cmd) return 0;
    if (a.req_bits_addr != b.req_bits_addr) return 0;
    if (a.req_bits_size != b.req_bits_size) return 0;
    if (a.req_bits_cmd == 4'b0001 || a.req_bits_cmd == 4'b0011 || a.req_bits_cmd == 4'b0111) begin
        if (a.req_bits_wmask != b.req_bits_wmask) return 0;
        if (a.req_bits_wdata != b.req_bits_wdata) return 0;
    end
    return 1;
endfunction

task mem_scoreboard::main_phase(uvm_phase phase);
    bus_seq_item get_expect,  get_actual, tmp_tran;
    bit result;

    super.main_phase(phase);
    fork
        while (1) begin
            exp_port.get(get_expect);
            expect_queue.push_back(get_expect);
        end
        while (1) begin
            act_port.get(get_actual);
            if(expect_queue.size() > 0) begin
                tmp_tran = expect_queue.pop_front();
                result = tr_compare(get_actual, tmp_tran);
                if(result) begin
                    `uvm_info(get_full_name(), "Compare SUCCESSFULLY", UVM_MEDIUM);
                end
                else begin
                    `uvm_error(get_full_name(), "Compare FAILED");
                    $display("the expect pkt is");
                    tmp_tran.print();
                    $display("the actual pkt is");
                    get_actual.print();
                end
            end
            else begin
                `uvm_error(get_full_name(), "Received from DUT, while Expect Queue is empty");
                $display("the unexpected pkt is");
                get_actual.print();
            end
        end
    join
endtask
`endif
