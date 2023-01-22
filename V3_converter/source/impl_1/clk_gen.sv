// use this module to generate all the clocks needed
module clk_gen  (
   input  logic   clk_period,
   output logic   clk_o
);

   initial
   begin
      clk_o  = 1'b1;
      #(clk_period);
      forever clk_o = #(clk_period/2) ~clk_o; // clk toggles for hald period
   end

endmodule