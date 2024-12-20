module fft_processor (
    input wire clk,
    input wire rst,
    input wire [31:0] data_in,
    input wire data_valid,
    input wire [2:0] numerology,  // 5G NR numerology (0-4)
    input wire mode,              // 0 for FFT, 1 for IFFT
    output reg [31:0] fft_out,
    output reg fft_valid
);

    // FFT size based on numerology
    reg [31:0] fft_size;
    
    always @(*) begin
        case(numerology)
            3'b000: fft_size = 256;  // 15 kHz spacing
            3'b001: fft_size = 512;  // 30 kHz spacing
            3'b010: fft_size = 1024; // 60 kHz spacing
            3'b011: fft_size = 2048; // 120 kHz spacing
            3'b100: fft_size = 4096; // 240 kHz spacing
            default: fft_size = 256;
        endcase
    end

    // Twiddle factors ROM
    reg [31:0] twiddle_factors [4095:0];
    reg [31:0] stage_buffer [4095:0];
    reg [11:0] addr_counter;
    reg [2:0] stage_counter;
    
    // FFT States
    parameter LOAD = 3'b000;
    parameter BUTTERFLY = 3'b001;
    parameter REORDER = 3'b010;
    parameter COMPLETE = 3'b011;
    reg [2:0] fft_state;

    // Initialize twiddle factors
    initial begin
        $readmemh("twiddle_factors.hex", twiddle_factors);
    end

    // Butterfly computation unit
    function [63:0] butterfly;
        input [31:0] a, b;
        input [31:0] twiddle;
        reg [31:0] temp;
        begin
            temp = complex_multiply(b, twiddle);
            butterfly = {(a + temp), (a - temp)};
        end
    endfunction

    // Complex multiplication
    function [31:0] complex_multiply;
        input [31:0] a, b;
        reg [15:0] ar, ai, br, bi;
        reg [15:0] pr, pi;
        begin
            {ar, ai} = a;
            {br, bi} = b;
            pr = ar * br - ai * bi;
            pi = ar * bi + ai * br;
            complex_multiply = {pr, pi};
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fft_valid <= 0;
            fft_out <= 0;
            fft_state <= LOAD;
            stage_counter <= 0;
        end else begin
            case (fft_state)
                LOAD: begin
                    if (data_valid) begin
                        stage_buffer[addr_counter] <= data_in;
                        if (addr_counter == fft_size - 1) begin
                            fft_state <= BUTTERFLY;
                            addr_counter <= 0;
                        end else
                            addr_counter <= addr_counter + 1;
                    end
                end
                
                BUTTERFLY: begin
                    // Implement butterfly operations for current stage
                    // ...FFT computation logic...
                    if (stage_counter == $clog2(fft_size)) begin
                        fft_state <= COMPLETE;
                    end else
                        stage_counter <= stage_counter + 1;
                end

                COMPLETE: begin
                    fft_valid <= 1;
                    fft_out <= stage_buffer[addr_counter];
                    if (addr_counter == fft_size - 1)
                        fft_state <= LOAD;
                    else
                        addr_counter <= addr_counter + 1;
                end
            endcase
        end
    end

endmodule