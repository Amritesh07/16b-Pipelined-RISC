#!/bin/bash
ghdl -a Components.vhd
ghdl -a AddressBlock.vhd
ghdl -a ALU.vhd
ghdl -a dRAM.vhd
ghdl -a FwdCntrl.vhd
ghdl -a GenericMux.vhd
ghdl -a InstructionDecoder.vhd
ghdl -a iRom.vhd
ghdl -a PipelineRegister.vhd
ghdl -a regfile.vhd
ghdl -a HazardUnit.vhd
ghdl -a Datapath.vhd
