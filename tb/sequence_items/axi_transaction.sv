//==========================================================
// File        : axi_transaction.sv
// Author      : Raveem
// Created     : 2026-03-09
// Description : axi transaction class
//==========================================================

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_transaction extends uvm_sequence_item;
    //========== transaction type ==========
    typedef enum { READ, WRITE } axi_cmd_t;
    rand axi_cmd_t cmd;

    //========== address channel fields ==========
    rand bit   [31:0]  addr;
    rand bit   [3:0]   id;
    rand bit   [7:0]   burst_len;
    rand bit   [2:0]   burst_size;
    rand bit   [1:0]   burst_type;

    //========== write data ==========
    rand bit   [31:0]  data[];
    rand bit   [3:0]   strb[];

    //========== read data (by monitor) ==========
    bit [31:0]  rdata [];

    //========== constraints ==========
    constraint burst_len_c {
        burst_len inside {[1:15]};
    }


    constraint burst_size_c {
        burst_size == 3'b010;       // 4 byte
    }

    constraint burst_type_c {
        burst_type == 2'b01;         // INCR burst
    }

    constraint data_size_c {
        data.size() == burst_len;
        strb.size() == burst_len;
    }

    constraint address_c {
        addr dist { [0:4095] };
    }

    constraint aligned_addr_c {
        addr % 4 == 0;
    }
        
    function new(string name="axi_transaction");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(axi_transaction)

        `uvm_field_enum(axi_cmd_t, cmd, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(id, UVM_ALL_ON)
        `uvm_field_int(burst_len, UVM_ALL_ON)
        `uvm_field_int(burst_size, UVM_ALL_ON)
        `uvm_field_int(burst_type, UVM_ALL_ON)

        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_array_int(strb, UVM_ALL_ON)
        `uvm_field_array_int(rdata, UVM_ALL_ON)
        
    `uvm_object_utils_end
    
endclass