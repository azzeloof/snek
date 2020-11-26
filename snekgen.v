
module snekgen(
  input frame_clk,
  input [9:0] hpos,
  input [9:0] vpos,
  input grow_flag,
  input [2:0] dir,
  output snek_loc,
  output [9:0] head_h,
  output [9:0] head_v
);
  
  genvar j;
  
  reg [11:0] i;

  reg [2:0] body_h [9:0];
  reg [2:0] body_v [9:0];
  reg [7:0] body_counter = 1;
  
  initial begin
    body_h[0] = 16;
    body_v[0] = 12;
    for (i=1; i<3; i++) begin
      body_h[i] = 99;
      body_v[i] = 99;
    end
  end
 
  wire [9:0] head_h = 3;
  wire [9:0] head_v = 3;
  
  wire [2:0] snec_locs;
  
  for (j=0; j<3; j=j+1) begin
    assign snec_locs[i] = (hpos > body_h[i]*20) & (hpos < (body_h[i]+1)*20) & (vpos > body_v[i]*20) & (vpos < (body_v[i]+1)*20);
  end

  //assign snec_locs[0] = (hpos > body_h[0]*20) & (hpos < (body_h[0]+1)*20) & (vpos > body_v[0]*20) & (vpos < (body_v[0]+1)*20);
  //assign snec_locs[1] = (hpos > body_h[1]*20) & (hpos < (body_h[1]+1)*20) & (vpos > body_v[1]*20) & (vpos < (body_v[1]+1)*20);
  //assign snec_locs[2] = (hpos > body_h[2]*20) & (hpos < (body_h[2]+1)*20) & (vpos > body_v[2]*20) & (vpos < (body_v[2]+1)*20);
  
  wire snek_loc;
  
  assign snek_loc = |snec_locs;
  
  always @(posedge frame_clk) begin
    if (grow_flag) begin
      body_counter <= body_counter + 1;
      body_h[body_counter] <= body_h[body_counter-1];
      body_v[body_counter] <= body_v[body_counter-1];
    end
    if (dir == 0) begin
      body_h[0] <= body_h[0] - 1;
    end else if (dir == 1) begin
      body_h[0] <= body_h[0] + 1;
    end else if (dir == 2) begin
      body_v[0] <= body_v[0] + 1;
    end else if (dir == 3) begin
      body_v[0] <= body_v[0] - 1;
    end
    for (i=1; i<3; i++) begin
      if (body_h[i] < 99) begin
        body_h[i] <= body_h[i-1];
        body_v[i] <= body_v[i-1];
      end
    end
  end
  
endmodule