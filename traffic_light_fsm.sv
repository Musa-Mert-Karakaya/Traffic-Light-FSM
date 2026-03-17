module traffic_light_fsm (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,

    output logic GA, 
    output logic YA, 
    output logic RA, 

    output logic GB, 
    output logic YB, 
    output logic RB  
);
    // 4-state FSM 
    typedef enum logic [1:0] {
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } state_t;

    state_t state, next_state;
    logic [2:0] timer;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 3'd0;
        end
        else begin
            state <= next_state;
            // Timer behavior:
            // - increments only in S1 and S3
            // - resets when leaving those states or when not in them
            if ((state == S1) || (state == S3)) begin
                if (timer < 3'd5)
                    timer <= timer + 3'd1;
                else
                    timer <= timer;   
            end
            else begin
                timer <= 3'd0;
            end
            // If we are leaving a yellow state, reset timer immediately
            if ((state == S1 && next_state != S1) ||
                (state == S3 && next_state != S3)) begin
                timer <= 3'd0;
            end
        end
    end

    always_comb begin
        next_state = state;

        case (state)
            // S0: LA green, LB red
            // stay while TAORB = 1
            // when ~TAORB = 1, go to S1
            S0: begin
                if (TAORB)
                    next_state = S0;
                else
                    next_state = S1;
            end
            // S1: LA yellow, LB red
            // hold for 5 time units while ~TAORB is true and TIMER < 5
            // once TIMER = 5, go to S2
            S1: begin
                if ((!TAORB) && (timer < 3'd5))
                    next_state = S1;
                else if (timer == 3'd5)
                    next_state = S2;
                else
                    next_state = S1;
            end
            // S2: LA red, LB green
            // stay while ~TAORB = 1
            // when TAORB = 1, go to S3
            S2: begin
                if (!TAORB)
                    next_state = S2;
                else
                    next_state = S3;
            end
            // S3: LA red, LB yellow
            // hold for 5 time units while TAORB is true and TIMER < 5
            // once TIMER = 5, go back to S0
            S3: begin
                if ((TAORB) && (timer < 3'd5))
                    next_state = S3;
                else if (timer == 3'd5)
                    next_state = S0;
                else
                    next_state = S3;
            end

            default: begin
                next_state = S0;
            end
        endcase
    end

    always_comb begin
        // Default all outputs off
        GA = 1'b0; YA = 1'b0; RA = 1'b0;
        GB = 1'b0; YB = 1'b0; RB = 1'b0;

        case (state)
            S0: begin
                GA = 1'b1;
                RB = 1'b1;
            end

            S1: begin
                YA = 1'b1;
                RB = 1'b1;
            end

            S2: begin
                RA = 1'b1;
                GB = 1'b1;
            end

            S3: begin
                RA = 1'b1;
                YB = 1'b1;
            end

            default: begin
                GA = 1'b0; YA = 1'b0; RA = 1'b0;
                GB = 1'b0; YB = 1'b0; RB = 1'b0;
            end
        endcase
    end

endmodule