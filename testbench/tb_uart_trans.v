`timescale 1ns/1ps

module tb_uart_trans;

  // Parameters
  parameter DATA_SIZE  = 8;
  parameter SIZE_FIFO  = 16;
  parameter SYS_FREQ   = 50000000;
  parameter BAUD_RATE  = 115200;//921600;
  parameter SAMPLE     = 16;
  parameter BAUD_DVSR  = SYS_FREQ / (SAMPLE * BAUD_RATE);

  // DUT ports
  reg clk;
  reg trans;
  reg reset_n;
  reg [DATA_SIZE-1:0] bus_data_in;
  wire tx;
  wire [2:0] TX_status_register;
  wire wait_request;
  wire s_tick;
  wire waiting_nibble;


  // Instantiate DUT
  uart_trans #(
    .DATA_SIZE (DATA_SIZE),
    .SIZE_FIFO (SIZE_FIFO),
    .SYS_FREQ  (SYS_FREQ),
    .BAUD_RATE (BAUD_RATE),
    .SAMPLE    (SAMPLE),
    .BAUD_DVSR (BAUD_DVSR)
  ) dut (
	 .trans 					(trans),
    .clk                (clk),
    .reset_n            (reset_n),
    .bus_data_in        (bus_data_in),
    .tx                 (tx),
    .TX_status_register (TX_status_register),
	 .wait_request(wait_request),
	 .s_tick(s_tick),
	 .waiting_nibble(waiting_nibble)
  );

  // Clock generation
  always #10 clk = ~clk; // 50MHz clock

  initial begin
    // Initialize
	 trans=0;
    clk = 0;
    reset_n = 1;
    bus_data_in = 0;

    // Reset
    #100;
   

    // Gửi dữ liệu chỉ trong 1 chu kỳ clock
    @(posedge clk);
	 reset_n = 0; 
    @(posedge clk);
	
	 reset_n = 1;
    @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 trans=1;
	 bus_data_in = 8'hFF;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hF0;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'h1E;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hE1;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hAB;
repeat (2*BAUD_DVSR) @(posedge clk);
//	 bus_data_in = 8'hBA;
//repeat (2*BAUD_DVSR) @(posedge clk);
//	 bus_data_in = 8'h55;
//repeat (2*BAUD_DVSR) @(posedge clk);
//	 bus_data_in = 8'h77;
//repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 0;
	 trans=0;
#400000
		trans = 1;
		bus_data_in = 8'hFA;
#640
		trans = 0;
    // Đợi để quan sát quá trình truyền
#400000
			trans = 1;
		bus_data_in = 8'hFA;
repeat (2*BAUD_DVSR) @(posedge clk);
		trans = 0;
#400000
    $finish;
  end

endmodule
