`timescale 1ns/1ns

module tb_uart_re();
  parameter DATA_SIZE = 8;
  parameter SIZE_FIFO = 16;
  parameter SYS_FREQ  = 50000000;
  parameter BAUD_RATE = 115200;
  parameter SAMPLE    = 16;
  //parameter BAUD_DVSR = SYS_FREQ / (SAMPLE * BAUD_RATE);
parameter BAUD_DVSR = (SYS_FREQ * 2 + SAMPLE * BAUD_RATE) / (2 * SAMPLE * BAUD_RATE);
  reg clk;
  reg reset_n;
  reg rx;
  wire [7:0] out_rx;
  wire [7:0] real_output;
  wire [2:0] RX_status_register;
 wire [7:0] rx_data_out;
 wire  [3:0]           sub_low_de1;
wire  [3:0]           sub_high_de1;
wire [7:0] mstate;
wire  double_error;
wire   error_corrected;
wire h_ok;
wire l_ok;
reg read_en;
wire [9:0] dout;
wire join_ok;
wire s_tick;
wire wait_request;
wire wait_req;
wire read_latch;
  uart_re #(
    .DATA_SIZE(DATA_SIZE),
    .SIZE_FIFO(SIZE_FIFO),
    .SYS_FREQ(SYS_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .SAMPLE(SAMPLE),
    .BAUD_DVSR(BAUD_DVSR)
  ) uut (
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx),
    .out_rx(out_rx),
	 .real_output(real_output),
    .RX_status_register(RX_status_register),
	 .rx_data_out (rx_data_out),
	 .sub_low_de1(sub_low_de1),
		.sub_high_de1(sub_high_de1),
		.mstate (mstate),
		.double_error(double_error),
		.dout(dout),
		.read_en(read_en),
 .error_corrected(error_corrected),
 .h_ok(h_ok),
 .l_ok(l_ok),
 .join_ok(join_ok),
 .s_tick(s_tick),
 .wait_request(wait_request),
 .wait_req(wait_req),
 .read_latch(read_latch)
 //.wait_req_wire(wait_req_wire)
  );

  always #10 clk = ~clk; // 50MHz clock

  initial begin
    $display("SYS_FREQ = %d", SYS_FREQ);
    $display("BAUD_RATE = %d", BAUD_RATE);
    $display("BAUD_DVSR = %d", BAUD_DVSR);
    
    clk = 0;
    reset_n = 1;
    rx = 1; // idle line
	 read_en = 0;

    // Reset
    #(BAUD_DVSR * 2 * 10);
    reset_n = 0;
    #(BAUD_DVSR * 2 * 10);
    reset_n = 1;

    // Truyền ký tự 0xCD = 0001 1101 (giả định đã được mã hóa Hamming 8,4 thành 2 byte, doc tru phai qua trai)


   // send_uart_byte(8'b10 0 0 011 1); // giả định đây là codeword thấp

    // === Send byte 2 ===
    //send_uart_byte(8'b01100110); // giả định đây là codeword cao

      repeat (BAUD_DVSR) @(posedge clk);
	// 1 error
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit 01 1 0 011 0
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

  repeat (16*BAUD_DVSR) @(negedge clk);
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit   01100110
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
	 
 repeat (16*BAUD_DVSR) @(posedge clk);
 
 
	 
	 //0111 1101 
	 
	 //00 0 1 111 0
	 //10 1 0 101 0
	
	 
	

	// 1 error
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit //00 0 1 111 0
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;//
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

  repeat (16*5*BAUD_DVSR) @(negedge clk);
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit   //10 1 0 101 0
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;//
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
	 	
		
	// 2 error
	repeat (16*BAUD_DVSR) @(posedge clk);
	rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit 
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

  repeat (16*BAUD_DVSR) @(negedge clk);
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit   
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

	 
	 
	 
	 #499880;
	 read_en = 1;
	 #20
	 //read_en = 0;
	 
	#220
	//read_en = 1;
	 #20
	 read_en = 0;
	#300
	read_en = 1;
	#100
	read_en = 0;

	 #10000;
    $finish;
  end



endmodule
