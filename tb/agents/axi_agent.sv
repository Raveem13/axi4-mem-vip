//==========================================================
// File        : axi_agent.sv
// Author      : Raveem
// Created     : 2026-03-10
// Description : 
//==========================================================

class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)

    axi_driver      drv;
    axi_sequencer   seqr;
    axi_monitor     mon;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        drv  = axi_driver   ::type_id::create("drv", this);   
        seqr = axi_sequencer::type_id::create("seqr",this);
        mon  = axi_monitor  ::type_id::create("mon", this);   

        `uvm_info("AGT", "AXI agent build complete", UVM_LOW)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        drv.seq_item_port.connect(seqr.seq_item_export);
        `uvm_info("AGT", "Driver connected to sequencer", UVM_LOW)
        
    endfunction
    
endclass