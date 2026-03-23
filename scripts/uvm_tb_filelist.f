//---- package files ----
tb/tb_pkg.sv

tb/interface/axi4_if.sv

//---- rtl files ----
rtl/axi_memory_slave.sv

// ---- test-benches ----

tb/sequence_items/axi_transaction.sv

tb/sequences/axi_base_sequence.sv
tb/sequences/axi_read_sequence.sv
tb/sequences/axi_write_sequence.sv
tb/sequences/axi_wr_rd_sequence.sv

//---------- agents ----------

tb/agents/axi_sequencer.sv  
tb/agents/axi_driver.sv
tb/agents/axi_monitor.sv
tb/agents/axi_agent.sv
tb/scoreboard/axi_scoreboard.sv

tb/env/axi_env.sv
tb/test/axi_test.sv
tb/test/axi_wr_rd_test.sv
tb/top_tb.sv
    