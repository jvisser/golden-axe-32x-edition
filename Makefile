.DEFAULT_GOAL := release

# Default paths, can be overridden by setting MARSDEV before calling make
MARSDEV    ?= ${HOME}/mars
TOOLSBIN    = $(MARSDEV)/bin
MDBIN       = $(MARSDEV)/m68k-elf/bin
SHBIN       = $(MARSDEV)/sh-elf/bin
MDSRC       = src/md
BUILD       = out
INCLUDE     = src/include
MDINCLUDE   = $(INCLUDE)/md
MDBUILD     = $(BUILD)/md
MDASSETS    = $(MDBUILD)/assets
ROM         = rom/rom.bin
JAVATOOLS   = tools

# m68k GCC and Binutils
MDCC        = $(MDBIN)/m68k-elf-gcc
MDCXX       = $(MDBIN)/m68k-elf-g++
MDAS        = $(MDBIN)/m68k-elf-as
MDLD        = $(MDBIN)/m68k-elf-ld
MDNM        = $(MDBIN)/m68k-elf-nm
MDOBJC      = $(MDBIN)/m68k-elf-objcopy

# sh2 GCC and Binutils
SHCC        = $(SHBIN)/sh-elf-gcc
SHCXX       = $(SHBIN)/sh-elf-g++
SHAS        = $(SHBIN)/sh-elf-as
SHLD        = $(SHBIN)/sh-elf-ld
SHNM        = $(SHBIN)/sh-elf-nm
SHOBJC      = $(SHBIN)/sh-elf-objcopy

# Some files needed are in a versioned directory
MDCC_VER    := $(shell $(MDCC) -dumpversion)
SHCC_VER    := $(shell $(SHCC) -dumpversion)

# Assembler flags
MDASFLAGS   = -m68000 -I $(MDSRC) -I $(MDINCLUDE) -I $(MDASSETS)
SHASFLAGS   = --small

# Linker flags
MDLDFLAGS   = -L $(MDBUILD) -T $(MDSRC)/md.ld -nostdlib -N -x
SHLDFLAGS   = -T $(MARSDEV)/ldscripts/mars.ld -nostdlib

# Generate MD object target list
MDSS        := $(wildcard $(MDSRC)/*.s $(MDSRC)/*/*.s)
MDOBJS      := $(patsubst $(MDSRC)/%.s, $(MDBUILD)/obj/%.o, $(MDSS))

.PHONY: pre-build make-assets extract-amazon-tile-data build-tools dump-gfx clean rebuild

rebuild: clean release

release: pre-build make-assets $(BUILD)/patch.ips

make-assets: extract-amazon-tile-data

clean:
	@rm -f -r $(BUILD)

pre-build:
	@mkdir -p $(MDASSETS)

# Build java tools
build-tools:
	mvn -f $(JAVATOOLS)/pom.xml clean package

# Dump graphics data from the original game's ROM file
dump-gfx:
	java -jar $(JAVATOOLS)/DataVis/target/DataVis.jar -c config/datavis.yaml -o dump $(ROM)

# Extract amazon tile data
extract-amazon-tile-data: $(MDASSETS)/amazon.nem
$(MDASSETS)/amazon.nem: $(ROM)
	$(TOOLSBIN)/nemcmp -x0x7A25A $< $@

# Assemble MD modules
$(MDOBJS): $(MDBUILD)/obj/%.o : $(MDSRC)/%.s
	@echo "MDAS $<"
	@mkdir -p $(dir $@)
	@$(MDAS) $(MDASFLAGS) $< -o $@

# Generate intermediate MD object file used to generate the linker script include file for the patches
$(MDBUILD)/patch.o: $(MDOBJS)
	$(MDLD) -relocatable $(MDOBJS) -o $@

# Generate linked output
$(MDBUILD)/patch.elf: $(MDBUILD)/patch.o
	@scripts/make_patch_ld $(MDBIN)/m68k-elf-size $< $(MDBUILD)/patch.ld.generated
	$(MDLD) $(MDLDFLAGS) $< -o $@

# Generate .ips file
$(BUILD)/patch.ips: $(MDBUILD)/patch.elf
	@$(MDOBJC) -O binary $< $(MDBUILD)/patch.bin
	@$(MDOBJC) --dump-section patch_index=$(MDBUILD)/patch.index $<
	java -jar $(JAVATOOLS)/MakeIPS/target/MakeIPS.jar -i $(MDBUILD)/patch.index -p $(MDBUILD)/patch.bin $@
