# Programmable cartridge for Dendy-style consoles

Programmable PLD-based cartrige for Dendy-like consoles.

## Features
1. 1MB of SRAM for use as PRG ROM or PRG RAM
2. 1MB of SRAM for use as CHR ROM or CHR RAM
3. Atmel ATF1508 CPLD for glue logic, mapper implementation and flashing
4. LM66100 and a CR2032 battery holder to allow RAM to act as non-volatile storage
5. JTAG header for CPLD flashing

## Tooling
Makefile and linker configuration for writing programs
Pattern table generator script to generate pattern table contents from bitmaps

## Repo contents
cart - Kicad project and BOM
verilog - Verilog code for the ATF1508 CPLD
6502_development/demo_program - demo code for writing programs
6502_development/bmptransform - python script to generate pattern table contents from bmp images

