module copy_engine (
    input wire clk,
    input wire rst,
    input wire start,               // Start signal for transfer
    input wire [31:0] src_addr,     // Source address
    input wire [31:0] dst_addr,     // Destination address
    input wire [15:0] length,       // Transfer length in words
    output reg done,                // Transfer completion signal

    // Memory interfaces
    output reg [31:0] mem_read_addr,
    input wire [31:0] mem_read_data,
    output reg mem_read_en,

    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    output reg mem_write_en
);

    // Internal Registers
    reg [31:0] src_ptr, dst_ptr;
    reg [15:0] count;

    // State machine states
    typedef enum reg [1:0] {IDLE, READ, WRITE, DONE} state_t;
    state_t state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            mem_read_en <= 0;
            mem_write_en <= 0;
        end else begin
            case (state)
                // Idle: Wait for start signal
                IDLE: begin
                    if (start) begin
                        src_ptr <= src_addr;
                        dst_ptr <= dst_addr;
                        count <= length;
                        state <= READ;
                    end
                end

                // Read: Fetch data from the source address
                READ: begin
                    mem_read_addr <= src_ptr;
                    mem_read_en <= 1;
                    state <= WRITE;
                end

                // Write: Write data to the destination address
                WRITE: begin
                    mem_write_addr <= dst_ptr;
                    mem_write_data <= mem_read_data;  // Copy data
                    mem_write_en <= 1;

                    // Update pointers and counters
                    src_ptr <= src_ptr + 4;
                    dst_ptr <= dst_ptr + 4;
                    count <= count - 1;

                    // Check if the transfer is complete
                    if (count == 1) begin
                        state <= DONE;
                    end else begin
                        state <= READ;
                    end
                end

                // Done: Signal completion
                DONE: begin
                    done <= 1;
                    mem_read_en <= 0;
                    mem_write_en <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
