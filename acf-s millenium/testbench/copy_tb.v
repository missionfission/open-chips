module copy_engine_tb;
    reg clk, rst, start;
    reg [31:0] src_addr, dst_addr;
    reg [15:0] length;
    wire done;

    // Instantiate the copy engine
    copy_engine dut (
        .clk(clk), .rst(rst), .start(start),
        .src_addr(src_addr), .dst_addr(dst_addr),
        .length(length), .done(done),
        ...
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0;
        #10 rst = 0;

        // Start copy operation
        src_addr = 32'h0000_1000;
        dst_addr = 32'h0000_2000;
        length = 16'h0004;  // Copy 4 words
        start = 1;
        #10 start = 0;

        // Wait for completion
        wait (done);
        $display("Copy operation completed successfully.");
        $finish;
    end
endmodule
