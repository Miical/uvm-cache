`ifndef CACHE_MODEL__SV
`define CACHE_MODEL__SV

class cache_model extends uvm_component;

   uvm_blocking_get_port #(bus_seq_item)  in_port;
   uvm_analysis_port #(bus_seq_item)      in_ap;
   uvm_blocking_get_port #(bus_seq_item)  mem_port;
   uvm_analysis_port #(bus_seq_item)      mem_ap;
   uvm_blocking_get_port #(bus_seq_item)  mmio_port;
   uvm_analysis_port #(bus_seq_item)      mmio_ap;

   virtual mask_if mif;

   reg        cache_empty;
   reg        cache_valid[128][4];
   reg        cache_dirty[128][4];
   reg [18:0] cache_tag[128][4];
   reg [63:0] cache_data[128][4][8];

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);

   task reset();
      for (int i = 0; i < 128; i++) begin
         for (int j = 0; j < 4; j++) begin
            cache_valid[i][j] = 1'b0;
            cache_dirty[i][j] = 1'b0;
            cache_tag[i][j]   = 19'b0;
            for (int k = 0; k < 8; k++)
               cache_data[i][j][k] = 64'b0;
         end
      end
      cache_empty = 1'b0;
   endtask

   task write_back(int setid, int wayid);
      bus_seq_item req = new("req");
      bus_seq_item resp;
      req.tr_type = bus_seq_item::REQ;
      req.req_bits_addr[5:0] = 6'b0;
      req.req_bits_addr[12:6] = setid;
      req.req_bits_addr[31:13] = cache_tag[setid][wayid];
      req.req_bits_cmd = 4'b0011;
      req.req_bits_size = 3'b011;
      req.req_bits_wmask = 8'hff;

      for (int i = 0; i < 7; i++) begin
         req.req_bits_wdata = cache_data[setid][wayid][i];
         mem_ap.write(req);
         mem_port.get(resp);
         assert(resp.resp_bits_cmd == 4'b0101);
      end
      req.req_bits_cmd = 4'b0111;
      req.req_bits_wdata = cache_data[setid][wayid][7];
      mem_ap.write(req);
      mem_port.get(resp);
      assert(resp.resp_bits_cmd == 4'b0101);

      cache_valid[setid][wayid] = 1'b0;
      `uvm_info("cache_model", "write_back", UVM_HIGH)
   endtask

   task fetch(bit [31:0] addr, int wayid, int wordid);
      bit [18:0] tag = addr[31:13];
      bit [9:0]  setid = addr[12:6];

      bus_seq_item req = new("req");
      bus_seq_item resp;
      req.tr_type = bus_seq_item::REQ;
      req.req_bits_addr[31:3] = addr[31:3];
      req.req_bits_addr[2:0] = 3'b0;
      req.req_bits_size = 3'b011;
      req.req_bits_cmd = 4'b0010;
      req.req_bits_wmask = 8'b0;
      req.req_bits_wdata = 64'b0;
      mem_ap.write(req);
      `uvm_info("cache_model", "[fetch] send req", UVM_HIGH)

      mem_port.get(resp);
      `uvm_info("cache_model", "[fetch] get resp", UVM_HIGH)
      assert(resp.resp_bits_cmd == 4'b0000);

      cache_empty = 1'b0;
      cache_valid[setid][wayid] = 1'b1;
      cache_dirty[setid][wayid] = 1'b0;
      cache_tag[setid][wayid] = tag;
      cache_data[setid][wayid][wordid] = resp.resp_bits_rdata;
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
   mmio_port = new("mmio_port", this);
   mmio_ap = new("mmio_ap", this);
endfunction

task cache_model::main_phase(uvm_phase phase);
   super.main_phase(phase);
   reset();

   while(1) begin
      bit [18:0] req_tag;
      bit [6:0] req_setid;
      bit [2:0] req_wordid;
      bit [63:0] bitsmask;
      int hit_id;
      bit need_refill;
      bus_seq_item req;
      bus_seq_item resp;
      bus_seq_item mem_resp;

      // get resquest
      in_port.get(req);
      `uvm_info("cache_model", "get req", UVM_HIGH)
      req_tag = req.req_bits_addr[31:13];
      req_setid = req.req_bits_addr[12:6];
      req_wordid = req.req_bits_addr[5:3];

      // reset
      if (req.rst) begin
         reset();
         continue;
      end

      // mmio
      if (4'h3 <= req.req_bits_addr[31:28] && req.req_bits_addr[31:28] <= 4'h7)
      begin
         mmio_ap.write(req);
         `uvm_info("cache_model", "send req to mmio", UVM_HIGH)
         mmio_port.get(resp);
         `uvm_info("cache_model", "get resp from mmio", UVM_HIGH)
         resp.resp_bits_user = req.req_bits_user;
         in_ap.write(resp);
         `uvm_info("cache_model", "send resp", UVM_HIGH)
         continue;
      end

      // check whether hit or not
      hit_id = -1;
      need_refill = 0;
      for (int i = 0; i < 4; i++) begin
         if (cache_valid[req_setid][i] && cache_tag[req_setid][i] == req_tag)
         begin
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
         fetch(req.req_bits_addr, victim_id, req_wordid);
         need_refill = 1;
         hit_id = victim_id;
      end

      // write cache
      if (req.req_bits_cmd == 4'b0001 || req.req_bits_cmd == 4'b0011
            || req.req_bits_cmd == 4'b0111) begin
          cache_dirty[req_setid][hit_id] = 1'b1;
          bitsmask = bytesmask2bitsmask(req.req_bits_wmask);
          cache_data[req_setid][hit_id][req_wordid] =
            (cache_data[req_setid][hit_id][req_wordid] & ~bitsmask)
            | (req.req_bits_wdata & bitsmask);
      end

      // send respond
      resp = new("resp");
      resp.tr_type = bus_seq_item::RESP;
      resp.resp_bits_user  = req.req_bits_user;
      resp.io_empty = cache_empty;
      if (req.req_bits_cmd == 4'b0000 || req.req_bits_cmd == 4'b0010) begin
         resp.resp_bits_cmd   = 4'b0110;
         resp.resp_bits_rdata = cache_data[req_setid][hit_id][req_wordid];
      end
      else begin
         resp.resp_bits_cmd   = 4'b0101;
         resp.resp_bits_rdata = 64'b0;
      end
      in_ap.write(resp);
      `uvm_info("cache_model", "send resp", UVM_HIGH)

      // refill
      if (need_refill) begin
         int pkt_id = get_packet_id(req.req_bits_addr);
         mem_port.get(mem_resp);
         for (int i = 1; i < 8; i++) begin
            pkt_id = (pkt_id + 1) % 8;
            cache_data[req_setid][hit_id][pkt_id] = mem_resp.mem_resp_rdata[i];
         end
         `uvm_info("cache_model", "refill down", UVM_HIGH)
      end
   end
endtask
`endif
