
#=============================================================================
# Genus Synthesis + DFT Insertion Script
# Design: processor (8-bit FSM Processor)
# Technology: 90nm
#=============================================================================

puts "============================================================"
puts "  Genus Synthesis + DFT Script for processor"
puts "  Technology: 90nm"
puts "============================================================"

# 1. Setup 90nm Library Paths
set_db init_lib_search_path /home/install/FOUNDRY/digital/90nm/dig/lib/
set_db library slow.lib

# 2. Read HDL source
puts "\n>>> Reading RTL Design..."
read_hdl ./alu.v
read_hdl ./processor.v

# 3. Elaborate Design
puts "\n>>> Elaborating Design..."
set_db hdl_unconnected_value 0
elaborate processor
check_design -unresolved

# 4. Apply Timing Constraints (Read the SDC file generated above)
puts "\n>>> Reading SDC Constraints..."
read_sdc ./processor.sdc

# 5. Power optimization goals & Pre-Synthesis DFT Definitions
set_max_leakage_power 0.0
set_max_dynamic_power 0.0

set_db dft_scan_style muxed_scan
set_db dft_prefix DFT_

define_dft shift_enable -name scan_en_sig -active high scan_en
define_dft test_clock   -name clk_test    -period 10000 clk

# 6. Synthesis (Generic and Mapped)
puts "\n>>> Synthesizing to Generic Gates..."
set_db syn_generic_effort high
syn_generic

puts "\n>>> Mapping to 90nm Technology Library..."
set_db syn_map_effort high
syn_map

# 7. Incremental Optimization & Pre-DFT Netlist
puts "\n>>> Running Incremental Optimization..."
set_db syn_opt_effort high
syn_opt

puts "\n>>> Generating Pre-DFT Reports and Netlist..."
report timing > ./pre_dft_timing.rpt
write_hdl > ./processor_pre_dft.v
write_sdc > ./processor_pre_dft.sdc

# 8. Insert Scan Chains
puts "\n>>> Checking DFT Rules & Inserting Scan Chains..."
check_dft_rules > ./dft_rules_check.rpt
replace_scan
define_scan_chain -name chain1 -sdi scan_in -sdo scan_out -non_shared_output
connect_scan_chains

# 9. Post-DFT Optimization
puts "\n>>> Post-DFT Incremental Optimization..."
syn_opt -incr

# 10. Post-DFT Reports
puts "\n>>> Generating Post-DFT Reports..."
report timing    > ./post_dft_timing.rpt
report area      > ./post_dft_area.rpt
report power     > ./post_dft_power.rpt
report gates     > ./post_dft_gates.rpt
report dft_setup > ./dft_setup.rpt
report dft_chains > ./scan_chains.rpt
check_dft_rules  > ./post_dft_rules.rpt

# 11. Write Post-DFT Netlist and Modus ATPG files
puts "\n>>> Writing Post-DFT Files and Modus Protocol..."
write_hdl > ./processor_post_dft.v
write_sdf > ./processor_post_dft.sdf
write_sdc > ./processor_post_dft.sdc
write_scandef > ./processor.scandef
write_dft_atpg -library ./processor_post_dft.v -directory ./

puts "\n============================================================"
puts "  Genus Synthesis + DFT Complete! (90nm)"
puts "============================================================"
gui_show
