CC := cl65
AS := ca65
LD := ld65
PYTHON = ../venv/bin/python
OBJDIR := obj
ROMDIR := roms
ASFLAGS :=
CCFLAGS := -O --cpu 6502 --standard c99
LDFLAGS :=

SOURCES := $(wildcard *.c)
ASSEMBLIES := $(wildcard *.s)
LIBASSEMBLIES := $(wildcard ../cc65lib/*.s)
BITMAPS := $(wildcard bitmaps/*.bmp)

COBJECTS := $(SOURCES:%.c=$(OBJDIR)/%.o)
ASOBJECTS := $(ASSEMBLIES:%.s=$(OBJDIR)/%.so)
LIBOBJECTS := $(LIBASSEMBLIES:%.s=$(OBJDIR)/%.so)

all: $(ROMDIR)/rom.rom
	@echo "DONE"

$(ROMDIR)/rom.rom: linker.cfg $(ASOBJECTS) $(COBJECTS) $(LIBOBJECTS)
	@echo "[LD]"$@
	@mkdir -p $(dir $@)
	@$(LD) -o $@ $(LDFLAGS) -C linker.cfg  $(ASOBJECTS) $(COBJECTS) $(LIBOBJECTS)

$(OBJDIR)/%.o:%.c patterns_gen.h common.h
	@echo "[CC]"$<
	@mkdir -p $(dir $@)
	@$(CC) -o $@ $(CCFLAGS) -c $<

$(OBJDIR)/%.so:%.s
	@echo "[AS]"$^
	@mkdir -p $(dir $@)
	@$(AS) -o $@ $(ASFLAGS) $^

patterns_gen.h:$(BITMAPS)
	@echo "Generating pattern table"
	@$(PYTHON) ../bmptransform/transform.py bitmaps/ patterns_gen.h

clean:
	rm -rf $(OBJDIR)
	rm -rf $(ROMDIR)
	rm -f patterns_gen.h

.PHONY: clean
