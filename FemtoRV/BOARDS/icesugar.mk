YOSYS_ICESUGAR_OPT=-DICE_SUGAR -q -p "synth_ice40 -relut -top $(PROJECTNAME) -json $(PROJECTNAME).json"
NEXTPNR_ICESUGAR_OPT=--force --json $(PROJECTNAME).json --pcf BOARDS/icesugar.pcf --asc $(PROJECTNAME).asc \
                       --freq 12 --up5k --package sg48

#######################################################################################################################

# Instructions
# in FemtoRV directory: make ICESUGAR (this will generate /FIRMWARE/config.mk)
# Compile firmware into hex file: in FIRMWARE/EXAMPLES: make hello.hex (this will generate firmware.hex in /FIRMWARE)
# back in FemtoRV: make ICESUGAR (run again this will now $readmemh("FIRMWARE/firmware.hex",RAM); in femtosoc.v and generate femtosoc.bin
# Windows: copy femtosoc.bin to iCELink device (iceprog in WSL can't access USB devices on Windows host)


ICESUGAR: ICESUGAR.firmware_config ICESUGAR.synth ICESUGAR.prog

ICESUGAR.synth: FIRMWARE/firmware.hex 
	TOOLS/make_config.sh -DICE_SUGAR
	yosys $(YOSYS_ICESUGAR_OPT) $(VERILOGS)
	nextpnr-ice40 $(NEXTPNR_ICESUGAR_OPT)
	icetime -p BOARDS/icesugar.pcf -P sg48 -r $(PROJECTNAME).timings -d up5k -t $(PROJECTNAME).asc
	icepack -s $(PROJECTNAME).asc $(PROJECTNAME).bin

ICESUGAR.show: FIRMWARE/firmware.hex 
	yosys $(YOSYS_ICESUGAR_OPT) $(VERILOGS)
	nextpnr-ice40 $(NEXTPNR_ICESUGAR_OPT) --gui

ICESUGAR.prog:
	icesprog $(PROJECTNAME).bin

ICESUGAR.firmware_config:
	BOARD=icesugar TOOLS/make_config.sh -DICE_SUGAR
	(cd FIRMWARE; make libs)