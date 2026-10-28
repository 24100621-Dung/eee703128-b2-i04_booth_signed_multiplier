`timescale 1ns/1ps

module tb_i04_booth_signed_multiplier;

    logic        clk;
    logic        rst_n;
    logic        start;
    logic [7:0]  multiplicand;
    logic [7:0]  multiplier;
    logic [15:0] product;
    logic        done;

    // Instantiate DUT
    i04_booth_signed_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    // Clock generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        multiplicand = 0;
        multiplier = 0;

        #20 rst_n = 1;

        // Testcase 1: 7 * 6 = 42
        #10;
        multiplicand = 8'd7;
        multiplier   = 8'd6;
        start = 1;
        #10 start = 0;
        wait(done);
        $display("TC1: 7 * 6 = %d (Expected: 42)", $signed(product));

        // Testcase 2: -7 * 6 = -42
        #20;
        multiplicand = -8'sd7;
        multiplier   = 8'sd6;
        start = 1;
        #10 start = 0;
        wait(done);
        $display("TC2: -7 * 6 = %d (Expected: -42)", $signed(product));

        // Testcase 3: -12 * -12 = 144
        #20;
        multiplicand = -8'sd12;
        multiplier   = -8'sd12;
        start = 1;
        #10 start = 0;
        wait(done);
        $display("TC3: -12 * -12 = %d (Expected: 144)", $signed(product));

        #50;
        $finish;
    end

endmodule