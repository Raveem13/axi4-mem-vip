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
    
    task run_phase(uvm_phase phase);
        // axi_write_sequence  w_seq;
        axi_read_sequence   r_seq;

        phase.raise_objection(this);
        
        // `uvm_info("TEST", "Starting write sequence", UVM_NONE)
        
        // w_seq = axi_write_sequence::type_id::create("w_seq");
        // w_seq.start(env.agent.seqr);
        
         `uvm_info("TEST", "Starting read sequence", UVM_NONE)
        r_seq = axi_read_sequence::type_id::create("r_seq");
        r_seq.start(env.agent.seqr);

        phase.drop_objection(this);
    endtask
endclass
