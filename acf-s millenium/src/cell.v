module header_parser (
    input clk,
    input rst,
    input [52:0] cell_in,           // Incoming ATM cell
    input cell_valid,               // Cell valid signal
    output reg [1:0] out_port,      // 2-bit output port ID
    output reg valid_out            // Output valid signal
);
    // Example VPI/VCI lookup table (fixed mapping for simplicity)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_port <= 0;
            valid_out <= 0;
        end else if (cell_valid) begin
            case (cell_in[47:32])   // Extract VPI/VCI field from header
                16'h1001: out_port <= 2'b00; // Route to port 0
                16'h1002: out_port <= 2'b01; // Route to port 1
                16'h1003: out_port <= 2'b10; // Route to port 2
                16'h1004: out_port <= 2'b11; // Route to port 3
                default: out_port <= 2'b00;  // Default port
            endcase
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end
endmodule
