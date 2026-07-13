module fpga_fft_top (
    input  logic btn_clk,  // Push button for manual clocking (PIN_AA15)
    input  logic rst,      // Reset button (PIN_AA14)
    output logic [6:0] hex3, 
    output logic [6:0] hex2, 
    output logic [6:0] hex1, 
    output logic [6:0] hex0  
);

    // Fix for active-low buttons on Altera boards
    logic reset_active;
    assign reset_active = ~rst; 

    // ==========================================
    // 1. ADDRESS COUNTER
    // ==========================================
    logic [2:0] addr;
    
    // Triggering on negedge so it advances right when you press the button down
    always_ff @(negedge btn_clk or posedge reset_active) begin
        if (reset_active) 
            addr <= 3'd0;
        else     
            addr <= addr + 3'd1;
    end

    // ==========================================
    // 2. ROM (READING FROM FILE)
    // ==========================================
    logic [15:0] fft_rom [0:7];

    initial begin
        $readmemh("fft_data.txt", fft_rom);
    end

    logic signed [7:0] in_re, in_im;
    assign in_re = fft_rom[addr][15:8]; 
    assign in_im = fft_rom[addr][7:0];  

    // ==========================================
    // 3. THE FFT MODULE
    // ==========================================
    logic signed [7:0] out_re, out_im;
    logic valid;

    fft8_top #(8) my_fft (
        .clk(btn_clk),
        .rst(reset_active),
        .in_re(in_re),
        .in_im(in_im),
        .out_re(out_re),
        .out_im(out_im),
        .valid(valid)
    );

    // ==========================================
    // 4. 7-SEGMENT DISPLAYS
    // ==========================================
    hex_decoder hd3 (.in(out_re[7:4]), .out(hex3));
    hex_decoder hd2 (.in(out_re[3:0]), .out(hex2));
    
    hex_decoder hd1 (.in(out_im[7:4]), .out(hex1));
    hex_decoder hd0 (.in(out_im[3:0]), .out(hex0));

endmodule