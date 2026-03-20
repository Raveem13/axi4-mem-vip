//==========================================================
// File        : axi_driver.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : sequence to interface 
//==========================================================

class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver)
    
    virtual axi4_if vif;
    // typedef enum { READ, WRITE } axi_cmd_t;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")

        `uvm_info("DRV", "Driver built", UVM_LOW)
    endfunction
    
    task run_phase(uvm_phase phase);
        
        axi_transaction tr;

        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.cmd == axi_transaction::WRITE) begin
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
        @(vif.drv_wr_cb);
        
        vif.drv_wr_cb.awaddr  <= tr.addr;
        vif.drv_wr_cb.awlen   <= tr.burst_len-1;
        vif.drv_wr_cb.awsize  <= tr.burst_size;
        vif.drv_wr_cb.awburst <= tr.burst_type;
        vif.drv_wr_cb.awid    <= tr.id;
        vif.drv_wr_cb.awvalid <= 1;

        do @(vif.drv_wr_cb);
        while(!(vif.drv_wr_cb.awready));

        vif.drv_wr_cb.awvalid <= 0;

        //---------- Write data channel ----------
        for (int i=0; i<beats; ++i) begin
            
            vif.drv_wr_cb.wdata   <= tr.data[i];
            vif.drv_wr_cb.wstrb   <= tr.strb[i];
            vif.drv_wr_cb.wvalid  <= 1;
            vif.drv_wr_cb.wlast   <= (i == beats-1);

            do @(vif.drv_wr_cb);
            while(!(vif.drv_wr_cb.wready));
            
        end
        vif.drv_wr_cb.wvalid  <= 0;
        vif.drv_wr_cb.wlast   <= 0;

        //---------- write response channel ----------
        vif.drv_wr_cb.bready <= 1;

        do @(vif.drv_wr_cb);
        while(!vif.drv_wr_cb.bvalid);

        vif.drv_wr_cb.bready <= 0;
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
        vif.drv_rd_cb.arvalid <= 1;

        wait(vif.drv_rd_cb.arready);

        @(posedge vif.clk);
        vif.drv_rd_cb.arvalid <= 0;

        //---------- read data channel ----------
        vif.drv_rd_cb.rready  <= 1;
        for (int i=0; i<beats; ++i) begin
            
            wait(vif.drv_rd_cb.rvalid);
            @(posedge vif.clk);

        end

        vif.drv_rd_cb.rready  <= 0;

    endtask

endclass

