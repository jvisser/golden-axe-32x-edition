# TODO: Auto generate .d dependency make files

.DEFAULT_GOAL := release

# Default paths, can be overridden by setting MARSDEV before calling make
MARSDEV    ?= ${HOME}/mars
TOOLSBIN    = $(MARSDEV)/bin
MDBIN       = $(MARSDEV)/m68k-elf/bin
SHBIN       = $(MARSDEV)/sh-elf/bin

# Project paths
ASSETSRC    = assets
MDSRC       = src/md
SHSRC       = src/mars
INCLUDE     = src/include
BUILD       = out
MDBUILD     = $(BUILD)/md
MDASSETS    = $(MDBUILD)/assets
SHBUILD     = $(BUILD)/mars
ROM         = rom/rom.bin
JAVATOOLS   = tools

# Includes paths
MDINCLUDE   = -I $(INCLUDE)/md -I $(MDSRC) -I $(ASSETSRC) -I $(MDASSETS) -I $(SHBUILD)
SHINCLUDE   = -I $(INCLUDE)/mars

# m68k GCC and Binutils
MDCC        = $(MDBIN)/m68k-elf-gcc
MDCXX       = $(MDBIN)/m68k-elf-g++
MDAS        = $(MDBIN)/m68k-elf-as
MDLD        = $(MDBIN)/m68k-elf-ld
MDNM        = $(MDBIN)/m68k-elf-nm
MDOBJC      = $(MDBIN)/m68k-elf-objcopy
MDSIZE      = $(MDBIN)/m68k-elf-size

# SH2 GCC and Binutils
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
MDASFLAGS   = -m68000 --bitwise-or $(MDINCLUDE)
SHASFLAGS   = --small $(SHINCLUDE)

# Linker flags
MDLDFLAGS   = -L $(MDBUILD) -T $(MDSRC)/md.ld -nostdlib -N
SHLDFLAGS   = -T $(SHSRC)/mars.ld -nostdlib

# C compiler flags
MDCCFLAGS  = -m68000 -Wall -Wextra -std=c99 -ffreestanding -fshort-enums -Os -fomit-frame-pointer
SHCCFLAGS  = -m2 -mb -Wall -Wextra -std=c99 -ffreestanding -fshort-enums -O3 -fomit-frame-pointer -flto -fuse-linker-plugin

# Generate MD m68k object target list
MDSS        = $(wildcard $(MDSRC)/*.s $(MDSRC)/*/*.s)
MDOBJS      = $(patsubst $(MDSRC)/%.s, $(MDBUILD)/obj/%.o, $(MDSS))

# Generate 32X SH2 object target list
SHSS        = $(wildcard $(SHSRC)/*.s $(SHSRC)/*/*.s)
SHCS       += $(wildcard $(SHSRC)/*.c $(SHSRC)/*/*.c)
SHSOBJS     = $(patsubst $(SHSRC)/%.s, $(SHBUILD)/obj/%.o, $(SHSS))
SHCOBJS    += $(patsubst $(SHSRC)/%.c, $(SHBUILD)/obj/%.o, $(SHCS))
SHOBJS      = $(SHSOBJS) $(SHCOBJS)

# Generate asset target lists
MDIMGSRC    = $(wildcard $(ASSETSRC)/img/*.png)
MDIMGS      = $(patsubst $(ASSETSRC)/img/%.png, $(MDASSETS)/img/%.img, $(MDIMGSRC))
MDPATSRC    = $(wildcard $(ASSETSRC)/pattern/*.png)
MDPATS      = $(patsubst $(ASSETSRC)/pattern/%.png, $(MDASSETS)/pattern/%.pat, $(MDPATSRC))
MDPATNEMS   = $(patsubst $(ASSETSRC)/pattern/%.png, $(MDASSETS)/pattern/%.pat.nem, $(MDPATSRC))
MDMAPSRC    = $(wildcard $(ASSETSRC)/map/**/*.tmx)
MDMAPOBJS   = $(patsubst $(ASSETSRC)/map/%.tmx, $(MDASSETS)/map/%.o, $(MDMAPSRC))

.PHONY: pre-build build-tools dump-gfx clean rebuild apply-patch

rebuild: clean release

release: pre-build $(SHBUILD)/mars.bin $(BUILD)/patch.ips

patch: release $(BUILD)/rom.32x

clean:
	@rm -f -r $(BUILD)

# Build java tools
init:
	mvn -f $(JAVATOOLS)/pom.xml clean package

# Dump graphics data from the original game's ROM file
dump-gfx:
	java -jar $(JAVATOOLS)/DataVis/target/DataVis.jar -c config/datavis.yaml -o dump $(ROM)

pre-build:
	@mkdir -p $(MDASSETS)
	@mkdir -p $(SHBUILD)

