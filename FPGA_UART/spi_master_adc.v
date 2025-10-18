module spi_master_adc(

   clk,
   n_rst,

   n_start,
   done,

   led,
   fnd_1,
   fnd_2,

   sclk,
   cs_n,
   sdata
);
parameter SCLK_HALF = 4'hC;
 
input clk;
input n_rst;

input n_start;
output done;

output sclk;
reg sclk;
output cs_n;
reg cs_n;
input  sdata;

output [7:0] led;
output [6:0] fnd_1;
output [6:0] fnd_2;

// ----------------------------------------
//
reg [7:0] r_sdata;
reg [4:0] cnt_sclk;
reg [3:0] cnt;

wire start;
reg start_d1;
assign start = ~n_start;

always @(posedge clk or negedge n_rst )
	if(!n_rst)
	   start_d1 <= 1'b0;
	else
	   start_d1 <= start;

wire r_start = ((start==1'b1)&&(start_d1==1'b0))?1'b1:1'b0; // active high/low change // sunny

always@ (posedge clk or negedge n_rst)
	if(!n_rst) begin
	   cs_n <= 1'b1;
	end
	else begin
		if(r_start==1'b1)
			cs_n <= 1'b0;
		else if(cnt_sclk == 5'h10)
			cs_n <= 1'b1;
		else
			cs_n <= cs_n;
	end

// clk : 5 MHz
// sclk : 2 MHz at SCLK_HALF = 12
always@(posedge clk or negedge n_rst)
	if(!n_rst) begin
	   cnt <= 4'h0;
	end
	else begin
		if(cs_n==1'b0) begin
			if(cnt == SCLK_HALF)
				cnt <= 4'h0;
			else 
				cnt <= cnt + 4'h1;
		end
		else
			 cnt <= 4'h0;
    end

//reg sclk_
always@(posedge clk or negedge n_rst)
	if(!n_rst)
	   sclk <= 1'b0;
	else begin
		if (cs_n == 1'b0) begin
			if(cnt == SCLK_HALF)
				sclk <= ~sclk;
		end
		else begin
			sclk <= 1'b1;
		end
	end

/////////////////////////////////////////////////////

wire sclk_rise = ((cnt == SCLK_HALF)&&(sclk == 1'b0))? 1'b1 : 1'b0;


always@ (posedge clk or negedge n_rst)
	if(!n_rst) begin
	   cnt_sclk <= 5'h00;
	end
	else begin
		if (cs_n == 1'b0) begin
	   		if(sclk_rise == 1'b1) 
		  		cnt_sclk <= cnt_sclk + 5'h01;
		end 
		else begin
		  cnt_sclk <= 5'h00;
		end
	end

//////////////////////////////////////////////////////////

always@(posedge clk or negedge n_rst)
	if(!n_rst) begin
	   r_sdata <= 8'h00;
	end
	else begin
		if (cs_n == 1'b0) begin
	   		if((sclk_rise == 1'b1) && (cnt_sclk <= 5'ha))
				r_sdata<= {r_sdata[6:0], sdata};
		end
	end

assign led = r_sdata;
assign done = (cnt_sclk == 5'hb)? 1'b1 : 1'b0;

fnd u_fnd_1(
   .din(r_sdata[3:0]),
   .dout(fnd_1)
);

fnd u_fnd_2(
   .din(r_sdata[7:4]),
   .dout(fnd_2)
);

endmodule

////////////////////////////////////////////////////////////
