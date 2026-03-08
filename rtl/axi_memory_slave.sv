//==========================================================
// File        : axi_memory_slave.sv
// Author      : Raveem
// Created     : 2026-03-08
// Description : RTL of the AXI memory slave
//==========================================================

module axi_memory_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter MEM_DEPTH  = 1024
)(
    input  logic clk,
    input  logic rst_n,
    axi4_if axi
);

    //========== Internal Memory ==========
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    
endmodule