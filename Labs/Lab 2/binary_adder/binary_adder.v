module binary_adder(
	KEY,
	LEDR,
	SW
);

input[1:0] KEY;
input[9:0] SW;
output[8:0] LEDR;

adder adder_inst(SW[7:0], KEY[1], KEY[0], SW[9], LEDR);

endmodule

