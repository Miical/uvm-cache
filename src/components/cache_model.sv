`ifndef CACHE_MODEL__SV
`define CACHE_MODEL__SV

class cache_model extends uvm_component;

   // uvm_blocking_get_port #(bus_seq_item)  in_port;
   // uvm_analysis_port #(bus_seq_item)  in_ap;
   uvm_blocking_get_port #(bus_seq_item)  mem_port;
   uvm_analysis_port #(bus_seq_item)  mem_ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);

   `uvm_component_utils(cache_model)
endclass

function cache_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction

function void cache_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   // in_port = new("in_port", this);
   // in_ap = new("in_ap", this);
   mem_port = new("mem_port", this);
   mem_ap = new("mem_ap", this);
endfunction

task cache_model::main_phase(uvm_phase phase);
   super.main_phase(phase);
   while(1) begin
      // `uvm_info("cache_model", "get one transaction, copy and print it:", UVM_LOW)
   end
endtask
`endif
