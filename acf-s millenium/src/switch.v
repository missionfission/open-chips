module crossbar_switch (
    input clk,
    input [52:0] cell_in [3:0],    // 53-byte cells from 4 input ports
    input [1:0] out_port [3:0],    // Output port decisions from header parser
    input valid_in [3:0],          // Valid signals for each input
    output reg [52:0] cell_out [3:0], // 53-byte cells to 4 output ports
    output reg valid_out [3:0]     // Valid signals for output ports
);
    integer i;
    always @(posedge clk) begin
        // Clear outputs
        for (i = 0; i < 4; i = i + 1) begin
            valid_out[i] <= 0;
            cell_out[i] <= 0;
        end

        // Route cells to the correct output port
        for (i = 0; i < 4; i = i + 1) begin
            if (valid_in[i]) begin
                cell_out[out_port[i]] <= cell_in[i];
                valid_out[out_port[i]] <= 1;
            end
        end
    end
endmodule
