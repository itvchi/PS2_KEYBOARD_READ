module PS2_KEYBOARD_READ (
	input i_clk,
	input i_ps2_clk,
	input i_ps2_data,
	output o_tx
);
 wire [7:0] w_data;
 wire [7:0] w_code;
 wire w_data_valid;
 wire w_code_valid;

	ps2_reader reader (i_clk, i_ps2_clk, i_ps2_data, w_data, w_data_valid);
	ps2_interpreter int (i_clk, w_data, w_data_valid, w_code, w_code_valid);
	uart_tx tx (.i_clk(i_clk), .i_data(w_code), .i_send(w_code_valid), .o_tx(o_tx));
	

	
endmodule