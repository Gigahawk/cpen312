module sevenseg (KEY, HEX0);
input[1:0] KEY;
output[6:0] HEX0;
wire a, b, c, d, e, f, g;
wire n1_out, n3_out, n5_out, n6_out, n8_out;

nand n1 (n1_out, KEY[0], KEY[1]);
assign e = n1_out;
nand n2 (b, n1_out, n1_out);
nand n3 (n3_out, n5_out, KEY[1]);
nand n4 (a, n3_out, n3_out);
assign d = a;
nand n5 (n5_out, KEY[0], KEY[0]);
nand n6 (n6_out, n5_out, n8_out);
nand n7 (f, n6_out, n6_out);
nand n8 (n8_out, KEY[1], KEY[1]);

assign c = 0;
assign g = 0;

assign HEX0[0] = a;
assign HEX0[1] = b;
assign HEX0[2] = c;
assign HEX0[3] = d;
assign HEX0[4] = e;
assign HEX0[5] = f;
assign HEX0[6] = g;

endmodule

