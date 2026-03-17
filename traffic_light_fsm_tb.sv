`timescale 1ns/1ps
module traffic_light_fsm_tb;
    logic clk;
    logic reset;
    logic TAORB;
    logic GA, YA, RA;
    logic GB, YB, RB;
    traffic_light_fsm dut (
        .clk   (clk),
        .reset (reset),
        .TAORB (TAORB),
        .GA    (GA),
        .YA    (YA),
        .RA    (RA),
        .GB    (GB),
        .YB    (YB),
        .RB    (RB)
    );
    // Clock generation: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    // Stimulus
    initial begin
        reset = 1'b1;
        TAORB = 1'b1;
        #20;
        reset = 1'b0;
        #40;
        TAORB = 1'b0;
        #100;
        #40;
        TAORB = 1'b1;
        #100;
        #40;
        $finish;
    end

    initial begin
        $display("time\tclk\treset\tTAORB\tGA YA RA\tGB YB RB\tstate\ttimer");
        $monitor("%0t\t%b\t%b\t%b\t%b  %b  %b\t%b  %b  %b\t%0d\t%0d",
                 $time, clk, reset, TAORB, GA, YA, RA, GB, YB, RB, dut.state, dut.timer);
    end

endmodule