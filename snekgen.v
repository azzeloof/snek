
module snekgen(
  input frame_clk,
  input [9:0] hpos,
  input [9:0] vpos,
  input grow_flag,
  input [2:0] dir,
  input run,
  output snek_loc,
  output [4:0] head_h,
  output [4:0] head_v
);
  
  parameter maxlen = 16;//768;

  genvar j;
  
  reg [11:0] i;

  reg [4:0] body_h [maxlen-1:0];
  reg [4:0] body_v [maxlen-1:0];
  reg [7:0] body_counter = 1;
  
  initial begin
    body_h[0] = 15;
    body_v[0] = 11;
    for (i=1; i<maxlen; i++) begin
      body_h[i] = 31;
      body_v[i] = 31;
    end
  end
 
  wire [4:0] head_h;
  wire [4:0] head_v;

  assign head_h = body_h[0];
  assign head_v = body_v[0];
  
  wire [maxlen-1:0] snec_locs;
  
  generate
  for (j=0; j<maxlen; j=j+1) begin
    assign snec_locs[j] = (hpos > body_h[j]*20) & (hpos < (body_h[j]+1)*20) & (vpos > body_v[j]*20) & (vpos < (body_v[j]+1)*20);
  end
  endgenerate
  
  wire snek_loc;

  assign snek_loc = |snec_locs;
 
  always @(posedge frame_clk) begin
    if (run) begin
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
      for (i=1; i<maxlen; i++) begin
        // unused body segments are kept at 31,31
        if (body_v[i] < 30) begin // if the segment is on-screen
          body_h[i] <= body_h[i-1];
          body_v[i] <= body_v[i-1];
        end
      end
    end
  end
  
endmodule