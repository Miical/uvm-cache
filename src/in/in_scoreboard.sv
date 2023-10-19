`ifndef IN_SCOREBOARD__SV
`define IN_SCOREBOARD__SV
class in_scoreboard extends uvm_scoreboard;
   bus_seq_item  expect_queue[$];
   uvm_blocking_get_port #(bus_seq_item)  exp_port;
   uvm_blocking_get_port #(bus_seq_item)  act_port;
   `uvm_component_utils(in_scoreboard)

   extern function new(string name, uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
endclass

function in_scoreboard::new(string name, uvm_component parent = null);
   super.new(name, parent);
endfunction

function void in_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
   exp_port = new("exp_port", this);
   act_port = new("act_port", this);
endfunction

task in_scoreboard::main_phase(uvm_phase phase);
   while(1) begin
      bus_seq_item tr;
      exp_port.get(tr);
      `uvm_info("in_scoreboard", "get exp transaction", UVM_LOW)

      act_port.get(tr);
      `uvm_info("in_scoreboard", "get act transaction", UVM_LOW)
   end

endtask
`endif