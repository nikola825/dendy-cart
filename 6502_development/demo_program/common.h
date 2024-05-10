//
// Created by nidzo on 2/3/24.
//

#ifndef CODE_CONSOLE_H
#define CODE_CONSOLE_H

extern unsigned char BANKSELECTOR;
extern unsigned char MMC1_CONTROL;
extern unsigned char MMC1_CHR0;
extern unsigned char MMC1_CHR1;
extern unsigned char MMC1_PRG;

extern volatile unsigned char JOYPORT1, JOYPORT2;
extern volatile unsigned char PPUSTATUS;
extern volatile unsigned char PPUCTRL;
extern volatile unsigned char PPUMASK;
extern volatile unsigned char PPUADDR;
extern volatile unsigned char PPUDATA;
extern volatile unsigned char PPUSCROLL;
extern volatile unsigned char OAMADDR;
extern volatile unsigned char OAMDMA;

extern volatile unsigned char CART_RAM;

extern unsigned char zpb1;
extern unsigned char zpb2;
extern unsigned char zpb3;
extern unsigned char zpb4;
extern unsigned int zpw1;
extern unsigned int zpw2;
extern unsigned int zpw3;
extern unsigned int zpw4;
extern unsigned char selbank;
#pragma zpsym ("zpb1");
#pragma zpsym ("zpb2");
#pragma zpsym ("zpb3");
#pragma zpsym ("zpb4");
#pragma zpsym ("zpw1");
#pragma zpsym ("zpw2");
#pragma zpsym ("zpw3");
#pragma zpsym ("zpw4");
#pragma zpsym ("selbank");

struct Sprite
{
    unsigned char y;
    unsigned char tile;
    unsigned char attributes;
    unsigned char x;
};
extern struct Sprite oam[64];

extern unsigned char ppu_ready;
extern volatile unsigned char blanked;

extern void trampoline();

#endif //CODE_CONSOLE_H
