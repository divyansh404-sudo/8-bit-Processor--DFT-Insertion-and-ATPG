puts "\n============================================="
puts "Starting Modus Test Run Script for processor"
puts "=============================================\n"

set WORKDIR ./
set CELL processor

# 1. CREATE RESULTS DIRECTORY
set RESULTS_DIR $WORKDIR/results
puts ">>> Creating results directory at $RESULTS_DIR"
file mkdir $RESULTS_DIR

## Set netlist
set NETLIST $WORKDIR/processor_post_dft.v

## Explicitly set 90nm Verilog Library based on your working reference!
puts ">>> Setting 90nm Library Models..."
set LIBRARY "/home/install/FOUNDRY/digital/90nm/dig/vlog/typical.v"

## Testmode information
set TESTMODE FULLSCAN

# Dynamically find pinassign and modedef
set ASSIGNFILE ""
set MODEDEF ""
catch {
    set ASSIGNFILE [exec bash -c "find $WORKDIR -type f -name \"*.pinassign\" | head -n 1"]
    set MODEDEF [exec bash -c "find $WORKDIR -type f -name \"*.modedef\" | head -n 1"]
}

#*************************************************
# BUILD MODEL
#*************************************************
puts  ">>> Building Test Model"
build_model  \
   -cell $CELL \
   -workdir $WORKDIR \
   -designsource $NETLIST \
   -techlib $LIBRARY \
   -designtop $CELL \
   -allowmissingmodules yes 

#*************************************************
# BUILD TEST MODE FULLSCAN
#*************************************************
puts ">>> Building Test Mode $TESTMODE"
if {$MODEDEF ne ""} {
    build_testmode -workdir $WORKDIR -testmode $TESTMODE -modedef $MODEDEF -assignfile $ASSIGNFILE 
} else {
    build_testmode -workdir $WORKDIR -testmode $TESTMODE -assignfile $ASSIGNFILE 
}

#*************************************************
# Verify & Report Test Structures
#*************************************************
puts ">>> Verifying Test Structures..."
verify_test_structures -workdir $WORKDIR -testmode $TESTMODE > $RESULTS_DIR/verify_structures.rpt

puts ">>> Reporting Test Structures..."
report_test_structures -workdir $WORKDIR -testmode $TESTMODE > $RESULTS_DIR/test_structures.rpt

#*************************************************
# BUILD FAULT MODEL
#*************************************************
puts ">>> Building Test Fault Model..."
build_faultmodel -fullfault yes

#*************************************************
# Create ATPG Vectors & Generate Reports
#*************************************************
puts ">>> Generating Scan Chain Tests..."
create_scanchain_tests -testmode $TESTMODE -experiment scan

puts ">>> Generating Logic Tests..."
create_logic_tests -testmode $TESTMODE -experiment logic

puts ">>> Generating Coverage Statistics..."
redirect $RESULTS_DIR/test_coverage_logic.rpt {
    report_statistics -experiment logic
}

puts ">>> Writing Verilog Vectors (Serial Format)..."
write_vectors -testmode $TESTMODE -inexperiment logic -language verilog -scanformat serial -outputfilename $RESULTS_DIR/test_results.v

puts "\n============================================="
puts "Modus Run Complete."
puts "All reports and vectors are saved in: $RESULTS_DIR"
puts "=============================================\n"

# Open the GUI for visualization
gui_open
