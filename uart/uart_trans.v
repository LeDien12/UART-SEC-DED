// uart_trans.v - Phiên bản đã tối ưu, loại bỏ RX
module uart_trans #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 16,
            SYS_FREQ        = 50000000,
            BAUD_RATE       = 115200,//921600,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )  (
  input 	  							trans,
  input                       clk               ,  // Clock
  input                       reset_n           ,  // Asynchronous reset active low
  input       [DATA_SIZE-1:0] bus_data_in       ,  // Dữ liệu người dùng nhập vào
  output                      tx                ,  // UART TX
  output      [2:0]           TX_status_register,
  output								wait_request,
  output reg waiting_nibble,
  output								s_tick
);

//--------------------------- Internal signal declaration ---------------------------

wire [DATA_SIZE-1:0] tx_data_in;
wire                 tx_done, tx_full, tx_empty;

reg  [3:0]           sub_highlow;    // nibble cao/thấp
wire  [DATA_SIZE-1:0] sub_bus_data;   // dữ liệu sau Hamming
reg                  highOrLow;      // chọn gửi cao hay thấp
reg                  fifo_tx_wr;     // điều khiển ghi FIFO
wire						tx_start;
wire	[DATA_SIZE-1:0] data_to_be_mod;			



wire [3:0] low_in, high_in;

assign tx_start = !tx_empty;
//--------------------------------- Module wiring -----------------------------------
nibble_splitter splitter (
  .data_in     (bus_data_in),
  .low_nibble  (low_in),
  .high_nibble (high_in)
);

hamming84_encoder en_tx (
  .data_in  (sub_highlow),
  .code_out (sub_bus_data)
);

uart_sampling_tick #(
  .SYS_FREQ  (SYS_FREQ),
  .BAUD_RATE (BAUD_RATE),
  .SAMPLE    (SAMPLE),
  .BAUD_DVSR (BAUD_DVSR)
) uart_sampling_tick_inst (
  .clk      (clk),
  .reset_n  (reset_n),
  .s_tick   (s_tick)
);

uart_tx #(
  .DATA_SIZE (DATA_SIZE)
) uart_tx_inst (
  .clk          (clk),
  .s_tick       (s_tick),
  .reset_n      (reset_n),
  .tx_start     (tx_start),
  .data_in      (tx_data_in),
  .tx           (tx),
  .tx_done_tick (tx_done)
);

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO)
) uart_fifo_tx (
  .clk     (clk),
  .s_tick  (s_tick),
  .reset_n (reset_n),
  .w_data  (sub_bus_data),
  .r_data  (tx_data_in), //moded
  .wr      (fifo_tx_wr),
  .rd      (tx_done),
  .full    (tx_full),
  .empty   (tx_empty)
);

//------------------------- FSM nàp dữ liệu vào FIFO -------------------------

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) 
  begin
    highOrLow   <= 0;
    fifo_tx_wr  <= 0;
    sub_highlow <= 0;
	 waiting_nibble <= 1;
  end 
  else
		begin
			if (waiting_nibble == 0)
				waiting_nibble <= 1;
			if(s_tick) 
				begin
				 fifo_tx_wr <= 0; // reset sau mỗi chu kỳ
				 // Kiểm tra FIFO chưa đầy mới gửi
				 if (!tx_full&&trans) 
					 begin
						if (!highOrLow) 
							begin
							  sub_highlow <= low_in;
							  fifo_tx_wr  <= 1;
							  highOrLow   <= 1; // chuyển sang nibble cao
							end 
						else 
							begin
							  sub_highlow <= high_in;
							  fifo_tx_wr  <= 1;
							  highOrLow   <= 0; // quay lại nibble thấp của byte tiếp theo
							  waiting_nibble <= 0;
							end
						end
					end
		end
end

assign wait_request = (trans && waiting_nibble) || tx_full;
//-------------------------------- Status output ----------------------------------
assign TX_status_register = {tx_done, tx_empty, tx_full};

endmodule
