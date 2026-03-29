//==========================================================
// File        : axi_scoreboard.sv
// Author      : Raveem
// Created     : 2026-03-10
// Description : checks transactions
//==========================================================

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_imp #(axi_transaction, axi_scoreboard) analysis_export;

    axi_ref_model ref_model;

    int wd_len, awsize, waddr;
    int rd_len, arsize, raddr;

    bit [31:0] actual_rdata, expect_rdata;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export   = new("analysis_export", this);
        
        `uvm_info("SCB", "Scoreboard built", UVM_LOW)
        ref_model = new();
    endfunction

    function void write(axi_transaction tr);
        // `uvm_info("SCB", 
        //         $sformatf("Txn received: cmd=%s, addr=%0h, id=%0h",
        //                     tr.cmd.name(), tr.addr, tr.id), 
        //                     UVM_MEDIUM)
        
        if (tr.cmd == axi_transaction::WRITE) begin
            process_write(tr);
        end else begin
            process_read(tr);
        end

    endfunction

    function void process_write(axi_transaction tr);
        
        // `uvm_info("SCB-WR", "process write", UVM_NONE)
        wd_len   = tr.burst_len;
        awsize = tr.burst_size;
        waddr  = tr.addr;

        if (tr.data.size() !== wd_len) begin
            `uvm_error("SCB-WR", "Burst size Mismatch")
        end

        for (int beat=0; beat<wd_len; beat++) begin
            // `uvm_info("SCB-WR", 
            //     $sformatf("Beat %0d: address=%h, data=%h, strb=%b", beat, waddr, tr.data[beat], tr.strb[beat]), 
            //     UVM_NONE)

            ref_model.write_mem(waddr, tr.data[beat], tr.strb[beat]);
            waddr += (1 << awsize);
        end
        
    endfunction

    function void process_read(axi_transaction tr);
        
        // `uvm_info("SCB-RD", "process read", UVM_NONE)
        rd_len   = tr.burst_len;
        arsize = tr.burst_size;
        raddr  = tr.addr;

        if (tr.rdata.size() !== rd_len) begin
            `uvm_error("SCB-RD", "Burst size Mismatch")
        end

        for (int beat=0; beat<rd_len; beat++) begin
            
            actual_rdata = tr.rdata[beat];
            compare_read(raddr, actual_rdata);
            raddr += (1 << arsize);
        end
    endfunction

    function void compare_read( logic [31:0] addr,
                                logic [31:0] actual_rdata);

        expect_rdata = ref_model.read_mem(addr);
        if (actual_rdata !== expect_rdata) begin
            `uvm_error("SCB", $sformatf("Data MISMATCH @ 0x%0h | Expected=%h Actual=%h", addr, expect_rdata, actual_rdata))
        end else begin
            `uvm_info("SCB", $sformatf("Data MATCH @ 0x%0h | Data=%h", addr, actual_rdata), UVM_LOW)
        end
        
    endfunction

endclass