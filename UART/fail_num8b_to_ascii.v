module num8b_to_ascii (
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

//reg enable;
reg [1:0] state;

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        enable <= 1'h0;
    end
    else begin
        enable <= (start == 1'b1)? 2'h1 :
                   ((rx_done == 1'b1) && (cnt_num != 2'h0))? cnt_num + 2'h1 : cnt_num;
    end

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        state <= S_IDLE;
    end
    else begin
        case (state) 
            S_IDLE : state <= (start == 1'b1)?   S_FRST : state;
            S_FRST : state <= (rx_done == 1'b1)? S_SCND : state;
            S_SCND : state <= (rx_done == 1'b1)? S_THRD : state;
            S_THRD : state <= (rx_done == 1'b1)? S_IDLE : state;

        endcase
    end

// din : 0 ~ 255
wire [8:0] sub_200; // d200 = hC8, 2s(d200) = b1_0011_1000
wire [8:0] sub_100; // d100 = h64, 2s(d100) = b1_1001_1100
wire [4:0] sub_10;  // d10  = ha,  2s(d10)  = b1_0110
wire [6:0] num_10_1; // 0~99 < 128 (7-bit)
wire [3:0] num_1;
reg  [3:0] digit_100;
reg  [3:0] digit_10;
reg  [3:0] digit_1;

assign sub_200 = {1'b0,din} + 9'b1_0011_1000;
assign sub_100 = {1'b0,din} + 9'b1_1001_1100;
assign num_10_1 = (sub_200[8] == 1'b0)? sub_200[6:0] :
                    (sub_100[8] == 1'b0)? sub_100[6:0] : din[6:0];
assign sub_10 = {1'b0,num_10_1[3:0]} + 5'b1_0110;
assign num_100 = (din >= 8'd200)?

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
        digit_100 <= 8'h00;
    end
    else begin
        if (start == 1'b1) begin
            digit_100 <= (sub_200[8] == 1'b0)? 4'h2 :
                         (sub_100[8] == 1'b0)? 4'h1 : 4'h0;
            digit_10  <= (sub_10[4] == 1'b0)? {num_10_1[6:4],4'h0} + {sub_10 :
        end
    end

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
    end
    else begin
    end

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
    end
    else begin
    end

always @(posedge clk or negedge n_rst)
    if(!n_rst) begin
    end
    else begin
    end

endmodule