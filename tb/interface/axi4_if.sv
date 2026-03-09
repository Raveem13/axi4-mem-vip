//==========================================================
// File        : axi4_if.sv
// Author      : Raveem
// Created     : 2026-03-08
// Description : AXI4 interface definition
//==========================================================

interface axi4_if #(
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH   = 4;
)   
    logic   clk;
    logic   rst_n;

    //========== write address channel ==========
    logic   awready;
    logic   [ADDR_WIDTH-1:0]  awaddr;
    logic   [7:0] awlen;
    logic   [2:0] awsize;
    logic   [1:0] awburst;
    logic   [ID_WIDTH-1:0]    awid;
    logic   awvalid;

    //========== write data channel ==========
    logic   wvalid;
    logic   wready;
    logic   [DATA_WIDTH-1:0]  wdata;
    logic   [ID_WIDTH-1:0]    wid;
    logic   [(DATA_WIDTH/8)-1:0] wstrb;
    logic   wlast;
    
    //========== write response channel ==========
    logic   bvalid;
    logic   bready;
    logic   [ID_WIDTH-1:0] bid;
    logic   [1:0] bresp;
    
    //========== read address channel ==========
    logic   arvalid;
    logic   arready;
    logic   [ADDR_WIDTH-1:0] araddr;
    logic   [ID_WIDTH-1:0] arid;
    logic   [7:0] arlen;
    logic   [2:0] arsize;
    logic   [1:0] arburst;

    //=========== read data channel =========
    logic rvalid;
    logic rready;
    logic [DATA_WIDTH-1:0] rdata;
    logic [ID_WIDTH-1:0] rid;
    logic [1:0] rresp;
    logic rlast;

    //---------- Master modport (Driver) ----------
    modport master (
        input clk, rst_n,
        output awvalid, awaddr, awid,
        output awlen, awsize, awburst,
        output wvalid, wdata, wid, wstrb, wlast,
        output bready,
        output arvalid, araddr, arid,
        output arlen, arsize, arburst,

        input awready, wready,
        input arready, rready,
        input rvalid, rdata, rid, rresp, rlast,
    );

    //---------- Slave modport (DUT) ----------
    modport master (
        input clk, rst_n,
        input awvalid, awaddr, awid,
        input awlen, awsize, awburst,
        input wvalid, wdata, wid, wstrb, wlast,
        input bready,
        input arvalid, araddr, arid,
        input arlen, arsize, arburst,

        output awready, wready,
        output arready, rready,
        output rvalid, rdata, rid, rresp, rlast,
    );
endinterface