//`include "mmc1.v"

module unrom_mapper (
    input m2,
    output reg [7:0] dbg,
    output [7:0] cpu_bs,
    output cpu_oe,
    output cpu_ce,
    output cpu_ce_comp,
    output cpu_we,
    input [7:0] cpu_data,
    input m2dc,
    //  output irq,
    input cpu_rw,
    input romsel,
    input [14:12] cpu_addr,
    //    input cpu_a0,
    input [13:10] ppu_addr,
    output [9:0] ppu_bs,
    output ppu_we,
    output ciram_a10,
    output ciram_ce,
    input ppu_rd,
    output ppu_ce_comp,
    input ppu_wr,
    output ppu_oe,
    output ppu_ce,
    input reset_pin
);

// verify that these match your pinout
    //pragma attribute m2 pin_number 2
    //pragma attribute dbg pin_number "12 15 11 10 9 8 6 5"
    //pragma attribute cpu_bs pin_number "16 17 18 21 24 25 27 29"
    //pragma attribute cpu_oe pin_number 20
    //pragma attribute cpu_ce pin_number 22
    //pragma attribute cpu_ce_comp pin_number 28
    //pragma attribute cpu_we pin_number 30
    //pragma attribute cpu_data pin_number "31 33 34 36 39 37 41 40"
    //pragma attribute m2dc pin_number 44
    //pragma attribute irq pin_number 45
    //pragma attribute cpu_rw pin_number 46
    //pragma attribute romsel pin_number 48
    //pragma attribute cpu_addr pin_number "51 50 49"
    //pragma attribute ppu_addr pin_number "54 52 55 57"
    //pragma attribute cpu_a0 pin_number 35
    //pragma attribute ppu_bs pin_number "80 76 75 74 73 70 69 68 67 56"
    //pragma attribute ppu_we pin_number 58
    //pragma attribute ciram_a10 pin_number 60
    //pragma attribute ciram_ce pin_number 61
    //pragma attribute ppu_rd pin_number 63
    //pragma attribute ppu_ce_comp pin_number 64
    //pragma attribute ppu_wr pin_number 65
    //pragma attribute ppu_oe pin_number 77
    //pragma attribute ppu_ce pin_number 79
    //pragma attribute reset_pin pin_number 1

    parameter MAPPER_INIT = 2'b00;
    parameter MAPPER_FLASH = 2'b01;
    parameter MAPPER_UNROM = 2'b10;
    parameter MAPPER_MMC1 = 2'b11;

    reg [3:0] boot_counter;
    reg booted;
    reg [7:0] cpu_bs_reg;
    reg vert_mirror;
    reg [1:0] mapper;

    `include "unromnrom.v"
    `include "mmc1.v"

    assign cpu_bs = (mapper==MAPPER_FLASH) ? cpu_bs_reg :
                    (mapper==MAPPER_INIT) ? {5'b11111, cpu_addr[14:12]} :
                    (mapper==MAPPER_UNROM) ? unrom_cpu_bs :
                    (mapper==MAPPER_MMC1) ? mmc1_cpu_bs :
                    8'h00;

    wire cpu_enable;
    assign cpu_enable = (mapper==MAPPER_FLASH) ? (m2 & romsel) :
                        (mapper==MAPPER_INIT)  ? (~romsel) :
                        (mapper==MAPPER_UNROM) ? unrom_cpu_enable :
                        (mapper==MAPPER_MMC1) ? mmc1_cpu_enable :
                        1'b0;

    assign cpu_ce = cpu_enable;
    assign cpu_ce_comp = ~cpu_enable;

    wire cpu_write;
    assign cpu_we = ~cpu_write;
    assign cpu_write = (mapper==MAPPER_FLASH) ? (m2 & romsel & (~cpu_rw)) :
                       (mapper==MAPPER_MMC1) ? mmc1_cpu_write :
                       1'b0;

    wire cpu_read;
    assign cpu_oe = ~cpu_read;
    assign cpu_read = (mapper==MAPPER_FLASH) ? (m2 & romsel & cpu_rw) :
                      (mapper==MAPPER_INIT)  ? ((~romsel) & cpu_rw) :
                      (mapper==MAPPER_UNROM) ? unrom_cpu_read :
                      (mapper==MAPPER_MMC1) ? mmc1_cpu_read :
                      1'b0;

    wire special;
    assign special = (~romsel) & (~cpu_rw);

    wire ppu_writable;
    assign ppu_writable = (mapper==MAPPER_FLASH)|(mapper==MAPPER_UNROM)|(mapper==MAPPER_MMC1);

    assign ppu_bs = (mapper==MAPPER_MMC1) ? mmc1_ppu_bs :
                    (mapper==MAPPER_UNROM) ? unrom_ppu_bs :
                    {7'b0000000, ppu_addr[12:10]};

    assign ppu_we = ~(ppu_writable & (~ppu_wr));
    assign ppu_oe = ppu_rd;
    assign ciram_ce = ~(ppu_addr[13]);

    wire ppu_enabled;
    assign ppu_enabled = booted & (~ppu_addr[13]);

    assign ppu_ce = ppu_enabled;
    assign ppu_ce_comp = ~ppu_enabled;

    wire vert_mirror_select = (mapper==MAPPER_UNROM) ? unrom_vert_mirror :
                              (mapper==MAPPER_MMC1) ? mmc1_vert_mirror :
                              vert_mirror;

    assign ciram_a10 = vert_mirror_select ? ppu_addr[10] : ppu_addr[11];

    task init_special;
        begin
            if (cpu_data[6:0] == 7'b0000001) begin
                mapper <= MAPPER_UNROM;
                unrom_init;
            end else if (cpu_data[6:0] == 7'b0000010) begin
                mapper <= MAPPER_MMC1;
                mmc1_init;
            end else if (cpu_data == 8'he7) begin
                mapper <= MAPPER_FLASH;
                dbg <= cpu_data;
                vert_mirror <= 1'b0;
            end else begin
                vert_mirror <= cpu_data[7];
            end
        end
    endtask

    task flash_special;
        begin
            cpu_bs_reg <= cpu_data;
            dbg <= cpu_data;
        end
    endtask

    always @(negedge m2 or negedge reset_pin) begin
        if (reset_pin) begin
            if (!booted) begin
                // When in boot mode, wait for 16 clocks before switching to init mode
                if (boot_counter == 4'hf) begin
                    booted <= 1'b1;
                    dbg <= 8'hff;
                    cpu_bs_reg <= 8'hff;
                end else begin
                    booted <= 1'b0;
                    dbg <= 8'h00;
                    boot_counter <= boot_counter + 4'h1;
                end
                mapper <= MAPPER_INIT;
            end else if (special) begin
                // Handle a write in the 0x8000-0xffff bank, differend behaviors depending on mode
                case (mapper)
                    MAPPER_INIT:  init_special;
                    MAPPER_FLASH: flash_special;
                    MAPPER_UNROM: unrom_special;
                    MAPPER_MMC1:  mmc1_special;
                endcase
            end
        end else if (~reset_pin) begin
            // active-low reset
            booted <= 1'b0;
            dbg <= 8'h00;
            boot_counter <= 4'h0;
            mapper <= MAPPER_INIT;
            mmc1_reset;
        end
    end

endmodule
