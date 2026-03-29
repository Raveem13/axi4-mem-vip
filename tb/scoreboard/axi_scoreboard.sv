//==========================================================
// File        : axi_scoreboard.sv
// Author      : Raveem
// Created     : 2026-03-10
// Description : checks transactions
//==========================================================

`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read)

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_imp_write #(axi_transaction, axi_scoreboard) write_imp;
    uvm_analysis_imp_read #(axi_transaction, axi_scoreboard) read_imp;

    axi_ref_model ref_model;

    int wd_len, awsize, waddr;
    int rd_len, arsize, raddr;

    bit [31:0] actual_rdata, expect_rdata;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        `uvm_info("SCB", "Scoreboard built", UVM_LOW)
        write_imp = new("write_imp", this);
        read_imp  = new("read_imp", this);
        ref_model = new();
        
    endfunction

    function void write_write(axi_transaction txn);
        process_write(txn);
    endfunction

    function void write_read(axi_transaction txn);
        process_read(txn);
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