`ifndef CACHE_MODEL__SV
`define CACHE_MODEL__SV

class cache_model extends uvm_component;

   uvm_blocking_get_port #(bus_seq_item)  in_port;
   uvm_analysis_port #(bus_seq_item)      in_ap;
   uvm_blocking_get_port #(bus_seq_item)  mem_port;
   uvm_analysis_port #(bus_seq_item)      mem_ap;

   virtual mask_if mif;

   reg        cache_valid[0:1023][0:3];
   reg        cache_dirty[0:1023][0:3];
   reg [18:0] cache_tag[0:1023][0:3];
   reg [63:0] cache_data[0:1023][0:3];

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);

   task reset();
      for (int i = 0; i < 128; i++) begin
         for (int j = 0; j < 4; j++) begin
            cache_valid[i][j] = 1'b0;
            cache_dirty[i][j] = 1'b0;
            cache_tag[i][j]   = 19'b0;
            cache_data[i][j]  = 64'b0;
         end
      end
   endtask

   task write_back(int setid, int wayid);
      bus_seq_item req = new("req");
      bus_seq_item resp;
      req.is_req = 1'b1;
      req.req_bits_addr[2:0] = 3'b0;
      req.req_bits_addr[12:3] = setid;
      req.req_bits_addr[31:13] = cache_tag[setid][wayid];
      req.req_bits_size = 3'b011;
      req.req_bits_cmd = 4'b0011;
      req.req_bits_wmask = 8'hff;
      req.req_bits_wdata = cache_data[setid][wayid];
      mem_ap.write(req);
      `uvm_info("cache_model", "write_back req", UVM_HIGH)

      mem_port.get(resp);
      `uvm_info("cache_model", "write_back resp", UVM_HIGH)
      assert(resp.req_bits_cmd == 4'b0101);
   endtask

   task fetch(bit [31:0] addr, int wayid);
      bit [18:0] tag = addr[31:13];
      bit [9:0]  setid = addr[12:3];

      bus_seq_item req = new("req");
      bus_seq_item resp;
      req.is_req = 1'b1;
      req.req_bits_addr[31:3] = addr[31:3];
      req.req_bits_addr[2:0] = 3'b0;
      req.req_bits_size = 3'b011;
      req.req_bits_cmd = 4'b0010;
      req.req_bits_wmask = 8'b0;
      req.req_bits_wdata = 64'b0;
      mem_ap.write(req);
      `uvm_info("cache_model", "fetch req", UVM_HIGH)

      mem_port.get(resp);
      `uvm_info("cache_model", "fetch resp", UVM_HIGH)
      assert(resp.resp_bits_cmd == 4'b0110);

      cache_valid[setid][wayid] = 1'b1;
      cache_dirty[setid][wayid] = 1'b0;
      cache_tag[setid][wayid] = tag;
      cache_data[setid][wayid] = resp.resp_bits_rdata;
   endtask

   `uvm_component_utils(cache_model)
endclass

function cache_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction

function void cache_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (!uvm_config_db#(virtual mask_if)::get(this, "", "mif", mif))
         `uvm_fatal("cache_model", "No virtual interface set up.")

   in_port = new("in_port", this);
   in_ap = new("in_ap", this);
   mem_port = new("mem_port", this);
   mem_ap = new("mem_ap", this);
endfunction

task cache_model::main_phase(uvm_phase phase);
   super.main_phase(phase);
   reset();

   while(1) begin
      bit [18:0] req_tag;
      bit [9:0] req_setid;
      int hit_id;
      bus_seq_item req;
      bus_seq_item resp;

      // get resquest
      in_port.get(req);
      `uvm_info("cache_model", "get req", UVM_HIGH)
      req_tag = req.req_bits_addr[31:13];
      req_setid = req.req_bits_addr[12:3];

      // check whether hit or not
      hit_id = -1;
      for (int i = 0; i < 4; i++) begin
         if (cache_valid[req_setid][i] && cache_tag[req_setid][i] == req_tag) begin
            hit_id = i;
            break;
         end
      end

      // miss
      if (hit_id == -1) begin
         // find victim
         int victim_id = -1;
         for (int i = 3; i >= 0 ; i--) begin
            if (!cache_valid[req_setid][i]) begin
               victim_id = i;
               break;
            end
         end

         // need evict
         if (victim_id == -1) begin
            mif.get_mask();
            victim_id = mask2index(mif.victim_way_mask);
            if (cache_dirty[req_setid][victim_id])
               write_back(req_setid, victim_id);
         end

         // fetch data
         fetch(req.req_bits_addr, victim_id);
         hit_id = victim_id;
      end

      // write cache
      if (req.req_bits_cmd == 4'b0001 || req.req_bits_cmd == 4'b0011
            || req.req_bits_cmd == 4'b0111) begin
          cache_dirty[req_setid][hit_id] = 1'b1;
          cache_data[req_setid][hit_id] =
            (cache_data[req_setid][hit_id] & ~req.req_bits_wmask)
            | (req.req_bits_wdata & req.req_bits_wmask);
      end

      // send respond
      resp = new("resp");
      resp.is_req = 1'b0;
      if (req.req_bits_cmd == 4'b0000 || req.req_bits_cmd == 4'b0010) begin
         resp.resp_bits_user  = req.req_bits_user;
         resp.resp_bits_cmd   = 4'b0110;
         resp.resp_bits_rdata = cache_data[req_setid][hit_id];
      end
      else begin
         resp.resp_bits_user  = req.req_bits_user;
         resp.resp_bits_cmd   = 4'b0101;
         resp.resp_bits_rdata = 64'b0;
      end
      in_ap.write(resp);
      `uvm_info("cache_model", "send resp", UVM_HIGH)
   end
endtask
`endif
