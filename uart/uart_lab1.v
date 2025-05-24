module uart_lab1(
		input 	CLOCK_50,
		output	[15:0] LEDR,
		input 	[0:0]	KEY
		);
		
		system nios_system(
					.clk_clk										(CLOCK_50),
					.reset_reset_n								(KEY[0]),
					.led_external_connection_export		({16'd0,LEDR})
		);
endmodule