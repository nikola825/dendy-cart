reg [4:0] mmc1_control;
reg [4:0] mmc1_buffer;
reg [4:0] mmc1_ppu_bank0;
reg [4:0] mmc1_ppu_bank1;

wire chr_8k_banking;
wire prg_low_switchable;
wire prg_high_switchable;
wire prg_32k_mode;

assign chr_8k_banking = ~(mmc1_control[4]);
assign prg_low_switchable = mmc1_control[3] & mmc1_control[2];
assign prg_high_switchable = mmc1_control[3] & (~mmc1_control[2]);
assign prg_32k_mode = ~mmc1_control[3];

wire mmc1_ramsel;
assign mmc1_ramsel = ((~m2dc) & romsel) & cpu_addr[14] & cpu_addr[13];

wire mmc_cpu_select;
assign mmc_cpu_select = ~mmc1_ramsel &
                        ((prg_low_switchable & (~cpu_addr[14])) |
                         (prg_high_switchable & cpu_addr[14]) |
                         prg_32k_mode);

wire [7:0] mmc1_cpu_bs;
assign mmc1_cpu_bs = mmc_cpu_select ? (
                            prg_32k_mode ? { 2'b00, cpu_bs_reg[5:3], cpu_addr[14:12]} :
                            { 2'b00, cpu_bs_reg[5:2], cpu_addr[13:12]}
                        ) :
                        mmc1_ramsel ? { 7'b0111111, cpu_addr[12]} :
                        { 2'b00, {4{cpu_addr[14]}}, cpu_addr[13:12]};

wire mmc1_cpu_enable;
assign mmc1_cpu_enable = (~romsel) | mmc1_ramsel;

wire mmc1_cpu_write;
assign mmc1_cpu_write = mmc1_ramsel & (~cpu_rw);

wire mmc1_cpu_read;
assign mmc1_cpu_read = cpu_rw & ((~romsel) | mmc1_ramsel);

wire mmc1_vert_mirror;
assign mmc1_vert_mirror = mmc1_control[1] & (~mmc1_control[0]);

wire [9:0] mmc1_ppu_bs;
assign mmc1_ppu_bs = chr_8k_banking ? {3'b000, mmc1_ppu_bank0[4:1], ppu_addr[12:10]} :
                     ppu_addr[12] ? {3'b000, mmc1_ppu_bank1[4:0], ppu_addr[11:10]} :
                     {3'b000, mmc1_ppu_bank0[4:0], ppu_addr[11:10]};

task mmc1_init;
    begin
        mmc1_control <= 5'b11101;
        cpu_bs_reg[5:2] <= 4'b1111;
        dbg <= 8'h0e;
    end
endtask

task mmc1_special;
    begin
        if (cpu_data[7]) begin
            mmc1_buffer <= 5'b10000;
        end else if (mmc1_buffer[0]) begin
            case (cpu_addr[14:13])
                2'b00: mmc1_control <= {cpu_data[0], mmc1_buffer[4:1]};
                2'b01: mmc1_ppu_bank0 <= {cpu_data[0], mmc1_buffer[4:1]};
                2'b10: mmc1_ppu_bank1 <= {cpu_data[0], mmc1_buffer[4:1]};
                2'b11: cpu_bs_reg[5:2] <= mmc1_buffer[4:1];
            endcase
            dbg[4:0] <= {cpu_data[0], mmc1_buffer[4:1]};
            dbg[7:6] <= cpu_addr[14:13];
            mmc1_buffer <= 5'b10000;
        end else begin
            mmc1_buffer[4:0] <= {cpu_data[0], mmc1_buffer[4:1]};
        end
    end
endtask

task mmc1_reset;
    begin
        mmc1_buffer <= 5'b10000;
        mmc1_control <= 4'h0;
        mmc1_ppu_bank0 <= 5'h00;
        mmc1_ppu_bank1 <= 5'h00;
    end
endtask
