`timescale 1ns/1ps

// ===================== BUTTERFLY =====================
module butterfly #(
    parameter W = 8
)(
    input  logic signed [W-1:0] a_re, a_im,
    input  logic signed [W-1:0] b_re, b_im,
    input  logic [1:0] tw_sel,
    output logic signed [W:0] sum_re, sum_im,
    output logic signed [W:0] diff_re, diff_im
);

    localparam signed [W-1:0] C707 = 90;

    logic signed [W:0] d_re, d_im;
    logic signed [2*W:0] m_re, m_im;

    assign sum_re = a_re + b_re;
    assign sum_im = a_im + b_im;

    assign d_re = a_re - b_re;
    assign d_im = a_im - b_im;

    always_comb begin
        diff_re = 0;
        diff_im = 0;
        m_re = 0;
        m_im = 0;

        case (tw_sel)
            2'b00: begin
                diff_re = d_re;
                diff_im = d_im;
            end
            2'b01: begin
                m_re = (d_re + d_im) * C707;
                m_im = (d_im - d_re) * C707;
                diff_re = m_re >>> (W-1);
                diff_im = m_im >>> (W-1);
            end
            2'b10: begin
                diff_re = d_im;
                diff_im = -d_re;
            end
            2'b11: begin
                m_re = (d_im - d_re) * C707;
                m_im = -(d_re + d_im) * C707;
                diff_re = m_re >>> (W-1);
                diff_im = m_im >>> (W-1);
            end
        endcase
    end

endmodule


module sdf_stage #(
    parameter W = 8,
    parameter D = 4
)(
    input  logic clk,
    input  logic rst,
    input  logic bypass,
    input  logic [1:0] tw_sel,
    input  logic signed [W-1:0] in_re, in_im,
    output logic signed [W-1:0] out_re, out_im
);

    logic signed [W-1:0] shift_re [0:D-1];
    logic signed [W-1:0] shift_im [0:D-1];

    logic signed [W:0] sum_re, sum_im;
    logic signed [W:0] diff_re, diff_im;

    butterfly #(W) bf (
        .a_re(shift_re[D-1]),
        .a_im(shift_im[D-1]),
        .b_re(in_re),
        .b_im(in_im),
        .tw_sel(tw_sel),
        .sum_re(sum_re),
        .sum_im(sum_im),
        .diff_re(diff_re),
        .diff_im(diff_im)
    );

    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i=0;i<D;i++) begin
                shift_re[i] <= 0;
                shift_im[i] <= 0;
            end
        end else begin
            for (i=D-1;i>0;i--) begin
                shift_re[i] <= shift_re[i-1];
                shift_im[i] <= shift_im[i-1];
            end

            shift_re[0] <= bypass ? in_re : diff_re[W-1:0];
            shift_im[0] <= bypass ? in_im : diff_im[W-1:0];
        end
    end

    assign out_re = bypass ? shift_re[D-1] : sum_re[W-1:0];
    assign out_im = bypass ? shift_im[D-1] : sum_im[W-1:0];

endmodule


module fft_ctrl (
    input  logic clk,
    input  logic rst,
    output logic [1:0] tw1, tw2,
    output logic b1, b2, b3,
    output logic valid
);

    typedef enum logic [3:0] {
        S0, S1, S2, S3, S4, S5, S6, S7
    } state_t;

    state_t state, next;

    always_ff @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= next;
    end

    always_comb begin
        next = state;

        case (state)
            S0: next = S1;
            S1: next = S2;
            S2: next = S3;
            S3: next = S4;
            S4: next = S5;
            S5: next = S6;
            S6: next = S7;
            S7: next = S0;
        endcase
    end

    always_comb begin
        tw1 = 0; tw2 = 0;
        b1 = 1; b2 = 1; b3 = 1;
        valid = 0;

        case (state)
            S0: begin b1=1; b2=1; b3=1; tw1=0; end
            S1: begin b1=1; b2=1; b3=0; tw1=1; end
            S2: begin b1=1; b2=0; b3=1; tw1=2; end
            S3: begin b1=1; b2=0; b3=0; tw1=3; end
            S4: begin b1=0; b2=1; b3=1; tw1=0; end
            S5: begin b1=0; b2=1; b3=0; tw1=1; end
            S6: begin b1=0; b2=0; b3=1; tw1=2; end
            S7: begin 
                b1=0; b2=0; b3=0; 
                tw1=3; 
                valid=1;
            end
        endcase

        tw2 = {state[0],1'b0};
    end

endmodule


module fft8_top #(
    parameter W = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [W-1:0] in_re, in_im,
    output logic signed [W-1:0] out_re, out_im,
    output logic valid
);

    logic [1:0] tw1, tw2;
    logic b1, b2, b3;

    logic signed [W-1:0] s1_re, s1_im;
    logic signed [W-1:0] s2_re, s2_im;
    logic signed [W-1:0] s3_re, s3_im;

    fft_ctrl ctrl (
        .clk(clk),
        .rst(rst),
        .tw1(tw1),
        .tw2(tw2),
        .b1(b1), .b2(b2), .b3(b3),
        .valid(valid)
    );

    sdf_stage #(W,4) st1 (
        .clk(clk), .rst(rst),
        .bypass(b1),
        .tw_sel(tw1),
        .in_re(in_re), .in_im(in_im),
        .out_re(s1_re), .out_im(s1_im)
    );

    sdf_stage #(W,2) st2 (
        .clk(clk), .rst(rst),
        .bypass(b2),
        .tw_sel(tw2),
        .in_re(s1_re), .in_im(s1_im),
        .out_re(s2_re), .out_im(s2_im)
    );

    sdf_stage #(W,1) st3 (
        .clk(clk), .rst(rst),
        .bypass(b3),
        .tw_sel(2'b00),
        .in_re(s2_re), .in_im(s2_im),
        .out_re(out_re), .out_im(out_im)
    );

endmodule
