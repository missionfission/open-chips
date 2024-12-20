module digital_front_end (
    input wire clk,
    input wire rst,
    input wire [15:0] adc_data_i,
    input wire [15:0] adc_data_q,
    input wire adc_valid,
    input wire [3:0] filter_config,  // Added filter configuration
    input wire dc_offset_en,         // Enable DC offset correction
    output reg [31:0] dfe_out,
    output reg dfe_valid
);

    // Digital filter parameters
    reg [31:0] fir_coeffs [15:0];
    reg [31:0] buffer_i [15:0];
    reg [31:0] buffer_q [15:0];

    // DC offset correction
    reg [15:0] dc_offset_i, dc_offset_q;
    reg [31:0] acc_i, acc_q;
    reg [7:0] avg_count;

    // Initialize FIR coefficients
    initial begin
        fir_coeffs[0] = 32'h0001_0000; // Unity gain
        fir_coeffs[1] = 32'h0000_F012;
        // ...more coefficients...
    end

    // FIR filter implementation
    reg [31:0] filtered_i, filtered_q;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dfe_valid <= 0;
            dfe_out <= 0;
            dc_offset_i <= 0;
            dc_offset_q <= 0;
            avg_count <= 0;
        end else if (adc_valid) begin
            // Shift buffer and apply new sample
            for (i = 15; i > 0; i = i - 1) begin
                buffer_i[i] <= buffer_i[i-1];
                buffer_q[i] <= buffer_q[i-1];
            end
            buffer_i[0] <= adc_data_i;
            buffer_q[0] <= adc_data_q;

            // FIR filter computation
            filtered_i = 0;
            filtered_q = 0;
            for (i = 0; i < 16; i = i + 1) begin
                filtered_i = filtered_i + (buffer_i[i] * fir_coeffs[i]);
                filtered_q = filtered_q + (buffer_q[i] * fir_coeffs[i]);
            end

            // DC offset correction
            if (dc_offset_en) begin
                filtered_i = filtered_i - dc_offset_i;
                filtered_q = filtered_q - dc_offset_q;
                
                // Update DC offset estimation
                if (avg_count < 8'hFF) begin
                    acc_i = acc_i + filtered_i;
                    acc_q = acc_q + filtered_q;
                    avg_count = avg_count + 1;
                end else begin
                    dc_offset_i <= acc_i >> 8;
                    dc_offset_q <= acc_q >> 8;
                    acc_i <= 0;
                    acc_q <= 0;
                    avg_count <= 0;
                end
            end

            dfe_valid <= 1;
            dfe_out <= {filtered_i[31:16], filtered_q[31:16]};
        end
    end

endmodule