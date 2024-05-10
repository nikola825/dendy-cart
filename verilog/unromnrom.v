wire unrom_cpu_enable;
assign unrom_cpu_enable = (~romsel);

wire [7:0] unrom_cpu_bs;
assign unrom_cpu_bs = cpu_addr[14] ? {6'b000111, cpu_addr[13:12]} :
                      {3'b000, cpu_bs_reg[4:2], cpu_addr[13:12]};

wire unrom_cpu_read;
assign unrom_cpu_read = ((~romsel) & cpu_rw);

wire unrom_vert_mirror;
assign unrom_vert_mirror = vert_mirror;

wire [9:0] unrom_ppu_bs;
assign unrom_ppu_bs = {7'b0000000, ppu_addr[12:10]};

task unrom_init;
    begin
        cpu_bs_reg[4:2] <= 3'b111;
        dbg <= 8'h07;
        vert_mirror <= cpu_data[7];
    end
endtask

task unrom_special;
    begin
        cpu_bs_reg[4:2] <= cpu_data[2:0];
        dbg <= cpu_data;
    end
endtask
