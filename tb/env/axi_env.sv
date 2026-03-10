//==========================================================
// File        : axi_env.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : environment
//==========================================================

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)
    
    function new(string name="axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass