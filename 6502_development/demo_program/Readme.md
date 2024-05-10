# Demo program
A program that renders a desktop-like dummy screen with mouse cursor and icons

## Contents
- asmstubs.s - boilerplate stuff to get the program running
- initcode.c - main C code stuff - handles events, mappers and so on
- ppu_loading.c - initializes the pattern table, name table and palletes
- zeropage.c - defines memory locations in the zeropage
- linker.cfg - defines the layout to build to iNES2.0 ROM with the UNROM mapper

## Requirements
- CC65 compiler for the 6502 CPU https://cc65.github.io/
