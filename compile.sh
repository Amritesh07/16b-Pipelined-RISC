#!/bin/bash
ghdl -a Components.vhd
ghdl -a AddressBlock.vhd
ghdl -a ALU.vhd
ghdl -a Entities.vhd
ghdl -a dRAM.vhd
ghdl -a FwdCntrl.vhd
ghdl -a GenericMux.vhd
ghdl -a InstructionDecoder.vhd
ghdl -a iROM.vhd
ghdl -a PipelineRegister.vhd
ghdl -a regfile.vhd
ghdl -a HazardUnit.vhd
ghdl -a Datapath.vhd
ghdl -a pilot.vhd
ghdl -a final_test.vhd
ghdl -m Grand_Testh
./grand_testh --wave=run.ghw --stop-time=5000ns
