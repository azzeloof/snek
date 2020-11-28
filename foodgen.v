/*
foodgen.v
snek
Adam Zeloof
11/27/2020
*/

module foodgen(
  input clk,
  input frame_clk,
  input rst,
  input [9:0] hpos, 
  input [9:0] vpos,
  input new_food_flag,
  output [4:0] food_h,
  output [4:0] food_v,
  output food_loc
);
  
  wire food_loc;
  reg [4:0] food_h;
  reg [4:0] food_v;

  assign food_loc = (hpos > food_h*20) & (hpos < (food_h+1)*20) & (vpos > food_v*20) & (vpos < (food_v+1)*20);
  
  //Pseudo-random number generators
  //https://electronics.stackexchange.com/questions/30521/random-bit-sequence-using-verilog
  reg [4:0] rng0 = 1;
  reg [4:0] rng1 = 3;
  // Keep the numbers changing every clock cycle
  always @(posedge clk) begin
    rng0 <= { rng0[3:0], rng0[4] ^ rng0[2] };
    rng1 <= { rng1[3:0], rng1[4] ^ rng1[2] };
  end
  
  // Move the food to a new location when needed
  always @(posedge frame_clk) begin
    if (new_food_flag) begin
      food_h <= rng0;
      food_v <= rng1;
    end
    if (rst) begin
      food_h <= rng0;
      food_v <= rng1;
    end
  end
  
endmodule