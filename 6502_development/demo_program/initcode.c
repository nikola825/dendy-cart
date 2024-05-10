#include "common.h"

extern unsigned char _DATA_LOAD__;
extern unsigned char _DATA_RUN__;
extern unsigned char _DATA_SIZE__;

// Copy from RODATA to actual DATA in the onboard RAM
void copy_data_to_ram()
{
    zpw1 = (unsigned int) (&_DATA_SIZE__);
    zpw2 = (unsigned int) (&_DATA_LOAD__);
    zpw3 = (unsigned int) (&_DATA_RUN__);

    while (zpw1)
    {
        *((unsigned char *) zpw3) = *((unsigned char *) zpw2);
        --zpw1;
        ++zpw2;
        ++zpw3;
    }
}

unsigned char debug_status_var;

void debug_status(unsigned char c)
{
    debug_status_var = c;
    BANKSELECTOR = c;
    BANKSELECTOR = 0x80 | selbank;
}

// Read joystick
unsigned char joyread()
{
    JOYPORT1 = 1;
    zpb1 = 0;
    JOYPORT1 = 0;
    for (zpb2 = 0; zpb2 < 8; zpb2++)
    {
        zpb1 <<= 1;
        zpb1 |= (JOYPORT2 & 1);
    }
    return zpb1;
}

void nmi()
{
    if (ppu_ready)
    {
        if (PPUSTATUS & 128)
        {
            blanked = 1;
        }
    }
}

// Utility functions for MMC-style mappers
void mmc_control(unsigned char control_value)
{
    MMC1_CONTROL = 0xff;
    MMC1_CONTROL = control_value & 1;
    control_value >>= 1;
    MMC1_CONTROL = control_value & 1;
    control_value >>= 1;
    MMC1_CONTROL = control_value & 1;
    control_value >>= 1;
    MMC1_CONTROL = control_value & 1;
    control_value >>= 1;
    MMC1_CONTROL = control_value & 1;
}

void prg_banksel(unsigned char bank)
{
    MMC1_PRG = 0xff;
    MMC1_PRG = bank & 1;
    bank >>= 1;
    MMC1_PRG = bank & 1;
    bank >>= 1;
    MMC1_PRG = bank & 1;
    bank >>= 1;
    MMC1_PRG = bank & 1;
    bank >>= 1;
    MMC1_PRG = bank & 1;
}

void chr0_banksel(unsigned char bank)
{
    MMC1_CHR0 = 0xff;
    MMC1_CHR0 = bank & 1;
    bank >>= 1;
    MMC1_CHR0 = bank & 1;
    bank >>= 1;
    MMC1_CHR0 = bank & 1;
    bank >>= 1;
    MMC1_CHR0 = bank & 1;
    bank >>= 1;
    MMC1_CHR0 = bank & 1;
}

void chr1_banksel(unsigned char bank)
{
    MMC1_CHR1 = 0xff;
    MMC1_CHR1 = bank & 1;
    bank >>= 1;
    MMC1_CHR1 = bank & 1;
    bank >>= 1;
    MMC1_CHR1 = bank & 1;
    bank >>= 1;
    MMC1_CHR1 = bank & 1;
    bank >>= 1;
    MMC1_CHR1 = bank & 1;
}

#pragma wrapped-call (push, trampoline, bank)

extern void ppu_init();

extern void flush_oam();

#pragma wrapped-call (pop);

void delay()
{
    int i;
    for (i = 0; i < 1000; i++)
    {

    }
}

void consolemain()
{
    BANKSELECTOR = 1;
    blanked = 0;
    ppu_init();

    while (1)
    {
        if (blanked)
        {
            blanked = 0;

            // Detect joystick presses and move the "mouse"
            zpb1 = joyread();
            if (zpb1 & 1)
            {
                if (oam[0].x < 254) oam[0].x += 2;
            }
            if (zpb1 & 2)
            {
                if (oam[0].x > 2) oam[0].x -= 2;
            }
            if (zpb1 & 4)
            {
                if (oam[0].y < 238) oam[0].y += 2;
            }
            if (zpb1 & 8)
            {
                if (oam[0].y > 0) oam[0].y -= 2;
            }

            // Highlight the "icons"
            PPUADDR = 0x3f;
            PPUADDR = 0x03;
            if (oam[0].x >= 19 && oam[0].x <= 45 && oam[0].y >= 19 && oam[0].y <= 45)
            {
                PPUDATA = 0x01;
            }
            else
            {
                PPUDATA = 0x21;
            }
            PPUADDR = 0x3f;
            PPUADDR = 0x0b;
            if (oam[0].x >= 211 && oam[0].x <= 237 && oam[0].y >= 178 && oam[0].y <= 207)
            {
                PPUDATA = 0x01;
            }
            else
            {
                PPUDATA = 0x21;
            }

            PPUCTRL = 128;
            PPUSCROLL = 0x00;
            PPUSCROLL = 0x00;

            // Flush the new sprite positions into OAM RAM
            flush_oam();
        }
    }
}
