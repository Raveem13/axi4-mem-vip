//==========================================================
// File        : axi_env.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : environment
//==========================================================

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_agent       agent;
    axi_scoreboard  scb;
    
    function new(string name="axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent   = axi_agent::type_id::create("agent", this);
        scb     = axi_scoreboard::type_id::create("scb", this);

        `uvm_info("ENV", "Agent & Scoreboard created", UVM_LOW)
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    
        agent.mon.write_ap.connect(scb.write_imp);
        agent.mon.read_ap.connect(scb.read_imp);

        `uvm_info("ENV", "Monitor connected to scoreboard", UVM_NONE)
        
    endfunction

endclass