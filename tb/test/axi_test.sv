//==========================================================
// File        : axi_test.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : test file
//==========================================================

class axi_test extends uvm_test;
    `uvm_component_utils(axi_test)

    axi_env env;

    function new(string name="axi_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);
    endfunction
    
endclass
