//==========================================================
// File        : axi_wr_rd_sequence.sv
// Author      : Raveem
// Created     : 2026-03-22
// Description : one sequence that generates both 
//               read and write txns with same address
//==========================================================

class axi_wr_rd_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_wr_rd_sequence)

    function new(string name="axi_wr_rd_sequence");
        super.new(name);
    endfunction

    task body();
        axi_transaction w_tr, r_tr;

        repeat(5) begin

            //---------- write txn ----------
            w_tr = axi_transaction::type_id::create("w_tr");

            start_item(w_tr);

            assert (w_tr.randomize() with {
                cmd == WRITE;
            }); 

            `uvm_info("WR_SEQ", $sformatf("Write: %s", w_tr.sprint()), UVM_MEDIUM)

            finish_item(w_tr);

            //---------- address matching read txn ----------
            r_tr = axi_transaction::type_id::create("r_tr");

            start_item(r_tr);
            
            assert (r_tr.randomize() with {
                cmd == READ;
                // matching write txn
                addr        == w_tr.addr;
                burst_len   == w_tr.burst_len;
                burst_size  == w_tr.burst_size;
                burst_type  == w_tr.burst_type;
                id          != w_tr.id;   // optional but good
            });

            `uvm_info("RD_SEQ", $sformatf("Read: %s", r_tr.sprint()), UVM_MEDIUM)

            finish_item(r_tr);
        end
    endtask
endclass
