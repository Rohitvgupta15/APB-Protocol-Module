# Design and Implementation of the APB Protocol

## Overview
This repository contains a Register Transfer Level (RTL) implementation of the **Advanced Peripheral Bus (APB)** protocol using Verilog HDL.  
APB is a part of the AMBA (Advanced Microcontroller Bus Architecture) family and is widely used for connecting low-bandwidth peripherals in embedded and System-on-Chip (SoC) designs.

The project focuses on **protocol-level behavior**, including signal timing, transaction sequencing, and master–slave communication, and is verified through simulation.

---

## About APB Protocol
The Advanced Peripheral Bus (APB) is designed to provide a simple, low-power, and low-complexity interface for peripheral devices.  
It is non-pipelined, synchronous, and operates using a predictable two-phase transaction mechanism.

APB is commonly used for peripherals such as UARTs, timers, GPIOs, control/status registers, and simple memory-mapped devices.

---

## Key Features
- AMBA-compliant APB protocol design
- Single master with multiple slave support
- Two-phase transaction model:
  - SETUP phase
  - ACCESS phase
- Supports read and write operations
- Wait-state handling using `PREADY`
- Error reporting using `PSLVERR`
- FSM-based control logic
- Deterministic and non-pipelined data transfers

---

## APB Transaction Phases
### SETUP Phase
- Address and control signals are asserted
- `PSEL = 1`
- `PENABLE = 0`

### ACCESS Phase
- Data transfer occurs
- `PENABLE = 1`
- Transfer completes when `PREADY = 1`

---

## APB Signals Used

| Signal    | Description |
|----------|-------------|
| PCLK     | Clock signal |
| PRESETn  | Active-low reset |
| PADDR    | Address bus |
| PSEL     | Peripheral select |
| PWRITE   | Read/Write control |
| PWDATA   | Write data bus |
| PRDATA   | Read data bus |
| PENABLE  | Access phase indicator |
| PREADY   | Slave ready signal |
| PSLVERR  | Slave error signal |

---

## Architecture Overview
### APB Master
- Initiates and controls all bus transactions
- Generates address, control, and data signals
- Manages SETUP and ACCESS phases using FSM logic

### APB Slaves
- Respond to master requests
- Perform read and write operations
- Assert ready and error signals as required

### APB Interconnect
- Shared address, data, and control buses
- Only one slave active during a transaction
- No arbitration required due to single-master architecture

---

## Functional Verification
The design has been verified through simulation for:
- Basic read and write operations
- Back-to-back transactions
- Sequential (burst-style) accesses
- Asynchronous reset during active transfers
- Invalid address access and error signaling

Simulation waveforms confirm correct signal handshaking, timing behavior, and protocol compliance.

.
├── rtl/
│   ├── apb_master.v   # APB master RTL module
│   ├── apb_slave.v    # APB slave RTL module
│   └── apb_top.v      # Top-level APB integration module
│
├── tb/
│   └── apb_tb.v       # APB protocol testbench
│
└── README.md          # Project documentation


---

## Intended Use
- Learning and understanding the AMBA APB protocol
- Reference RTL design for SoC bus interfaces
- Academic and educational projects
- Protocol verification and study purposes

---

## Notes
- This repository focuses strictly on **APB protocol design and simulation**
- No FPGA-specific, board-specific, or hardware deployment details are included
- The design is modular and easily extensible

---

## Author
**Rohit Vijay Gupta**

---

## Repository Structure
