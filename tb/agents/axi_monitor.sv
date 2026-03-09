//==========================================================
// File        : axi_monitor.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : observes axi interface, restructure txns
//==========================================================

class axi_monitor extends uvm_monitor;
    `uvm_object_utils(axi_monitor)
    
    virtual axi4_if.monitor vif;
    uvm_analysis_port #(axi_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        
        if (!uvm_config_db#(virtual axi4_if.monitor)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Monitor interface not set")
            
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            
            @(posedge vif.clk);

            if (vif.awvalid && vif.awready)
                collect_write(tr);
            if (vif.arvalid && vif.arready)
                collect_read(tr);
        end
    endtask

    task collect_write(axi_transaction tr);
        
        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");

        tr.cmd  = WRITE;
        tr.addr = vif.awaddr;
        tr.id   = vif.awid;

        int beats = vif.awlen + 1;

        tr.data = new[beats];

        for (int i=0; i<beats; ++i) begin
            
            while (!(vif.wvalid && vif.wready)) begin
                @(posedge vif.clk);
            end
            tr.data[i] = vif.wdata;

        end

        ap.write(tr);

    endtask

    task collect_read(axi_transaction tr);
        
        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");

        tr.cmd  = READ;
        tr.addr = vif.araddr;
        tr.id   = vif.arid;

        int beats = vif.arlen + 1;

        tr.rdata = new[beats];

        for (int i=0; i<beats; ++i) begin
            
            while (!(vif.rvalid && vif.rready)) begin
                @(posedge vif.clk);
            end
            tr.rdata[i] = vif.rdata;

        end

        ap.write(tr);
    endtask
    
endclass