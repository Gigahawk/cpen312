module clock_12h(
	KEY, SW, CLOCK_50, LEDR,
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

input[3:0] KEY;
input[9:0] SW;
input CLOCK_50;
output[6:0] HEX0;
output[6:0] HEX1;
output[6:0] HEX2;
output[6:0] HEX3;
output[6:0] HEX4;
output[6:0] HEX5;

output[17:0] LEDR;

wire clk_half;


clock_divider clock_divider_inst(
    CLOCK_50, clk_half
);

bcd_counter bcd_counter_inst(
    .clk (clk_half),
    .rst (KEY[3]),
    .dout0 (LEDR[3:0]),
    .dout1 (LEDR[8:4]),
    .din0 (SW[3:0]),
    .din1 (SW[8:4]),
    .ld (KEY[0]),
    .carry_out(LEDR[9])
);




clock_counter clock_counter_inst(
    clk_half,
    KEY[3],
    SW[3:0],
    SW[8:4],
    KEY[0],
    KEY[1],
    KEY[2],
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
);

assign LEDR[16] = clk_half;



endmodule
