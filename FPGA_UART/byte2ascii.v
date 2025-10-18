module byte2ascii (
    clk,
    n_rst,

    start,
    din,

    dout,
    dout_vld,
    rx_done
);

parameter S_IDLE = 2'h0;
parameter S_FRST = 2'h1;
parameter S_SCND = 2'h2;
parameter S_THRD = 2'h3;

input clk;
input n_rst;

input start;
input [7:0] din;

output [7:0] dout;
output dout_vld;

input rx_done;

reg start_d1;
wire start_en;
always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        start_d1 <= 1'h0;
    end
    else begin
        start_d1 <= start;
    end
assign start_en = ((start == 1'b1) && (start_d1 == 1'b0))? 1'b1 : 1'b0;

reg [1:0] state;
always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        state <= S_IDLE;
    end
    else begin
        case (state) 
            S_IDLE : state <= (start_en == 1'b1)? S_FRST : state;
            S_FRST : state <= (rx_done  == 1'b1)? S_SCND : state;
            S_SCND : state <= (rx_done  == 1'b1)? S_THRD : state;
            S_THRD : state <= (rx_done  == 1'b1)? S_IDLE : state;
            default : state <= S_IDLE;
        endcase
    end
    
reg  [7:0] data;
wire [3:0] data_sel;
wire [4:0] sub_9;

reg       load;
always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        load <= 1'b0;
        data <= 8'h00;
    end
    else begin
        load <= (start_en == 1'b1 || ((state == S_FRST || state == S_SCND)&&(rx_done == 1'b1)))? 1'b1 : 1'b0;
        data <= (start_en == 1'b1)? din : data;
    end


assign data_sel = (state == S_FRST)? data[7:4] : data[3:0];
assign sub_9 = {1'b0,data_sel} + 5'b1_0111;  // -9
// sub_9[4] == 0 : >= 9 : 9, a~f
// sub_9[4] == 1 : < 9 : 0~8
assign dout = (state == S_THRD)? 8'h20 : // space
              ((sub_9[4] == 1'b1)||(sub_9 == 5'h00))? {4'h3,data_sel} : 
              {4'h6,sub_9[3:0]};
assign dout_vld = load;

endmodule