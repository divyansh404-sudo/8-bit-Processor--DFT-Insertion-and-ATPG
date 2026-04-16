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

### Scan Chain Register Mapping

The single scan chain (`chain1`) captures all 296 sequential elements in the following order:

```text
scan_in
  │
  ├─ bits  1–8   : A_reg[7:0]          (Accumulator)
  ├─ bits  9–16  : IR_reg[7:0]         (Instruction Register)
  ├─ bits 17–21  : PC_reg[4:0]         (Program Counter)
  ├─ bits 22–29  : alu_b_reg[7:0]      (ALU Operand B)
  ├─ bits 30–32  : alu_op_reg[2:0]     (ALU Opcode)
  ├─ bit  33     : halted_reg          (Halt Flag)
  ├─ bits 34–289 : memory_reg[0..31]   (32 × 8-bit RAM — 256 bits)
  ├─ bits 290–294: next_pc_reg[4:0]    (Next PC)
  └─ bits 295–296: state_reg[1:0]      (FSM State)
  │
scan_out
```

> **Observation:** 256 of the 296 scan bits (86.5%) correspond to the 32×8 memory array, which is the dominant contributor to chain length in this stored-program processor architecture.

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

## 📐 Area Analysis

### Post-DFT Area Summary

| Parameter | Value |
|----------|-------|
| Total Cell Count | 1,537 |
| Total Cell Area | 14,496.905 µm² |
| Net Area | 0.000 µm² (no wireload model) |
| Wireload Model | Default (none) |

### Area Breakdown by Type

| Cell Type | Instances | Area (µm²) | Area % |
|----------|-----------|-----------|--------|
| Sequential (Scan FFs) | 296 | 7,537.967 | **52.0%** |
| Logic Gates | 1,111 | 6,557.782 | 45.2% |
| Inverters | 94 | 237.667 | 1.6% |
| Buffers | 36 | 163.490 | 1.1% |
| Physical Cells | 0 | 0.000 | 0.0% |
| **Total** | **1,537** | **14,496.905** | **100%** |

> **Note:** Sequential cells dominate area (52%) due to 296 scan flip-flops replacing standard DFFs, each adding a scan MUX overhead inherent to muxed-scan architecture.

### Key Gate Instances (Top Contributors by Area)

| Gate | Instances | Area (µm²) | Purpose |
|------|-----------|-----------|---------|
| SDFFRHQX1 | 253 | 6,319.358 | Scan FF (primary) |
| MX2XL | 262 | 1,983.078 | 2:1 Mux (datapath) |
| AOI222XL | 67 | 557.835 | AOI logic |
| AOI221XL | 55 | 416.295 | AOI logic |
| NAND2XL | 139 | 420.836 | NAND logic |
| AOI22XL | 242 | 1,465.358 | AOI logic |
| SDFFRHQX4 | 15 | 476.847 | Scan FF (high drive) |
| SDFFRHQX2 | 14 | 360.284 | Scan FF (medium drive) |
| SDFFSXHQX1 | 14 | 381.478 | Scan FF (set) |

---

## ⚡ Power Analysis

### Post-DFT Power Summary

| Category | Leakage (W) | Internal (W) | Switching (W) | Total (W) | Share |
|---------|------------|-------------|--------------|----------|-------|
| Register | 4.631e-05 | 3.031e-04 | 1.270e-05 | 3.621e-04 | **77.25%** |
| Logic | 2.709e-05 | 3.952e-05 | 1.913e-05 | 8.575e-05 | 18.29% |
| Clock | 0.000e+00 | 0.000e+00 | 2.092e-05 | 2.092e-05 | 4.46% |
| Memory | 0.000e+00 | 0.000e+00 | 0.000e+00 | 0.000e+00 | 0.00% |
| **Total** | **7.340e-05** | **3.426e-04** | **5.276e-05** | **4.688e-04** | **100%** |

### Power Breakdown by Component

| Power Type | Value (W) | Percentage |
|-----------|----------|-----------|
| Leakage Power | 7.340e-05 | 15.66% |
| Internal Power | 3.426e-04 | 73.09% |
| Switching Power | 5.276e-05 | 11.25% |
| **Total Power** | **4.688e-04** | **100%** |

> **Note:** Register logic dominates total power at 77.25%, consistent with a design where 52% of area is scan flip-flops. Internal (dynamic) power is the largest contributor at 73.09% of total power.

---

## ⏱️ Timing Analysis — Pre vs Post DFT

### Pre-DFT Critical Path

| Parameter | Value |
|----------|-------|
| Path | `halted_reg/CK` → `halted_out` |
| Clock Edge (Capture) | 20,000 ps |
| Output Delay | 5,000 ps |
| Clock Uncertainty | 500 ps |
| Required Time | 14,500 ps |
| Data Path Delay | 690 ps |
| **Slack (WNS)** | **+13,810 ps ✅ MET** |
| Cell Used | DFFRHQX1 (standard DFF) |

### Post-DFT Critical Path

