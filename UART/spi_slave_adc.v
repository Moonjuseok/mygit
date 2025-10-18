module spi_slave_adc (
    n_rst,

	data,

    sclk,
    cs_n,
    sdata
);

input 		n_rst;
input [7:0] data;

input 		sclk;
input 		cs_n;
output		sdata;


reg [4:0] cnt;
reg [1:0] addr_i;
reg [2:0] data_i;
reg		  cmd_i;

always @(negedge sclk or negedge n_rst) 
	if(!n_rst) begin
		cnt <= 5'h0;
	end
	else begin
		if (cs_n == 1'b0) 
			cnt <= cnt + 5'h1;
	end

reg [7:0] dout;
wire      dout_en;

always @(negedge sclk or negedge n_rst)
	if(!n_rst) begin
		dout  <= 8'h00;
	end
	else begin
		dout  <= (cnt == 5'h3)? data : {dout[6:0],1'b0};
	end

assign dout_en = ((cs_n==1'b0) && (cnt <= 4'hf))? 1'b1 : 1'b0;
assign sdata   = (dout_en == 1'b1)? dout[7] : 1'bz;

endmodule
