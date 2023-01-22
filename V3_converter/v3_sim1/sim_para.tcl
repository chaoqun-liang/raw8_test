lappend auto_path "C:/lscc/radiant/3.2/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {je5d00}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {LIFCL}
set ::bali::simulation::Para(PROJECT) {v3_sim1}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/chaoq/my_designs/csi2cpi/V3_converter}
set ::bali::simulation::Para(FILELIST) {"C:/Users/chaoq/my_designs/csi2cpi/D_unpack/my_fifo1/rtl/my_fifo1.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/payload_unpack.sv" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/sync_unpack.sv" "C:/Users/chaoq/my_designs/csi2cpi/D_unpack/int_gpll/rtl/int_gpll.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/axis4_slave_if.sv" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/DPHY_INST.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/wrapper_test_da.sv" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/bus_driver.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/clk_driver.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/csi2_model.v" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/source/impl_1/tb_da.sv" "C:/Users/chaoq/my_designs/csi2cpi/V3_converter/myDphy/rtl/myDphy.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"" "work" "work" "" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"" "System Verilog" "System Verilog" "" "System Verilog" "Verilog 2001" "System Verilog" "Verilog 2001" "Verilog 2001" "Verilog 2001" "System Verilog" "" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_lifcl}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {tb_da}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/3.2}
set ::bali::simulation::Para(MEMPATH) {C:/Users/chaoq/my_designs/csi2cpi/V3_converter/myDphy}
set ::bali::simulation::Para(UDOLIST) {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(SIMULATIONTIME)  {100}
set ::bali::simulation::Para(SIMULATIONTIMEUNIT)  {ns}
set ::bali::simulation::Para(ISRTL)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
::bali::simulation::ModelSim_Run
