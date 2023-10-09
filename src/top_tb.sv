`timescale 1ns/1ps

`include "uvm_pkg.sv"
import uvm_pkg::*;

module top_tb;

initial begin
    $display("uvm-cache");
    $finish();
end

endmodule
