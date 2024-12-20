module output_interface (
    input clk,
    input rst,
    input [52:0] cell_in,
    input valid_in,
    output reg [7:0] data_out,      // Byte-by-byte output
    output reg valid_out
);
    reg [52:0] buffer;
    reg [5:0] byte_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_count <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            buffer <= cell_in;
            byte_count <= 0;
            valid_out <= 1;
        end else if (valid_out) begin
            data_out <= buffer[52 - (byte_count * 8) -: 8];
            byte_count <= byte_count + 1;
            if (byte_count == 52) valid_out <= 0;
        end
    end
endmodule
