module bcd_adder(
	KEY, SW, LEDR,
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

input[1:0] KEY;
input[9:0] SW;
output[9:0] LEDR;
output[7:0] HEX0;
output[7:0] HEX1;
output[7:0] HEX2;
output[7:0] HEX3;
output[7:0] HEX4;
output[7:0] HEX5;

adder adder_inst(
	SW[7:4], SW[3:0], KEY[1], KEY[0], SW[9], LEDR[9],
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

endmodule
