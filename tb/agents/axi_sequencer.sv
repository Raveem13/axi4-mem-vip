//==========================================================
// File        : axi_sequencer.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : axi txn sequencer
//==========================================================

class axi_sequencer extends uvm_sequencer #(axi_transaction);
    `uvm_component_utils(axi_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass