`timescale 1ns/1ps

module tb_uart_top;

  // Parameters
  parameter DATA_SIZE  = 8;
  parameter SIZE_FIFO  = 16;
  parameter SYS_FREQ   = 50000000;
  parameter BAUD_RATE  = 115200;
  parameter SAMPLE     = 16;
  parameter BAUD_DVSR  = SYS_FREQ / (SAMPLE * BAUD_RATE);

  // DUT ports
  reg clk;
  reg trans;
  reg reset_n;
  reg [DATA_SIZE-1:0] bus_data_in;
  wire rx;
  wire tx;
  wire [2:0] TX_status_register;
  wire       baud_en;
	wire loop_back;
  wire [9:0] real_output;
  wire [2:0] RX_status_register;
  //wire [7:0] rx_data_out;
  //wire [3:0] sub_low_de1;
  //wire [3:0] sub_high_de1;
  //wire [7:0] mstate;
  reg 		 read_en;
  wire wait_request_read;
    wire wait_request_write;
	 wire s_tick;
  // Instantiate DUT
  uart_top dut (
    .clk(clk),
    .reset_n(reset_n),
    //.loop_back(loop_back),
	 .rx(loop_back),
	 .tx(loop_back),
    // TX interface
    .trans(trans),
    .bus_data_in(bus_data_in),
    .TX_status_register(TX_status_register),
    .baud_en(baud_en),

    // RX interface
	 .read_en(read_en),
    .RX_status_register(RX_status_register),
	 .wait_request_read(wait_request_read),
	 .wait_request_write(wait_request_write),
	 .s_tick(s_tick)
  );
	 



  // Clock generation
  always #10 clk = ~clk; // 50MHz clock

  initial begin
	 trans=0;
    clk = 0;
    reset_n = 1;
    bus_data_in = 0;
	 read_en = 0;

    // Reset
    #100;
   

    // Gửi dữ liệu chỉ trong 1 chu kỳ clock
    @(posedge clk);
	 reset_n = 0;

    @(posedge clk);
	 trans=1;
	 reset_n = 1;
	 bus_data_in = 8'hFF;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'h55;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hAB;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hCD;
repeat (2*BAUD_DVSR) @(posedge clk);
	 bus_data_in = 8'hEA;
repeat (2*BAUD_DVSR) @(posedge clk);
    @(posedge clk);
	 trans=0;
    // Đợi để quan sát quá trình truyền
    #1200000;
	 read_en = 1;
    #500;
	 read_en =0;
	$finish;
  end

endmodule
