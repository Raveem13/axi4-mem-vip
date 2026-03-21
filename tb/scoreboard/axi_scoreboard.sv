//==========================================================
// File        : axi_scoreboard.sv
// Author      : Raveem
// Created     : 2026-03-10
// Description : checks transactions
//==========================================================

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_imp #(axi_transaction, axi_scoreboard) analysis_export;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export   = new("analysis_export", this);
        
        `uvm_info("SCB", "Scoreboard built", UVM_LOW)
        
    endfunction

    function void write(axi_transaction tr);
        `uvm_info("SCB", 
                $sformatf("Txn received: cmd=%s, addr=%0h, id=%0h",
                            tr.cmd.name(), tr.addr, tr.id), 
                            UVM_MEDIUM)
        
    endfunction
endclass