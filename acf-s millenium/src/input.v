module input_interface (
    input clk,                       // Clock signal
    input rst,                       // Reset signal
    input [7:0] data_in,             // 8-bit data input (byte-by-byte)
    input valid_in,                  // Input data valid signal
    output reg [52:0] cell_out,      // Output 53-byte ATM cell
    output reg cell_valid            // Cell valid signal
);
    reg [52:0] buffer;               // Buffer to store incoming cell
    reg [5:0] byte_count;            // Counter to track 53 bytes

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer <= 0;
            byte_count <= 0;
            cell_valid <= 0;
        end else if (valid_in) begin
            buffer <= {buffer[44:0], data_in}; // Shift in new byte
            byte_count <= byte_count + 1;

            if (byte_count == 52) begin
                cell_out <= buffer;
                cell_valid <= 1;
                byte_count <= 0;
            end else begin
                cell_valid <= 0;
            end
        end
    end
endmodule
