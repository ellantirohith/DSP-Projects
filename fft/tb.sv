`timescale 1ns/1ps

module fft8_tb;

    localparam W = 8;

    logic clk, rst;
    logic signed [W-1:0] in_re, in_im;
    logic signed [W-1:0] out_re, out_im;
    logic valid;

    logic signed [W-1:0] out_re_buf [0:7];
    logic signed [W-1:0] out_im_buf [0:7];

    int bitrev [0:7] = '{0,4,2,6,1,5,3,7};

    fft8_top #(W) dut (
        .clk(clk),
        .rst(rst),
        .in_re(in_re),
        .in_im(in_im),
        .out_re(out_re),
        .out_im(out_im),
        .valid(valid)
    );

    always #5 clk = ~clk;

    integer fin, fout, status;

    initial begin
        clk = 0;
        rst = 1;
        in_re = 0;
        in_im = 0;

        fin  = $fopen("fft_input.txt", "r");
        fout = $fopen("fft_output.txt", "w");

        repeat (3) @(posedge clk);
        rst = 0;

        for (int i = 0; i < 8; i++) begin
            status = $fscanf(fin, "%d %d\n", in_re, in_im);
            @(posedge clk);
        end

        in_re = 0;
        in_im = 0;

        $fclose(fin);
    end

    initial begin
        int count = 0;

        wait(valid);

        while (count < 8) begin
            @(posedge clk);
            out_re_buf[count] = out_re;
            out_im_buf[count] = out_im;
            count++;
        end

        for (int i = 0; i < 8; i++) begin
            $fdisplay(fout, "%0d %0d",
                out_re_buf[bitrev[i]],
                out_im_buf[bitrev[i]]
            );
        end

        $fclose(fout);

        $finish;
    end

endmodule