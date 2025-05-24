module uart_lab(
		input 	CLOCK_50,
		input		[0:0] GPIO_0,
		output	[0:0] GPIO_1,
		output	[15:0] LEDR,
		input 	[0:0]	KEY
		);
		
		system nios_system(
					.clk_clk										(CLOCK_50),
					.reset_reset_n								(KEY[0]),
					.uart_0_conduit_end_rx					(GPIO_0[0]),
					.uart_0_conduit_end_tx					(GPIO_1[0]),
					.led_external_connection_export		({16'd0,LEDR})
		);
endmodule