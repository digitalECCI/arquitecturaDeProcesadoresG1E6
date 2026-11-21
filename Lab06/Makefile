current_dir := ${CURDIR}
TOP := top
SOURCES := ${current_dir}/picosoc_noflash.v \
           ${current_dir}/picorv32.v \
           ${current_dir}/simpleuart.v \
           ${current_dir}/progmem.v

SIM_SOURCES := ${current_dir}/arty_tb.cpp

CROSS = riscv-none-elf-

SDC := ${current_dir}/picosoc.sdc

ifeq ($(TARGET), cycloneiv)
  SOURCES += ${current_dir}/top.v   
  QSF := ${current_dir}/top.qsf
  QUARTUS := 1   
else ifeq ($(TARGET), max10)
  SOURCES += ${current_dir}/top.v   
  QSF := ${current_dir}/top.qsf  
  QUARTUS := 1
else ifeq ($(TARGET),arty_35)
  SOURCES += ${current_dir}/arty.v
  PCF := ${current_dir}/arty.pcf
else ifeq ($(TARGET),arty_100)
  SOURCES += ${current_dir}/arty.v
  PCF := ${current_dir}/arty.pcf
else ifeq ($(TARGET),nexys4ddr)
  SOURCES += ${current_dir}/nexys4ddr.v
  PCF := ${current_dir}/nexys4ddr.pcf
else
  SOURCES += ${current_dir}/basys3.v
  PCF := ${current_dir}/basys3.pcf
endif


firmware: main.elf
	$(CROSS)objcopy -O binary main.elf main.bin
	python3 progmem.py

main.elf: main.lds start.s main.c
	$(CROSS)gcc $(CFLAGS) -march=rv32im -mabi=ilp32 -Wl,--build-id=none,-Bstatic,-T,main.lds,-Map,main.map,--strip-debug -ffreestanding -nostdlib \
	-o main.elf start.s main.c

main.lds: sections.lds
	$(CROSS)gcc -E -P -x c -o $@ $^

sim: firmware
	verilator -I./ -Wall --trace -cc ${current_dir}/arty.v $(SOURCES) --exe $(SIM_SOURCES)

waveform:
	make -C ./obj_dir -f Varty.mk Varty
	./obj_dir/Varty


# ---------------------------------------------------
# Flujo Quartus para Cyclone IV y Max10
# ---------------------------------------------------

ifeq ($(QUARTUS), 1)

QUARTUS_MAP := quartus_map
QUARTUS_FIT := quartus_fit
QUARTUS_ASM := quartus_asm
QUARTUS_PGM := quartus_pgm

build: map fit asm

map:
	$(QUARTUS_MAP) --read_settings_files=on --write_settings_files=off $(TOP)

fit:
	$(QUARTUS_FIT) --read_settings_files=on --write_settings_files=off $(TOP)

asm:
	$(QUARTUS_ASM) $(TOP)

pof: asm
	@echo "pof generado en output_files/$(TOP).pof"

program: pof
	$(QUARTUS_PGM) -c USB-Blaster -m JTAG -o "p;output_files/$(TOP).pof"

clean_fw:
	rm -f main.elf
	rm -f main.lds
	rm -f main.map
	rm -f main.bin
	rm -f progmem.v

clean_sim:
	rm -rf ./obj_dir
	rm -f ./waveform.vcd

clean_quartus:
	rm -rf db incremental_db output_files

.PHONY: map fit asm build pof program clean_fw clean_sim clean_quartus

else

# ---------------------------------------------------
# Flujo original con pcf (nextpnr)
# ---------------------------------------------------


flash:
	openocd -f ${DIGILENT_CFG_DIR}/digilent_arty.cfg -c 'init; jtagspi_init 0 ${BSCAN_DIR}/bscan_spi_xc7a100t.bit; \
	jtagspi_program {${BOARD_BUILDDIR}/${TOP}.bit} 0x0; exit'

program:
	openocd -f ${DIGILENT_CFG_DIR}/digilent_arty.cfg -c 'init; pld load 0 ${BOARD_BUILDDIR}/${TOP}.bit; exit';

clean_fw:
	rm -f main.elf
	rm -f main.lds
	rm -f main.map
	rm -f main.bin
	rm -f progmem.v

clean_sim:
	rm -rf ./obj_dir
	rm -f ./waveform.vcd

.PHONY: flash program clean_fw clean_sim

endif