module mac_stage (
    input clk,
    input rst,
    input signed [15:0] x,
    input signed [15:0] h,
    input signed [47:0] acc_in,
    output reg signed [47:0] acc_out
);

wire signed [31:0] mult;

assign mult = x * h;

always @(posedge clk) begin
    if (rst)
        acc_out <= 0;
    else
        acc_out <= acc_in + mult;
end

endmodule

module fir_transposed #(parameter N = 100)(
    input clk,
    input rst,
    input signed [15:0] x,
    output signed [47:0] y
);


reg signed [15:0] h [0:N-1];

initial
    $readmemh("fir_coeff_q214.txt", h);


wire signed [47:0] acc [0:N];

assign acc[N] = 0;

genvar i;

generate
    for(i = 0; i < N; i = i + 1) begin : MAC_CHAIN

        mac_stage stage (
            .clk(clk),
            .rst(rst),
            .x(x),                 
            .h(h[i]),
            .acc_in(acc[i+1]),
            .acc_out(acc[i])
        );

    end
endgenerate


assign y = acc[0];

endmodule