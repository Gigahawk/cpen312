module sevenseg_myhdl(KEY, HEX0);
input[1:0] KEY;
output[6:0] HEX0;

sevenseg sevenseg_inst(KEY, HEX0);

endmodule