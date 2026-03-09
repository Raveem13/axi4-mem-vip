//==========================================================
// File        : axi_driver.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : sequence to interface 
//==========================================================

class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver)
    
    virtual axi4_if.master vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi4_if.master)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction
    
    task run_phase(uvm_phase phase);
        
        axi_transaction tr;

        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.cmd == WRITE) begin
                drive_write(tr);
            end else begin
                drive_read(tr);
            end

            seq_item_port.item_done();
        end
    endtask

    //========== drive write txn ==========
    task drive_write(axi_transaction tr);
        
        int beats;

        beats = tr.burst_len;

        //---------- Write address channel ----------
        vif.awaddr  <= tr.addr;
        vif.awlen   <= tr.burst_len-1;
        vif.awsize  <= tr.burst_size;
        vif.awburst <= tr.burst_type;
        vif.awid    <= tr.id;
        vif.awvalid <= 1;

        wait(vif.awready);

        @(posedge clk);
        vif.awvalid <= 0;

        //---------- Write data channel ----------
        for (int i=0; i<beats; ++i) begin
            
            vif.wdata   <= tr.data[i];
            vif.wstrb   <= tr.strb[i];
            vif.wvalid  <= 1;
            vif.wlast   <= (i == beats-1);

            wait(vif.wready);

            @(posedge clk);
        end
        vif.wvalid  <= 0;
        vif.wlast   <= 0;

        //---------- write response channel ----------
        vif.bready <= 1;

        wait(vif.bvalid);
        @(posedge vif.clk);

        vif.bready <= 0;
    endtask

    //========== drive read txn ==========
    task drive_read(axi_transaction tr);
        
        int beats;

        beats = tr.burst_len;

        //---------- read address channel ----------
        vif.araddr  <= tr.addr;
        vif.arlen   <= tr.burst_len-1;
        vif.arsize  <= tr.burst_size;
        vif.arburst <= tr.burst_type;
        vif.arid    <= tr.id;
        vif.arvalid <= 1;

        wait(vif.arready);

        @(posedge clk);
        vif.arvalid <= 0;

        //---------- read data channel ----------
        vif.rready  <= 1;
        for (int i=0; i<beats; ++i) begin
            
            wait(vif.rvalid);
            @(posedge clk);

        end

        vif.rready  <= 0;

    endtask

endclass

