//==========================================================
// File        : ref_model.sv
// Author      : Raveem
// Created     : 2026-03-27
// Description : store and retrieve data for checking
//==========================================================

class ref_model;
    
    bit [7:0] mem [ longint unsigned ];

    function void write_mem(logic [31:0] addr,
                            logic [31:0] wdata, 
                            logic [3:0] wstrb );

        for (int i=0; i<4; ++i) begin
            if (wstrb[i]) begin
                mem[addr + i] = wdata[8*i +: 8];
            end
        end
        
    endfunction

    function logic [31:0] read_mem(logic [31:0] addr);
        logic [31:0] rdata;
        
        for (int i=0; i<4; ++i) begin
            rdata[8*i +: 8] = mem.exists(addr + i) ? mem[addr + i] : 8'h00; 
        end
        
        return rdata;
    endfunction
    
endclass