| Parameter | Value |
|----------|-------|
| Path | `PC_reg[4]/CK` → `PC_out[4]` |
| Clock Edge (Capture) | 20,000 ps |
| Output Delay | 5,000 ps |
| Clock Uncertainty | 500 ps |
| Required Time | 14,500 ps |
| Data Path Delay | 640 ps |
| **Slack (WNS)** | **+13,860 ps ✅ MET** |
| Cell Used | SDFFRHQX2 (scan DFF, post-DFT) |

### Pre vs Post DFT Comparison

| Metric | Pre-DFT | Post-DFT | Delta | Status |
|-------|--------|---------|-------|--------|
| WNS (Worst Slack) | +13,810 ps | +13,860 ps | +50 ps | ✅ Improved |
| TNS | 0 | 0 | — | ✅ No change |
| Critical Path Delay | 690 ps | 640 ps | −50 ps | ✅ Improved |
| Critical Path FF | DFFRHQX1 | SDFFRHQX2 | Scan FF | ✅ Replaced |
| Timing Violations | 0 | 0 | — | ✅ Clean |
| Clock Period | 20 ns | 20 ns | — | Unchanged |

> **Observation:** DFT insertion caused **no timing degradation**. The post-DFT critical path actually shows a marginal improvement (+50 ps slack) because Genus re-optimised the netlist during scan replacement, selecting a higher-drive scan cell (`SDFFRHQX2`) for the PC register which reduced its output transition time.

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

### DFT Rule Check Summary

| Rule Category | Violations |
|--------------|-----------|
| Internally driven clock net | 0 |
| Tied constant clock net | 0 |
| Undriven clock net | 0 |
| Conflicting async & clock net | 0 |
| Misc. clock net | 0 |
| Internally driven async net | 0 |
| Tied active async net | 0 |
| Undriven async net | 0 |
| Misc. async net | 0 |
| **Total DFT Violations** | **0** ✅ |

### DFT Configuration

| Parameter | Value |
|----------|-------|
| Scan Style | `muxed_scan` |
| Shift Enable Signal | `scan_en` (active high) |
| Test Mode Signal | `reset` (async set/reset, active low) |
| Test Clock Source | `clk` |
| Test Clock Domain | `clk_test` |
| Test Clock Period | 10,000 ps |
| Test Clock Edge | Rising |
| Lock-up Element | Preferred level-sensitive |
| Mix Clock Edges | Disabled |
| Registers Passing DFT Rules | 296 / 296 (100%) |

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

## 📋 Complete Design Summary — Pre vs Post DFT

| Metric | Pre-DFT | Post-DFT | Change |
|-------|--------|---------|--------|
| Sequential Elements | 296 FFs | 296 Scan FFs | FF → SDFF |
| Total Cell Count | ~1,537* | 1,537 | — |
| Total Area | ~14,497 µm²* | 14,496.905 µm² | Negligible |
| Sequential Area | — | 7,537.967 µm² | 52.0% of total |
| Critical Path Delay | 690 ps | 640 ps | −7.2% |
| WNS | +13,810 ps | +13,860 ps | +50 ps |
| Timing Violations | 0 | 0 | None |
| Total Power | — | 468.8 µW | — |
| DFT Violations | N/A | 0 | — |
| Scan Coverage | 0% | 100% | +100% |
| ATPG Static Coverage | N/A | 100% | — |

*Pre-DFT cell count and area are near-identical as scan replacement is in-place.

---

## 📝 Technical Observations

- The **8-bit processor** has a significantly larger scan chain (296 FFs) compared to simpler datapaths, reflecting the deep sequential state of a stored-program architecture.
- **86.5% of the scan chain** (256/296 bits) is occupied by the 32×8 memory array, which highlights how on-chip RAM dominates testability overhead in accumulator-based architectures.
- A **single muxed-scan chain** was sufficient to accommodate all 296 sequential elements.
- The design achieved **zero DFT rule violations**, confirming structurally valid scan insertion with 100% flip-flop scan-replaceability.
- ATPG execution achieved **100% static fault coverage** — all 18,338 stuck-at faults were fully detected.
- **Zero redundant faults** were identified, demonstrating efficient and non-degenerate logic structure.
- Dynamic fault coverage is inherently limited for complex sequential designs; improving it would require additional constrained-random or sequential ATPG techniques.
- Timing analysis confirms substantial **positive slack (+13.8 ns)**, indicating that DFT insertion caused no timing violations. Post-DFT slack marginally *improved* by 50 ps due to Genus re-optimisation during scan cell substitution.
- **Internal power dominates** at 73.09% of total 468.8 µW, driven by the large scan register bank (77.25% of total power).
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
│   ├── pre_dft_timing.rpt
│   ├── post_dft_timing.rpt
│   ├── post_dft_area.rpt
│   ├── post_dft_power.rpt
│   ├── post_dft_gates.rpt
│   ├── dft_setup.rpt
│   ├── dft_rules_check.rpt
│   ├── scan_chains.rpt
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

© 2026 Divyansh Tiwari — All Rights Reserved

</div>
