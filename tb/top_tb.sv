//==========================================================
// File        : top_tb.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : top module
//==========================================================

module tb_top;
    
    bit clk;
    bit rst_n;

    //---------- Clock ----------
    always #5 clk = ~clk;

    //---------- Reset ----------
    initial begin
        clk     = 0;
        rst_n       = 0;
        #20 rst_n   = 1;
    end

    //---------- Interface ----------
    axi4_if axi_if0();
    assign axi_if0.clk     = clk;
    assign axi_if0.rst_n   = rst_n;

    //---------- DUT ----------
    axi_memory_slave dut (
        .clk(clk),
        .rst_n(rst_n),
        .axi(axi_if0)
    );

    // Dummy slave signal
    always @(posedge clk) begin
        if(!rst_n) begin
            axi_if0.awready <= 0;
            axi_if0.wready  <= 0;
            axi_if0.bvalid  <= 0;
        end
        else begin
            axi_if0.awready <= 1;
            axi_if0.wready  <= 1;
            axi_if0.bvalid  <= 1;
        end
    end

    //---------- Run ----------
    initial begin
        uvm_config_db#(virtual axi4_if)::set(null, "*", "vif", axi_if0);
        
        run_test("axi_test");
    end
endmodule