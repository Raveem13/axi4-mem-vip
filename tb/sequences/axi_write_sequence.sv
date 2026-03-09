//==========================================================
// File        : axi_write_sequence.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : generates random write txns
//==========================================================

class axi_write_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_write_sequence)
    
    function new(string name="axi_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        axi_transaction tr;

        repeat(5) begin
            tr = axi_transaction::type_id::create("tr");

            start_item(tr);

            assert (tr.randomize() with {
                cmd == WRITE;
            });
            `uvm_info("AXI_SEQ", tr.sprint(), UVM_MEDIUM)
            
            finish_item(tr);

        end
    endtask
endclass