// EcoMender Bot : Task 2A - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Baudrate: 115200 

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
*/

// module declaration
module uart_tx(
    input clk_3125,
    input tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
//
//initial begin
//    tx = 1; tx_done = 0;
//end
    // Parameters for baud rate
    parameter BAUD_COUNT = 27;   // Baud rate count for 230400 baud on 3.125 MHz clock
	 wire parity_type = 1'b0;
    // State encoding
    parameter IDLE = 0, START = 1, DATA = 2, PARITY = 3, STOP = 4, DONE = 5;
    reg [2:0] state = IDLE;

    reg [3:0] bit_count;     // Bit position counter (0-10: start + 8 data + parity + stop)
    reg [7:0] shift_reg;     // Shift register for data
    reg parity_bit;          // Calculated parity bit
    reg [4:0] baud_counter;  // Counter for baud rate timing

    // Parity calculation
    always @(*) begin
        parity_bit = ^data ^ parity_type; // XOR for even (0) or odd (1) parity
    end
	 
	 initial begin
		 tx = 1'b1;
       tx_done = 1'b0;
       baud_counter = 0;
	 end

    // Main state machine
    always @(posedge clk_3125) begin
        case (state)
            IDLE: begin              // Idle line is high
//                tx_done <= 1'b0;
//              baud_counter <= 0;
                if (tx_start) begin
						  tx <= 1'b0;
                    shift_reg <= data;
                    bit_count <= 0;
                    state <= START;
                end
            end

            START: begin
                tx <= 1'b0;              // Start bit
                if (baud_counter == BAUD_COUNT - 1) begin
                    baud_counter <= 1;
                    state <= DATA;
                end else
                    baud_counter <= baud_counter + 1;
            end

            DATA: begin
                tx <= shift_reg[0];      // Transmit MSB first
                if (baud_counter == BAUD_COUNT - 1) begin
                    shift_reg <= shift_reg >> 1; // Shift left
                    baud_counter <= 0;
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) // After 8 data bits, go to parity
                        state <= PARITY;
                end else
                    baud_counter <= baud_counter + 1;
            end

            PARITY: begin
                tx <= parity_bit;
                if (baud_counter == BAUD_COUNT - 1) begin
                    baud_counter <= 0;
                    state <= STOP;
                end else
                    baud_counter <= baud_counter + 1;
            end

            STOP: begin
                tx <= 1'b1;              // Stop bit
                if (baud_counter == BAUD_COUNT - 1) begin
                    baud_counter <= 0;
                    state <= DONE;
						  tx_done <= 1'b1;
                end else
                    baud_counter <= baud_counter + 1;
            end

            DONE: begin
                tx_done <= 1'b0;
                state <= IDLE;
            end
        endcase
    end


//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule