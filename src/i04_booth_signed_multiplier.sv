module i04_booth_signed_multiplier (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [7:0]  multiplicand, // A (8-bit signed)
    input  logic [7:0]  multiplier,   // B (8-bit signed)
    output logic [15:0] product,      // Output 16-bit product
    output logic        done
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        WORK  = 2'b01,
        FINISH= 2'b10
    } state_t;

    state_t state;
    logic [7:0]  M;        // Multiplicand register
    logic [16:0] A_Q_Q1;   // {A[7:0], Q[7:0], Q_-1}
    logic [3:0]  count;     // Counter for 8 iterations

    wire [1:0] booth_bits = A_Q_Q1[1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            product  <= 16'd0;
            done     <= 1'b0;
            A_Q_Q1   <= 17'd0;
            M        <= 8'd0;
            count    <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        M      <= multiplicand;
                        A_Q_Q1 <= {8'd0, multiplier, 1'b0};
                        count  <= 4'd0;
                        state  <= WORK;
                    end
                end

                WORK: begin
                    if (count < 4'd8) begin
                        logic [8:0] sum;
                        case (booth_bits)
                            2'b01:   sum = {A_Q_Q1[16], A_Q_Q1[16:9]} + {M[7], M};
                            2'b10:   sum = {A_Q_Q1[16], A_Q_Q1[16:9]} - {M[7], M};
                            default: sum = {A_Q_Q1[16], A_Q_Q1[16:9]};
                        endcase
                        
                        // Arithmetic Shift Right (ASR)
                        A_Q_Q1 <= $signed({sum, A_Q_Q1[8:1]});
                        count  <= count + 1'b1;
                    end else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    product <= A_Q_Q1[16:1];
                    done    <= 1'b1;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule