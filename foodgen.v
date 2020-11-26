
module foodgen(
  input clk,
  input frame_clk,
  input [9:0] hpos, 
  input [9:0] vpos,
  input new_food_flag,
  output [4:0] food_h,
  output [4:0] food_v,
  output food_loc
);
  
  reg [7:0] counter;
  wire food_loc;
  
  assign food_loc = (hpos > food_h*20) & (hpos < ({5'b0,food_h}+1)*20) & (vpos > food_v*20) & (vpos < ({5'b0,food_v}+1)*20);
  
  always @(posedge clk) begin
    counter <= counter + 1;
  end
  
  always @(posedge frame_clk) begin
    if (new_food_flag) begin
      food_h <= counter[4:0];
      food_v <= counter[5:1] - 7 * (counter[5:1] > 24);
    end
  end
  
endmodule