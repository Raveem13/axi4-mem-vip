//==========================================================
// File        : tb_pkg.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : package file
//==========================================================


package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //---------- transactions ----------
    `include "sequence_items/axi_transaction.sv"

    //---------- sequences ----------
    `include "sequences/axi_base_sequence.sv"
    `include "sequences/axi_read_sequence.sv"
    `include "sequences/axi_write_sequence.sv"
        
    //---------- agents ----------
    `include "agents/axi_sequencer.sv"  
    `include "agents/axi_driver.sv"
    `include "agents/axi_monitor.sv"

    //---------- scoreboard ----------
    
    //---------- env ----------
    `include "tb/env/axi_env.sv"

    //---------- tests ----------
    `include "tb/test/axi_test.sv"

    // tb/top_tb.sv
endpackage