//==========================================================
// File        : axi_base_sequence.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : parent for all other sequences
//==========================================================

class axi_base_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_base_sequence);

    function new(string name = "axi_base_sequence");
        super.new(name);
    endfunction

endclass
