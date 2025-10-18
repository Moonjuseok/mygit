module top(
	clk,
	n_rst,

	n_start,

	sclk,
	cs_n,
	sdata,

	baudrate,
	//uart_txd,
	uart_txd_n,
	uart_rxd_n,

	check_rxd,

	led,
	fnd_1,
	fnd_2
);

`ifdef SIM
parameter T_DIV_BIT    = 4;   //  2-bit
parameter T_DIV_0      = 4'd15; // 0-15 : 16 // 50 MHz clock -> 9,600 rate
parameter T_DIV_HALF_0 = 4'd7;  // 0- 7 : 8
parameter T_DIV_1      = 4'd7;  // 0- 7 : 8  // 50 MHz clock -> 9,600 rate
parameter T_DIV_HALF_1 = 4'd3;  // 0- 3 : 4
`else
// 50 MHz clock -> (1/(d5208)) -> 9,600 rate
parameter T_DIV_BIT    = 13;   // 5207 : 13-bit
parameter T_DIV_0      = 13'd5207; // 0-5207 : 5208  // 50 MHz clock ->  9,600 rate
parameter T_DIV_HALF_0 = 13'd2603; // 5208/2 = 2604  // 50 MHz clock ->  9,600 rate
parameter T_DIV_1      = 13'd5207; // 0-2603 : 2604  // 50 MHz clock -> 19,200 rate
parameter T_DIV_HALF_1 = 13'd1301; // 2604/2 = 1302  // 50 MHz clock -> 19,200 rate
`endif

input clk;
input n_rst;
input n_start;

output sclk;
output cs_n;
input sdata;

input baudrate;
//output uart_txd;
output uart_txd_n;
input uart_rxd_n;
input check_rxd;

output [8:0] led;
output [6:0] fnd_1;
output [6:0] fnd_2;

wire [7:0] spi_data;
wire new_data;
assign led = {new_data,spi_data};

wire spi_done;
spi_master_adc u_spi_master_adc(
   .clk(clk),
   .n_rst(n_rst),

   .n_start(n_start),
   .done(spi_done),

   .led(spi_data),
   .fnd_1(),
   .fnd_2(),

   .sclk(sclk),
   .cs_n(cs_n),
   .sdata(sdata)
);

wire [7:0] uart_tx_din;
wire uart_tx_start;
wire uart_tx_done;

byte2ascii u_byte2ascii(
	.clk(clk),
	.n_rst(n_rst),

	.start(spi_done),
	.din(spi_data),

    .dout(uart_tx_din),
    .dout_vld(uart_tx_start),
    .rx_done(uart_tx_done)
);



wire uart_txd;
assign uart_txd_n = ~uart_txd;

uart_tx #(
	.T_DIV_BIT(T_DIV_BIT),
	.T_DIV_0(T_DIV_0), 
	.T_DIV_HALF_0(T_DIV_HALF_0), 
	.T_DIV_1(T_DIV_1),
	.T_DIV_HALF_1(T_DIV_HALF_1) 
) 
	u_uart_tx (
	.clk(clk), 	
	.n_rst(n_rst), 		

	.baudrate(baudrate),   // 0 : 9600, 1 : 19200...
	//.start(spi_done), 		
	//.din(spi_data), 		//
	.start(uart_tx_start), 		
	.din(uart_tx_din), 		//
	.done(uart_tx_done),
	.uart_txd(uart_txd) 		// UART TX DATA
);

//wire [6:0] seg_lsb, seg_msb;
wire [7:0] rx_data;

uart_rx #(
	.T_DIV_BIT(T_DIV_BIT),
	.T_DIV_0(T_DIV_0), 
	.T_DIV_HALF_0(T_DIV_HALF_0), 
	.T_DIV_1(T_DIV_1),
	.T_DIV_HALF_1(T_DIV_HALF_1) 
) u_uart_rx(
	.clk(clk), 	
	.n_rst(n_rst), 		// active low push button

 	.baudrate(baudrate), // 0 : 9600, 1 : 19200...
	
	.check(~check_rxd),		// active low push button
	.new_data(new_data),	// LED

	.uart_rxd(~uart_rxd_n),		// UART RX DATA

	.rx_data(rx_data)
	//.led(led),
	//.seg_lsb(seg_lsb),
	//.seg_msb(seg_msb)
);

fnd u_fnd_lsb(
	.din(rx_data[3:0]),
	.dout(fnd_1)
);
fnd u_fnd_msb(
	.din(rx_data[7:4]),
	.dout(fnd_2)
);

endmodule