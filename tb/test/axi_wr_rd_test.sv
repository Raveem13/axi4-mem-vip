//==========================================================
// File        : axi_wr_rd_test.sv
// Author      : Raveem
// Created     : 2026-03-22
// Description : Test for AXI write-read operations
//==========================================================

class axi_wr_rd_test extends uvm_test;
    `uvm_component_utils(axi_wr_rd_test)

    axi_env env;

    function new(string name="axi_wr_rd_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        axi_wr_rd_sequence wr_rd_seq;

        phase.raise_objection(this);
        
        `uvm_info("TEST", "Starting write read sequence", UVM_NONE)
        wr_rd_seq = axi_wr_rd_sequence::type_id::create("wr_rd_seq");
        wr_rd_seq.start(env.agent.seqr);
        
        phase.drop_objection(this);
    endtask
endclass
