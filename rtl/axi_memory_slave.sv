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
    //---------- Internal signals ----------    
    logic [ADDR_WIDTH-1: 0] addr_index, araddr_reg;
    logic [ID_WIDTH-1:0]    awid_reg;
    logic [7:0]   awlen_reg;
    logic [2:0]   awsize_reg;

    //========== Internal Memory ==========
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    
    //========== initialization ==========
    // initial begin
    //     axi.awready = 0;
    //     axi.wready  = 0;
    //     axi.bvalid  = 0;
    //     axi.arready = 0;
    //     axi.rvalid  = 0;    
    // end

    //========== Write FSM ==========

    // // Write to memory
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         mem <= '{default:0};
    //     end
    //     else if (axi.wvalid && axi.wready && (waddr < 1024)) begin
            
    //         waddr       <= waddr + 1;
    //     end
    // end
    // Write states
    typedef enum {
        W_IDLE,
        W_DATA,
        W_RESP
    } wstate_t;

    wstate_t wstate, next_wstate;

    //---------- state register logic ----------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wstate <= W_IDLE;
        end else begin
            wstate <= next_wstate;
        end
    end
    
    //---------- next state logic ----------
    always_comb begin
        axi.awready = 0;
        axi.wready  = 0;
        axi.bvalid  = 0;

        next_wstate = wstate;

        case (wstate)
            W_IDLE : begin
                axi.awready = 1;
                if (axi.awvalid)
                    next_wstate = W_DATA;
            end

            W_DATA : begin
                axi.wready  = 1;
                if (axi.wlast && axi.wvalid)
                    next_wstate = W_RESP;
            end

            W_RESP : begin
                axi.bvalid  = 1;
                if (axi.bready)
                    next_wstate = W_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.awready <= 0;
            axi.wready  <= 0;
            axi.bvalid  <= 0;
            axi.bid     <= 0;
            axi.bresp   <= 0;
        end
        else begin
            case (wstate)
                W_IDLE  : begin
                    if (axi.awvalid && axi.awready) begin
                        addr_index  <= axi.awaddr >> 2;
                        awid_reg    <= axi.awid;
                        awlen_reg   <= axi.awlen;
                        awsize_reg  <= axi.awsize;
                    end
                end
                
                W_DATA  : begin
                    if (axi.wvalid && axi.wready) begin
                        $display("Writing to memory");
                        mem[addr_index]  <= axi.wdata;
                        addr_index <= addr_index + 1;
                    end
                    
                end

                W_RESP  : begin
                    axi.bid     <= axi.awid;
                    axi.bresp   <= (axi.awaddr < MEM_DEPTH * 4) ? 2'b00 : 2'b01;
                end

            endcase
        end 
    end

    // // output logic
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         axi.bid     <= 0;
    //         axi.bresp   <= 0;
    //         axi.bvalid  <= 0;
    //     end else if (axi.wvalid && axi.wlast) begin
    //         axi.bresp   <= (waddr < MEM_DEPTH) ? 2'b00 : 2'b01;
    //         axi.bvalid  <= 1;
    //     end
    // end

    // gated log
    always_ff @(posedge clk or negedge rst_n) begin
        $display("%t [DUT] %s awready=%0d awvalid=%0b awaddr=%0h awid=%0h", $time, wstate.name(), axi.awready, axi.awvalid, axi.awaddr, axi.awid);
        $display("%t [DUT] %s wready=%0d wvalid=%0b wdata=%0h wstrb=%0d wlast=%0b", $time, wstate.name(), axi.wready, axi.wvalid, axi.wdata, axi.wstrb, axi.wlast);
        $display("%t [DUT] %s bvalid=%0b bresp=%0d bid=%0h", $time, wstate.name(), axi.bvalid, axi.bresp, axi.bid);
        // $display("address awaddr=%0h waddr_reg=%0h", axi.awaddr, addr_index);
        // $display("%t address memory [%0h] = %0h", $time, addr_index, mem[addr_index]);
    end
endmodule