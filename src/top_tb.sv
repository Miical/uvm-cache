`timescale 1ns/1ps

`include "uvm_pkg.sv"
import uvm_pkg::*;

`include "src/simplebus_if.sv"
`include "src/bus_seq_item.sv"
`include "src/components/bus_driver.sv"
`include "src/components/bus_monitor.sv"
`include "src/components/bus_agent.sv"
`include "src/components/cache_env.sv"
`include "src/components/top_env.sv"

module top_tb;

reg       clk;
reg       rst;
reg [1:0] io_flush;
reg       io_empty;

simplebus_if in_if(clk, rst, io_flush, io_empty);
simplebus_if mem_if(clk, rst, io_flush, io_empty);
simplebus_if coh_if(clk, rst, io_flush, io_empty);
simplebus_if mmio_if(clk, rst, io_flush, io_empty);

Cache cache(.clock(clk),
            .reset(rst),
            .io_flush(io_flush),
            .io_empty(io_empty),

            .io_in_req_ready(in_if.req_ready),
            .io_in_req_valid(in_if.req_valid),
            .io_in_req_bits_addr(in_if.req_bits_addr),
            .io_in_req_bits_size(in_if.req_bits_size),
            .io_in_req_bits_cmd(in_if.req_bits_cmd),
            .io_in_req_bits_wmask(in_if.req_bits_wmask),
            .io_in_req_bits_wdata(in_if.req_bits_wdata),
            .io_in_req_bits_user(in_if.req_bits_user),
            .io_in_resp_ready(in_if.resp_ready),
            .io_in_resp_valid(in_if.resp_valid),
            .io_in_resp_bits_cmd(in_if.resp_bits_cmd),
            .io_in_resp_bits_rdata(in_if.resp_bits_rdata),
            .io_in_resp_bits_user(in_if.resp_bits_user),

            .io_out_mem_req_ready(mem_if.req_ready),
            .io_out_mem_req_valid(mem_if.req_valid),
            .io_out_mem_req_bits_addr(mem_if.req_bits_addr),
            .io_out_mem_req_bits_size(mem_if.req_bits_size),
            .io_out_mem_req_bits_cmd(mem_if.req_bits_cmd),
            .io_out_mem_req_bits_wmask(mem_if.req_bits_wmask),
            .io_out_mem_req_bits_wdata(mem_if.req_bits_wdata),
            .io_out_mem_resp_ready(mem_if.resp_ready),
            .io_out_mem_resp_valid(mem_if.resp_valid),
            .io_out_mem_resp_bits_cmd(mem_if.resp_bits_cmd),
            .io_out_mem_resp_bits_rdata(mem_if.resp_bits_rdata),

            .io_out_coh_req_ready(coh_if.req_ready),
            .io_out_coh_req_valid(coh_if.req_valid),
            .io_out_coh_req_bits_addr(coh_if.req_bits_addr),
            .io_out_coh_req_bits_size(coh_if.req_bits_size),
            .io_out_coh_req_bits_cmd(coh_if.req_bits_cmd),
            .io_out_coh_req_bits_wmask(coh_if.req_bits_wmask),
            .io_out_coh_req_bits_wdata(coh_if.req_bits_wdata),
            .io_out_coh_resp_ready(coh_if.resp_ready),
            .io_out_coh_resp_valid(coh_if.resp_valid),
            .io_out_coh_resp_bits_cmd(coh_if.resp_bits_cmd),
            .io_out_coh_resp_bits_rdata(coh_if.resp_bits_rdata),

            .io_mmio_req_ready(mmio_if.req_ready),
            .io_mmio_req_valid(mmio_if.req_valid),
            .io_mmio_req_bits_addr(mmio_if.req_bits_addr),
            .io_mmio_req_bits_size(mmio_if.req_bits_size),
            .io_mmio_req_bits_cmd(mmio_if.req_bits_cmd),
            .io_mmio_req_bits_wmask(mmio_if.req_bits_wmask),
            .io_mmio_req_bits_wdata(mmio_if.req_bits_wdata),
            .io_mmio_resp_ready(mmio_if.resp_ready),
            .io_mmio_resp_valid(mmio_if.resp_valid),
            .io_mmio_resp_bits_cmd(mmio_if.resp_bits_cmd),
            .io_mmio_resp_bits_rdata(mmio_if.resp_bits_rdata));

initial begin
    run_test("top_env");
    $finish();
end

initial begin
    clk = 0;
    forever begin
       #100 clk = ~clk;
    end
 end

 initial begin
    io_flush = 2'b00;
    rst = 1'b1;
    #200;
    rst = 1'b0;
 end

 /*
 initial begin
   forever begin
      #100
      if (mem_if.req_valid == 1 || in_if.resp_valid == 1 || mmio_if.req_valid == 1) begin
         $display("in_if");
         in_if.print();
         $display("mem_if");
         mem_if.print();
         $display("okk");
         $finish();
     end
  end
end
*/

 initial begin
   mem_if.req_ready <= 1'b0;
   mem_if.resp_valid <= 1'b0;
   mem_if.resp_bits_cmd <= 4'b0000;
   mem_if.resp_bits_rdata <= 64'h0000000000000000;

   mmio_if.req_ready <= 1'b0;
   mmio_if.resp_valid <= 1'b0;
   mmio_if.resp_bits_cmd <= 4'b0000;
   mmio_if.resp_bits_rdata <= 64'h0000000000000000;

   coh_if.req_valid <= 1'b0;
   coh_if.req_bits_addr <= 32'h00000000;
   coh_if.req_bits_size <= 2'b00;
   coh_if.req_bits_cmd <= 4'b0000;
   coh_if.req_bits_wmask <= 8'b00000000;
   coh_if.req_bits_wdata <= 16'h0000;
   coh_if.resp_ready <= 1'b0;

   in_if.req_valid <= 1'b0;
   in_if.req_bits_addr <= 32'h00000000;
   in_if.req_bits_size <= 2'b00;
   in_if.req_bits_cmd <= 4'b0000;
   in_if.req_bits_wmask <= 8'b00000000;
   in_if.req_bits_wdata <= 64'h0000000000000000;
   in_if.req_bits_user <= 16'h0000;
   in_if.resp_ready <= 1'b0;
 end

 initial begin
    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.in_env.i_agt.drv", "bif", in_if);
    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.in_env.i_agt.mon", "bif", in_if);
    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.in_env.o_agt.mon", "bif", in_if);

    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.mem_env.i_agt.drv", "bif", mem_if);
    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.mem_env.i_agt.mon", "bif", mem_if);
    uvm_config_db#(virtual simplebus_if)::set(null, "uvm_test_top.mem_env.o_agt.mon", "bif", mem_if);
 end

endmodule
