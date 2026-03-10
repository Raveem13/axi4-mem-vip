# AXI4 Memory VIP (UVM)

SystemVerilog UVM verification IP for an **AXI4 memory slave**, supporting burst transactions, write strobes, outstanding transactions, and protocol assertions.

## Features

* AXI4 **INCR burst** transactions
* **Outstanding transactions** with ID-based ordering
* **Write strobe (WSTRB)** support for partial writes
* **Scoreboard-based memory checking**
* **SystemVerilog Assertions (SVA)** for protocol validation
* **Coverage-driven verification**

## File Structure

The verification environment includes:

```
axi4-mem-vip
├── rtl/          # AXI memory slave model
├── tb/           # UVM testbench
│   ├── agent
│   ├── driver
│   ├── monitor
│   ├── sequences
│   |── scoreboard
|   └── tests     # Directed and random tests
├── scripts/      # bash scripts (used WSL to run cmds in window) 

```

## Protocol Support

Supported AXI4 features:

* INCR burst transactions
* Burst lengths: 1 / 4 / 8 / 16 beats
* Write strobes (WSTRB)
* ID-based response matching
* Multiple outstanding transactions

## Status

Work in progress — implementation and tests are being developed.

