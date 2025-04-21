module zxevo1010_psg(
    input clk,

    inout [7:0] zxd,
    input [7:0] zxal,
    input [15:13] zxah,
    input zxm1_n,
    input zxmreq_n,
    input zxrd_n,
    input zxres_n,
    input zxwr_n,

    output midi_clk,
    output reg midi_data,
    output midi_rst_n,
    input midi_sense,

    output ymcs0_n,
    output ymcs1_n,
    output ymrd_n,
    output ymwr_n,
    output ymrst_n,
    output ymck,
    output [1:0] yma,
    inout [7:0] ymd,

    output reg sd_r_1bit,
    output reg sd_l_1bit
);


wire rst_n = zxres_n;

// n_iorq are useless in zxevo :(
// so we're detecting n_iorq cycle by n_rd/n_wr signal asserted without n_m1/n_mreq
reg ioreq;
always @(negedge clk) begin
    ioreq <= (zxrd_n == 1'b0 || zxwr_n == 1'b0) && zxm1_n == 1'b1 && zxmreq_n == 1'b1;
end
wire ioreq_rd = ioreq && zxrd_n == 1'b0;
wire ioreq_wr = ioreq && zxwr_n == 1'b0;


// n_dos are useless in zxevo :(
// so we're just lock some ports access when instruction has been fetched from rom
reg rom_m1_access;
always @(negedge clk) begin
    if (!rst_n)
        rom_m1_access <= 0;
    else if (zxm1_n == 0)
        rom_m1_access <= zxah[15:14] == 2'b00;
end



/* CLOCKS */
reg [4:0] clk7_cnt = 0;
always @(posedge clk) clk7_cnt <= clk7_cnt + 5'd7;
wire clk7 = clk7_cnt[4];

reg [2:0] clk12_cnt  = 0;
always @(posedge clk) clk12_cnt <= clk12_cnt  + 3'd3;
wire clk12  = clk12_cnt[2];



/* TURBO SOUND FM */
wire port_bffd = zxah[15:14] == 2'b10 && zxal[3:0] == 4'b1101;
wire port_fffd = zxah[15:14] == 2'b11 && zxal[3:0] == 4'b1101;
reg ym_chip_sel, ym_get_stat;
assign yma[0] = (~zxrd_n & zxah[14] & ~ym_get_stat) | (~zxwr_n & ~zxah[14]);
assign yma[1] = 1'b0; // TODO: possible to get extra FM channels there
assign ymcs0_n = ~(~ym_chip_sel && (port_bffd || port_fffd));
assign ymcs1_n = ~( ym_chip_sel && (port_bffd || port_fffd));

always @(posedge clk) begin
    if (!rst_n) begin
        ym_chip_sel <= 0;
        ym_get_stat <= 0;
    end
    else if (port_fffd && ioreq_wr && zxd[7:4] == 4'b1111) begin
        ym_chip_sel <= zxd[0];
        ym_get_stat <= ~zxd[1];
    end
end

assign ymrd_n = ~ioreq_rd;
assign ymwr_n = ~ioreq_wr;
assign ymrst_n = zxres_n;
assign ymck = clk7;
assign ymd = ~ymwr_n? zxd : 8'bzzzzzzzz;



/* MIDI */
reg midi_ext;
assign midi_rst_n = zxres_n & ~midi_ext;
assign midi_clk = clk12;
reg midi_reg_en;

always @(posedge clk) begin
    if (!rst_n) begin
        midi_data <= 1'b1;
        midi_reg_en <= 1'b0;
        midi_ext <= 1'b0;
    end
    else if (port_fffd && ioreq_wr) begin
        midi_reg_en <= zxd == 8'hE;
    end
    else if (port_bffd && ioreq_wr && midi_reg_en) begin
        if (!midi_data)
            midi_ext <= midi_sense;
        midi_data <= zxd[2];
    end
end



/* SOUNDRIVE */
reg [7:0] sd_ch0, sd_ch1, sd_ch2, sd_ch3;
always @(posedge clk) begin
    if (!rst_n) begin
        sd_ch0 <= 0;
        sd_ch1 <= 0;
        sd_ch2 <= 0;
        sd_ch3 <= 0;
    end
    else if (ioreq_wr && !rom_m1_access) begin
        case (zxal)
        8'h0F: sd_ch0 <= zxd;
        8'h1F: sd_ch1 <= zxd;
        8'h4F: sd_ch2 <= zxd;
        8'h5F: sd_ch3 <= zxd;
        endcase
    end
end

reg [8:0] sd_l, sd_r, sd_cnt;
always @(posedge clk) begin
    sd_l <= sd_ch0 + sd_ch1;
    sd_r <= sd_ch2 + sd_ch3;
    sd_cnt <= sd_cnt + 8'hff;
    sd_l_1bit <= sd_cnt < sd_l;
    sd_r_1bit <= sd_cnt < sd_r;
end



/* BUS CONTROLLER */
assign zxd = ioreq_rd && port_fffd? ymd : 8'bzzzzzzzz;


endmodule
