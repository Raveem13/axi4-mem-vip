//==========================================================
// File        : axi_monitor.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : observes axi interface, restructure txns
//==========================================================

class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)
    
    virtual axi4_if vif;
    uvm_analysis_port #(axi_transaction) ap;

    int beats;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Monitor interface not set")

        `uvm_info("MON", "Monitor built", UVM_LOW)  
    endfunction

    task run_phase(uvm_phase phase);
        axi_transaction tr;

        forever begin
            
            @(posedge vif.clk);
            
            if (vif.awvalid && vif.awready)
                collect_write(tr);
            if (vif.arvalid && vif.arready)
                collect_read(tr);
        end
    endtask

    task collect_write(axi_transaction tr);
        
        tr = axi_transaction::type_id::create("tr");

        tr.cmd  = axi_transaction::WRITE;
        tr.addr = vif.awaddr;
        tr.id   = vif.awid;
        tr.burst_len    = vif.awlen + 1;
        tr.burst_size   = vif.awsize;
        tr.burst_type   = vif.awburst;

        beats = vif.awlen + 1;

        tr.data = new[beats];
        tr.strb = new[beats];

        for (int i=0; i<beats; ++i) begin
            
            // $display("%t [MON] wready=%0d wvalid=%0b wdata=%0h wstrb=%0d wlast=%0b", $time, vif.wready, vif.wvalid, vif.wdata, vif.wstrb, vif.wlast);
            do @(posedge vif.clk);
            while (!(vif.wvalid && vif.wready));

            tr.data[i] = vif.wdata;
            tr.strb[i] = vif.wstrb;

        end
        `uvm_info("MON", tr.sprint(), UVM_LOW)
        ap.write(tr);

    endtask

    task collect_read(axi_transaction tr);
        
        tr = axi_transaction::type_id::create("tr");

        tr.cmd  = axi_transaction::READ;
        tr.addr = vif.araddr;
        tr.id   = vif.arid;
        tr.burst_len    = vif.arlen + 1;
        tr.burst_size   = vif.arsize;
        tr.burst_type   = vif.arburst;

        beats = vif.arlen + 1;

        tr.rdata = new[beats];

        for (int i=0; i<beats; ++i) begin
            
            do @(posedge vif.clk);
            while (!(vif.rvalid && vif.rready));

            tr.rdata[i] = vif.rdata;

        end
        `uvm_info("MON", tr.sprint(), UVM_LOW)
        ap.write(tr);

    endtask
    
endclass