# Assemble 32X SH2 assembly modules
# Run preprocessor as a separate pass as gcc will not pass the include paths to AS needed for the .incbin directive :/
$(SHSOBJS): $(SHBUILD)/obj/%.o : $(SHSRC)/%.s
	@echo "SHAS $@: $<"
	@mkdir -p $(dir $@)
	@$(SHCC) -E -P $(SHINCLUDE) -D __ASSEMBLER__=1 -o /dev/stdout - < $< | $(SHAS) $(SHASFLAGS) -o $@ --

# Assemble 32X SH2 c modules
$(SHCOBJS): $(SHBUILD)/obj/%.o : $(SHSRC)/%.c
	@echo "SHCC $@: $<"
	@mkdir -p $(dir $@)
	@$(SHCC) $(SHCCFLAGS) $(SHINCLUDE) -c $< -o $@

# Link 32X sub program
$(SHBUILD)/mars.elf: $(SHOBJS)
	@echo "SHCC(LD) $@: $?"
	@$(SHCC) $(SHLDFLAGS) $(SHOBJS) -o $@ $(SHLIBS)

# Create 32X sub program binary
$(SHBUILD)/mars.bin: $(SHBUILD)/mars.elf
	@echo "SHOBJC $@: $<"
	@$(SHOBJC) -O binary $< $@

# Extract amazon tile data
$(MDASSETS)/amazon.pat: $(ROM)
	@echo "NEMCMP -x $@: $<"
	@$(TOOLSBIN)/nemcmp -x0x7A25A $< $@

# Transform images
$(MDIMGS): $(MDASSETS)/img/%.img : $(ASSETSRC)/img/%.png
	@echo "IMGCONV $@: $<"
	@java -jar $(JAVATOOLS)/ImgConv/target/ImgConv.jar $< $@

# Transform md tilemaps
$(MDPATS): $(MDASSETS)/pattern/%.pat : $(ASSETSRC)/pattern/%.png
	@echo "MDDTILER $@: $<"
	@mkdir -p $(dir $@)
	@$(TOOLSBIN)/mdtiler -b $<.mdtiler

# Compress md tilemap tiles
$(MDPATNEMS): $(MDASSETS)/pattern/%.pat.nem : $(MDASSETS)/pattern/%.pat
	@echo "NEMCMP $@: $<"
	@$(TOOLSBIN)/nemcmp $< $@

# Transform 32X tilemaps
$(MDMAPOBJS): $(MDASSETS)/map/%.o : $(ASSETSRC)/map/%.tmx
	@echo "MAPCONV $@: $<"
	@mkdir -p $(dir $@)
	@java -jar $(JAVATOOLS)/MapConv/target/MapConv.jar $< | $(MDAS) $(MDASFLAGS) -o $@ --

$(MDBUILD)/obj/resources.o: $(MDIMGS) $(MDPATNEMS) $(MDASSETS)/amazon.pat $(SHBUILD)/mars.bin

# Assemble MD m68k modules
# Run preprocessor as a separate pass as gcc will not pass the include paths to AS needed for the .incbin directive :/
$(MDOBJS): $(MDBUILD)/obj/%.o : $(MDSRC)/%.s
	@echo "MDAS $@: $<"
	@mkdir -p $(dir $@)
	@$(MDCC) -E -P $(MDINCLUDE) -D __ASSEMBLER__=1 -o /dev/stdout - < $< | $(MDAS) $(MDASFLAGS) -o $@ --

# Generate intermediate MD object file used to generate the linker script include file for the patches
$(MDBUILD)/patch.o: $(MDOBJS) $(MDMAPOBJS)
	@echo "MDLD $@: $?"
	@$(MDLD) -relocatable $(MDOBJS) $(MDMAPOBJS) -o $@

# Generate linker script for patches
$(MDBUILD)/patch.ld.generated: $(MDBUILD)/patch.o
	@echo "MAKE_PATCH_LD $@: $<"
	@scripts/make-patch-ld $(MDSIZE) $< $@

# Generate linked output
$(MDBUILD)/patch.elf: $(MDBUILD)/patch.o $(MDBUILD)/patch.ld.generated
	@echo "MDLD $@: $?"
	@$(MDLD) $(MDLDFLAGS) $< -o $@

# Generate .ips file
$(BUILD)/patch.ips: $(MDBUILD)/patch.elf
	@echo "MAKEIPS $@: $<"
	@$(MDOBJC) -O binary $< $(MDBUILD)/patch.bin
	@$(MDOBJC) --dump-section patch_index=$(MDBUILD)/patch.index $<
	@java -jar $(JAVATOOLS)/MakeIPS/target/MakeIPS.jar -p 0x100000 -i $(MDBUILD)/patch.index -c $(MDBUILD)/patch.bin $@

# Apply patch and create patched ROM image file for testing
$(BUILD)/rom.32x: $(BUILD)/patch.ips
	@echo "FLIPS $@: $<"
	@flips --apply --ips $< $(ROM) $@
