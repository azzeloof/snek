// https://learn.digilentinc.com/Documents/262
module clk_divider (
    input clk,
    input rst,
    input [31:0] cycles, // cycles = f_clock/(2*f_desired)
    output reg clk_div
  );

  reg [31:0] count;

  always @ (posedge(clk), posedge(rst))
  begin
      if (rst)
          count <= 32'b0;
      else if (count > cycles - 2)
          count <= 32'b0;
      else
          count <= count + 1;
  end

  always @ (posedge(clk), posedge(rst))
  begin
      if (rst)
          clk_div <= 1'b0;
      else if (count > cycles - 2)
          clk_div <= ~clk_div;
      else
          clk_div <= clk_div;
  end

endmodule
