`timescale 1ns/1ps

module tb_uart_top1;

  // Parameters
  parameter DATA_SIZE  = 8;
  parameter SIZE_FIFO  = 16;
  parameter SYS_FREQ   = 50000000;
  parameter BAUD_RATE  = 921600;
  parameter SAMPLE     = 32;
  parameter BAUD_DVSR  = SYS_FREQ / (SAMPLE * BAUD_RATE);

  // DUT ports
  reg clk;
  reg trans;
  reg reset_n;
  reg [DATA_SIZE-1:0] bus_data_in;
  wire rx;                   // Tín hiệu nhận
  wire tx;                   // Tín hiệu truyền
  wire [2:0] TX_status_register;
  wire baud_en;

  wire [7:0] real_output;
  wire [2:0] RX_status_register;
  wire double_error;
  wire error_corrected;

  // Tín hiệu mô phỏng rx (nhận dữ liệu từ tx)
  reg [7:0] rx_data_sim;      // Dữ liệu mô phỏng cho tín hiệu rx
  reg rx_internal;            // Giả lập tín hiệu rx

  // Instantiate DUT (Device Under Test)
  uart_top dut (
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx_internal),      // Kết nối rx với tín hiệu mô phỏng rx_internal
    .tx(tx),
    // TX interface
    .trans(trans),
    .bus_data_in(bus_data_in),
    .TX_status_register(TX_status_register),
    .baud_en(baud_en),

    // RX interface
    .real_output(real_output),
    .RX_status_register(RX_status_register),
    .double_error(double_error),
    .error_corrected(error_corrected)
  );

  // Clock generation
  always #10 clk = ~clk; // 50MHz clock

  // Generate rx_data_sim and simulate rx
  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
      rx_data_sim <= 8'b0;
    end else if (tx) begin
      // Khi tx có dữ liệu, rx_data_sim sẽ được cập nhật để mô phỏng tín hiệu rx
      rx_data_sim <= tx;  // Chuyển dữ liệu từ tx vào rx_data_sim
    end
  end

  // Mô phỏng tín hiệu rx_internal để gửi dữ liệu đến DUT
  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
      rx_internal <= 1'b0;  // Đặt giá trị ban đầu cho rx_internal
    end else begin
      // Mô phỏng việc truyền dữ liệu từ tx sang rx
      rx_internal <= rx_data_sim[0]; // Chuyển bit thấp của rx_data_sim sang rx_internal
      rx_data_sim <= {1'b0, rx_data_sim[7:1]};  // Dịch trái rx_data_sim để mô phỏng nhận dữ liệu
    end
  end

  initial begin
    // Initialize signals
    trans = 0;
    clk = 0;
    reset_n = 1;
    bus_data_in = 0;

    // Reset
    #100;
    reset_n = 0;
    #100;
    reset_n = 1;

    // Gửi dữ liệu chỉ trong 1 chu kỳ clock
    @(posedge clk);
    trans = 1;
    bus_data_in = 8'hFF;
    @(posedge clk);
    bus_data_in = 8'h55;
    @(posedge clk);
    bus_data_in = 8'hAB;
    @(posedge clk);
    bus_data_in = 8'hCD;
    @(posedge clk);
    trans = 0;

    // Đợi để quan sát quá trình truyền
    #10000;

    // Kiểm tra nhận dữ liệu qua rx
    $display("Data received by rx: %h", real_output);

    // Dừng mô phỏng sau khi kiểm tra xong
    $finish;
  end

endmodule
