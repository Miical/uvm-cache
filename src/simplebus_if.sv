`ifndef SIMPLEBUS__IF
`define SIMPLEBUS__IF

interface simplebus_if(input clk, input rst, input[1:0] io_flush, input io_empty);
    logic        req_ready;
    logic        req_valid;
    logic [31:0] req_bits_addr;
    logic [2:0]  req_bits_size;
    logic [3:0]  req_bits_cmd;
    logic [7:0]  req_bits_wmask;
    logic [63:0] req_bits_wdata;
    logic [15:0] req_bits_user;

    logic        resp_ready;
    logic        resp_valid;
    logic [3:0]  resp_bits_cmd;
    logic [63:0] resp_bits_rdata;
    logic [15:0] resp_bits_user;

    task put_req(input [31:0] addr,
                 input [2:0] size,
                 input [3:0] cmd,
                 input [7:0] wmask,
                 input [63:0] wdata,
                 input [15:0] user);
        while (1) begin
            @(posedge clk)
            if (req_ready) begin
                req_valid <= 1'b1;
                resp_ready <= 1'b1;
                req_bits_addr <= addr;
                req_bits_size <= size;
                req_bits_cmd <= cmd;
                req_bits_wmask <= wmask;
                req_bits_wdata <= wdata;
                req_bits_user <= user;
                break;
            end
        end
        @(posedge clk)
            req_valid <= 0;
    endtask

    task get_resp();
        while (1) begin
            @(posedge clk)
                if (resp_valid) break;
        end
    endtask

    task get_req();
        while (1) begin
            @(posedge clk)
                if (req_valid) break;
        end
    endtask

    task put_resp(input [3:0] cmd,
                  input [63:0] rdata,
                  input  [15:0] user);
        while (1) begin
            @(posedge clk)
            if (resp_ready) begin
                resp_valid <= 1'b1;
                resp_bits_cmd <= cmd;
                resp_bits_rdata <= rdata;
                resp_bits_user <= user;
                break;
            end
        end
        @(posedge clk)
            resp_valid <= 1'b0;
    endtask

    task print();
        $display("---------- Simplebuf Interface -----------");
        $display("req_ready = %x", req_ready);
        $display("req_valid = %x", req_valid);
        $display("req_bits_addr = %x", req_bits_addr);
        $display("req_bits_size = %x", req_bits_size);
        $display("req_bits_cmd = %x", req_bits_cmd);
        $display("req_bits_wmask = %x", req_bits_wmask);
        $display("req_bits_wdata = %x", req_bits_wdata);
        $display("req_bits_user = %x", req_bits_user);

        $display("resp_ready = %x", resp_ready);
        $display("resp_valid = %x", resp_valid);
        $display("resp_bits_cmd = %x", resp_bits_cmd);
        $display("resp_bits_rdata = %x", resp_bits_rdata);
        $display("resp_bits_user = %x", resp_bits_user);

        $display("io_flush = %x", io_flush);
        $display("io_empty = %x", io_empty);
        $display("------------------------------------------");
    endtask

endinterface

`endif
