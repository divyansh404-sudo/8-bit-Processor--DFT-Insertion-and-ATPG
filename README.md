<div align="center">

# 8-bit Processor: DFT Insertion & ATPG

![Cadence](https://img.shields.io/badge/CADENCE-GENUS_SYNTHESIS-blue)
![Cadence](https://img.shields.io/badge/CADENCE-MODUS_ATPG-blue)
![Technology](https://img.shields.io/badge/TECH-90NM_CMOS-yellowgreen)
![DFT](https://img.shields.io/badge/SCAN-INSERTION-orange)
![Status](https://img.shields.io/badge/ATPG-COMPLETE-brightgreen)
![License](https://img.shields.io/badge/LICENSE-MIT-yellow)

Implementation of scan-based Design-for-Testability (DFT) architecture and ATPG workflow for a custom 8-bit processor designed in Verilog and synthesized using Cadence EDA tools.

</div>

---

## 🎯 Overview

This project presents the implementation of **scan-based Design-for-Testability (DFT)** on a custom **8-bit Processor** using **Cadence Genus Synthesis Solution**, targeting a **90nm CMOS technology library**.

The objective of this work is to transform the sequential processor design into a **testable scan-compatible architecture** by inserting scan flip-flops and establishing scan chain connectivity for enhanced controllability and observability during test mode.

The implementation covers RTL design, DFT-aware synthesis, scan insertion, scan chain generation, DFT rule verification, and ATPG-based fault pattern generation using **Cadence Modus**.

---

## ✨ Key Highlights

- **Custom 8-bit Sequential Processor** with ALU implemented in Verilog HDL
- **3-Stage FSM Architecture**: FETCH → EXEC → WB
- **7-Operation ALU**: ADD, SUB, AND, OR, INC, DEC, NOT
- **Scan-Based DFT Insertion** using Cadence Genus
- **Single Muxed-Scan Chain Architecture** connecting all sequential elements
- **296 Scan Flip-Flops** integrated into the final scan chain
- **DFT Rule Verification** completed with zero violations
- **Post-DFT Netlist and SCANDEF Generation** completed
- **ATPG executed** using Cadence Modus — 100% static fault coverage achieved

---

## 🏗️ Architecture

### Design Hierarchy

```text
processor (Top Module)
│
├── Input Ports: clk, reset, scan_en, scan_in, test_mode
├── Output Ports: A_out [7:0], PC_out [4:0], halted_out, scan_out
│
├── Internal Registers
│   ├── Accumulator A [7:0]
│   ├── Instruction Register IR [7:0]
│   ├── Program Counter PC [4:0]
│   ├── FSM State Register [1:0]
│   └── ALU operand register alu_b [7:0]
│
├── Memory Array: 32 × 8-bit
│
└── alu (Submodule)
    ├── Inputs:  a [7:0], b [7:0], op [2:0]
    └── Outputs: result [7:0], carry_out, zero_out
```

### Instruction Set Architecture

| Opcode [7:5] | Mnemonic | Operation |
|-------------|----------|-----------|
| `000` | LOAD | A ← Memory[addr] |
| `001` | STORE | Memory[addr] ← A |
| `010` | ALU | A ← ALU(A, op) |
| `111` | HALT | Processor halted |
| default | NOP | PC ← PC + 1 |

### ALU Operations

| op [2:0] | Operation | Notes |
|---------|-----------|-------|
| `000` | ADD | A + B, sets carry |
| `001` | SUB | A − B, sets borrow |
| `010` | AND | A & B |
| `011` | OR | A \| B |
| `100` | INC | A + 1, ignores B |
| `101` | DEC | A − 1, ignores B |
| `110` | NOT | ~A, ignores B |

### Design Classification

> The processor is implemented as a **sequential circuit** driven by a single clock domain, with an embedded 3-state FSM (FETCH / EXEC / WB) controlling instruction execution. Two flag registers (`carry`, `zero`) were pruned by Genus as they had no path to primary outputs.

---

## 🔄 DFT Flow

```text
RTL Design (processor.v + alu.v)
│
├── 8-bit accumulator-based processor
├── 7-operation combinational ALU
│
▼
Synthesis (Cadence Genus)
│
├── Generic synthesis (high effort)
├── Technology mapping (90nm CMOS slow.lib)
│
▼
DFT Insertion
│
├── Muxed-scan style configuration
├── Scan flip-flop replacement (296 FFs)
├── Scan chain stitching (chain1)
├── DFT rule checking
│
▼
Generated Outputs
│
├── Post-DFT Scan Netlist (processor_post_dft.v)
├── SCANDEF File (processor.scandef)
├── SDF / SDC files
└── Timing / Area / Power Reports
│
▼
ATPG (Cadence Modus)
│
├── Build Model & Fault Model (FULLSCAN)
├── Scan Test Generation (1 pattern)
├── Logic Test Generation (313 patterns)
└── Verilog Vector Output
```

---

## 🔗 Scan Chain Architecture

| Parameter | Value |
|----------|-------|
| Scan Style | Muxed Scan |
| Total Chains | 1 |
| Chain Length | 296 Bits |
| Shift Enable | scan_en |
| Scan Input | scan_in |
| Scan Output | scan_out |
| Clock Domain | clk |
| Test Clock Period | 10,000 ps |
| Scan Trigger Edge | Rising Edge |

### Scan Chain Connectivity

| Chain ID | Start Point | End Point | Length | Type |
|---------|------------|----------|-------|------|
| chain1 | scan_in | scan_out | 296 | Muxed Scan |

---

## ⚙️ Synthesis Results

| Parameter | Value |
|----------|------|
| Top Module | processor |
| Technology | 90nm slow.lib |
| Clock Period | 20 ns (50 MHz) |
| WNS (Worst Negative Slack) | +13883.90 ps (MET) |
| TNS | 0 |
| Total Instances (Post-DFT) | 296 |
| Synthesis Effort | High |

> **Note:** Genus pruned 2 unused registers (`carry`, `zero`) during elaboration as they had no path to any primary output. This reduces sequential count but does not affect functional correctness.

---

## 📊 DFT Results

| Metric | Value |
|-------|-------|
| Total Sequential Elements | 296 |
| Total Scan Cells Inserted | 296 |
| Scan Mapping Coverage | 100% |
| Flip-Flops Not Scan-Replaceable | 0 |
| Flip-Flops Not Targeted for DFT | 0 |
| Total Scan Chains | 1 |
| Chain Length | 296 bits |
| Scan Style | Muxed Scan |
| Scan Input | scan_in |
| Scan Output | scan_out |
| Shift Enable | scan_en |
| Test Clock | clk_test (10 ns period) |
| DFT Violations | 0 |
| DFT Insertion Status | Successful |

---

## 🧪 ATPG Results

| Parameter | Value |
|----------|------|
| ATPG Tool | Cadence Modus v20.12 |
| Test Mode | FULLSCAN |
| Fault Model | Stuck-at Fault |
| Total Static Faults | 18,338 |
| Collapsed Static Faults | 11,396 |
| Total Dynamic Faults | 22,216 |
| Scan Test Patterns | 1 |
| Logic Test Patterns | 313 |
| Total Test Sequences | 314 |
| Final Static Fault Coverage | **100.00%** |
| Final Dynamic Fault Coverage | 18.68% |
| Untested Static Faults | 0 |
| Redundant Faults | 0 |
| ATPG Status | Successful |

---

### Fault Coverage Breakdown

| Fault Category | Total Faults | Tested | Untested | Coverage |
|--------------|------------|-------|---------|---------|
| Total Static Faults | 18,338 | 18,338 | 0 | **100.00%** |
| Collapsed Static Faults | 11,396 | 11,396 | 0 | **100.00%** |
| Total Dynamic Faults | 22,216 | 4,150 | 18,066 | 18.68% |
| PI Static Faults | 8 | 8 | 0 | 100.00% |
| PO Static Faults | 30 | 30 | 0 | 100.00% |

> **Note on Dynamic Coverage:** The lower dynamic fault coverage (18.68%) is expected for a processor design with a wide state space and deeply sequential behavior. Full static coverage at 100% indicates all modelled stuck-at faults are detected.

---

### ATPG Pattern Statistics

| Test Type | Number of Patterns | Purpose |
|----------|------------------|--------|
| Scan Chain Test | 1 | Scan Shift Verification (596 cycles) |
| Logic Test | 313 | Static Fault Detection (93,573 cycles) |
| **Total** | **314** | **Complete ATPG Coverage** |

---

### Tool Runtime Statistics

| Operation | CPU Time | Elapsed Time |
|----------|---------|-------------|
| Build Model | 0.00 s | 0.02 s |
| Build Fault Model | — | — |
| Scan Test Generation | — | — |
| Logic Test Generation | 0.63 s | 1.70 s |
| Write Vectors | 0.09 s | 0.32 s |

---

## 📝 Technical Observations

- The **8-bit processor** has a significantly larger scan chain (296 FFs) compared to simpler datapaths, reflecting the deep sequential state of a stored-program architecture.
- A **single muxed-scan chain** was sufficient to accommodate all 296 sequential elements.
- The design achieved **zero DFT rule violations**, confirming structurally valid scan insertion with 100% flip-flop scan-replaceability.
- ATPG execution achieved **100% static fault coverage** — all 18,338 stuck-at faults were fully detected.
- **Zero redundant faults** were identified, demonstrating efficient and non-degenerate logic structure.
- Dynamic fault coverage is inherently limited for complex sequential designs; improving it would require additional constrained-random or sequential ATPG techniques.
- Timing analysis confirms substantial **positive slack (+13.8 ns)**, indicating that DFT insertion caused no timing violations.
- Two unused status registers (`carry`, `zero`) were optimized away by Genus, as they were not connected to any observable output — a common synthesis optimization for accumulator-based architectures.
- The embedded demo program (`LOAD M[16] → ALU ADD → STORE M[18] → HALT`) pre-loaded into memory validates functional correctness of the instruction pipeline.

---

## 📂 Repository Structure

```text
.
├── rtl/
│   ├── alu.v
│   └── processor.v
│
├── constraints/
│   └── processor.sdc
│
├── scripts/
│   ├── run_genus_dft.tcl
│   └── run_modus_atpg.tcl
│
├── output/
│   ├── processor_post_dft.v
│   ├── processor.scandef
│   ├── processor_post_dft.sdf
│   └── processor_post_dft.sdc
│
├── reports/
│   ├── post_dft_timing.rpt
│   ├── post_dft_area.rpt
│   ├── post_dft_power.rpt
│   ├── post_dft_gates.rpt
│   ├── dft_setup.rpt
│   ├── scan_chains.rpt
│   ├── post_dft_rules.rpt
│   └── test_coverage_logic.rpt
│
├── results/
│   └── test_results.v
│
├── logs/
│   ├── genus.log
│   └── modus.log
│
└── README.md
```

---

<div align="center">

### 👨‍🎓 About the Developer

**Divyansh Tiwari**
Roll No.: 123EC0039

Department of Electronics and Communication Engineering
Integrated Bachelor and Master of Technology

**Indian Institute of Information Technology Design and Manufacturing, Kurnool**

---

### ⭐ Star this repository if you found it helpful!

---

© 2025 Divyansh Tiwari — All Rights Reserved

</div>
