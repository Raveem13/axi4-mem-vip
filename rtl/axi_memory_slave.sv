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
    logic [ADDR_WIDTH-1: 0] waddr_index, raddr_index;
    logic [ID_WIDTH-1:0]    awid_reg, arid_reg;
    logic [7:0]   awlen_reg;
    logic [3:0]   wstrb_reg;
    logic [2:0]   awsize_reg;

    //========== Internal Memory ==========
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        for (int i=0; i<MEM_DEPTH; ++i) begin
            mem[i] = 0; // initialize memory
        end
    end

    //========== initialization ==========
    // initial begin
    //     axi.awready = 0;
    //     axi.wready  = 0;
    //     axi.bvalid  = 0;
    //     axi.arready = 0;
    //     axi.rvalid  = 0;    
    // end

    //========== Write FSM ==========

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

        next_wstate = wstate;

        case (wstate)
            W_IDLE : begin
                axi.awready = 1;
                if (axi.awvalid && axi.awready)
                    next_wstate = W_DATA;
            end

            W_DATA : begin
                axi.wready  = 1;
                if (axi.wlast && axi.wvalid && axi.wready)
                    next_wstate = W_RESP;
            end

            W_RESP : begin
                axi.bvalid  = 1;
                if (axi.bready && axi.bvalid)
                    next_wstate = W_IDLE;
            end
        endcase
    end

    //---------- Output logic ----------
    logic [31:0] curr_word;
    logic [1:0] bresp_reg;
    logic [7:0] wbeat_count;

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
                    axi.awready <= 1;
                    axi.wready  <= 0;
                    axi.bvalid  <= 0;
                    wbeat_count <= 0;
                    if (axi.awvalid && axi.awready) begin
                        waddr_index  <= axi.awaddr >> 2;
                        awid_reg    <= axi.awid;
                        awlen_reg   <= axi.awlen;
                        awsize_reg  <= axi.awsize;
                        bresp_reg   <= (axi.awaddr < MEM_DEPTH * 4) ? 2'b00 : 2'b10;    // RESP OKAY -> 00, SLVERR -> 10
                    end
                end
                
                W_DATA  : begin
                    axi.awready <= 0;
                    axi.wready  <= 1;
                    axi.bvalid  <= 0;
                    if (axi.wvalid && axi.wready) begin
                        curr_word = mem[waddr_index];

                        for (int i=0; i<4; ++i) begin
                            if (axi.wstrb[i])
                                curr_word[8*i +: 8]  = axi.wdata[8*i +: 8];
                        end
                        mem[waddr_index] <= curr_word;
                        
                        // $display("%t WRITE addr=%0h data=%h strb=%b result=%h wlast=%0b wbeat_count=%0d / awlen=%0d",
                        //         $time, waddr_index, axi.wdata, axi.wstrb, curr_word, axi.wlast, wbeat_count, awlen_reg);
                        
                        waddr_index <= waddr_index + 1;
                        wbeat_count <= wbeat_count + 1;
                    end
                end

                W_RESP  : begin
                    axi.awready <= 0;
                    axi.wready  <= 0;
                    axi.bvalid  <= 1;
                    axi.bid     <= awid_reg;
                    axi.bresp   <= bresp_reg;
                end

            endcase
        end 
    end

    // gated log
    // always_ff @(posedge clk or negedge rst_n) begin
    //     $display("%t [DUT-I/f] %s awready=%0d awvalid=%0b awaddr=%0h awid=%0h", $time, wstate.name(), axi.awready, axi.awvalid, axi.awaddr, axi.awid);
    //     $display("%t [DUT-I/f] %s wready=%0d wvalid=%0b wdata=%0h wstrb=%0d wlast=%0b", $time, wstate.name(), axi.wready, axi.wvalid, axi.wdata, axi.wstrb, axi.wlast);
    //     $display("%t [DUT] %s bvalid=%0b bresp=%0d bid=%0h", $time, wstate.name(), axi.bvalid, axi.bresp, axi.bid);
    //     // $display("address awaddr=%0h waddr_reg=%0h", axi.awaddr, addr_index);
    //     // $strobe("%t mem[%0h] = %h", $time, addr_index-1, mem[addr_index-1]);
    // end

    //========== Read FSM ==========

    logic [7:0] arlen_reg, rbeat_count;
    logic [31:0] mem_data;

    typedef enum {
        R_IDLE,
        R_DATA
    } rstate_t;

    rstate_t rstate, next_rstate;

    //---------- state register logic ----------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rstate <= R_IDLE;
        end else begin
            rstate <= next_rstate;
        end
    end

    //---------- next state logic ----------
    always_comb begin
        
        next_rstate = rstate;

        case (rstate)
            R_IDLE  : begin
                if (axi.arvalid && axi.arready) begin
                    next_rstate = R_DATA;
                end
            end

            R_DATA  : begin
                if (axi.rlast && axi.rvalid && axi.rready) begin
                    next_rstate = R_IDLE;
                end
            end
        endcase
    end

    //---------- Output logic ----------
    logic [31:0] curr_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.arready <= 0;
            axi.rvalid  <= 0;
            rbeat_count  <= 0;
            axi.rlast   <= 0;
            axi.rdata   <= 0;
            axi.rid     <= 0;
            axi.rresp   <= 0;
        end else begin
            case (rstate)
                R_IDLE: begin
                    axi.arready <= 1;
                    axi.rvalid  <= 0;
                    rbeat_count <= 0;
                    axi.rlast   <= 0;   
                    if (axi.arvalid && axi.arready) begin
                        raddr_index <= axi.araddr >> 2;
                        arid_reg    <= axi.arid;    
                        arlen_reg   <= axi.arlen;
                        
                    end
                end

                R_DATA: begin

                    if (!axi.rvalid || axi.rready) begin
                        curr_data = mem[raddr_index];

                        axi.rdata  <= curr_data;
                        axi.rresp  <= (curr_data !== 'x) ? 2'b00 : 2'b10;
                        axi.rid    <= arid_reg;
                        axi.rlast  <= (rbeat_count == arlen_reg);
                        axi.rvalid <= 1;

                        raddr_index <= raddr_index + 1;
                        rbeat_count <= rbeat_count + 1;
                    end
                    // else HOLD when backpressure
                    
                end
            endcase
        end
    end

    // assign axi.rdata = mem_data;

    // Log
    // always_ff @(posedge clk or negedge rst_n) begin
    //     // $display("%t [DUT] %s arready=%0d arvalid=%0b araddr=%0h arid=%0h", $time, rstate.name(), axi.arready, axi.arvalid, axi.araddr, axi.arid);
    //     // $display("%t [DUT] %s rready=%0d rvalid=%0b rdata=%0h rlast=%0b", $time, rstate.name(), axi.rready, axi.rvalid, axi.rdata, axi.rlast);
    //     // $display("%t [DUT] %s araddr=%0h raddr_index=%0h beat_count=%0d", $time, rstate.name(), axi.araddr, raddr_index, beat_count);
        
    //     if (rstate inside {R_IDLE, R_DATA}) begin
    //         $display("%t [DUT] %s beat_count=%0d rlast=%0b", $time, rstate.name(), beat_count, axi.rlast);
    //     end
    // end
    
    //========== Assertions ==========
    // wlast burst counter validation
    assert property (@(posedge clk)
        (wstate == W_DATA && axi.wvalid && axi.wready && axi.wlast)
        |-> (wbeat_count == awlen_reg)
    ) else $error("%t [DUT] wlast/awlen mismatch %0d != %0d", $time, wbeat_count, awlen_reg);

endmodule