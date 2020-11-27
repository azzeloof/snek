module snekgen(
  input frame_clk,
  input rst,
  input [9:0] hpos,
  input [9:0] vpos,
  input grow_flag,
  input [2:0] dir,
  input run,
  output snek_loc,
  output [5:0] head_h,
  output [5:0] head_v,
  output [7:0] body_counter,
  output dead
);
  
  parameter maxlen = 16;//768;

  genvar j;
  
  reg [11:0] i;

  reg [5:0] body_h [maxlen-1:0];
  reg [5:0] body_v [maxlen-1:0];
  reg [7:0] body_counter = 1;
  
  initial begin
    body_h[0] <= 15;
    body_v[0] <= 11;
    for (i=1; i<maxlen; i++) begin
      body_h[i] <= 42;
      body_v[i] <= 42;
    end
  end
 
  wire [5:0] head_h;
  wire [5:0] head_v;

  assign head_h = body_h[0];
  assign head_v = body_v[0];
  
  wire [maxlen-1:0] snec_locs;
  
  generate
  for (j=0; j<maxlen; j=j+1) begin
    assign snec_locs[j] = (hpos > body_h[j]*20) & (hpos < (body_h[j]+1)*20) & (vpos > body_v[j]*20) & (vpos < (body_v[j]+1)*20);
  end
  endgenerate
  
  wire snek_loc;
  assign snek_loc = |snec_locs; // OR all of the locations togethor to be displayed
 
  reg dead;

  always @(posedge frame_clk) begin
    if (run) begin // only move when the game is running (not during splashscreen)
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
        // unused body segments are kept at 42, 42
        if ((body_h[i] != 42) & (body_v[i] != 42)) begin // if the segment is on-screen
          body_h[i] <= body_h[i-1];
          body_v[i] <= body_v[i-1];
        end
      end
    end
    if (rst) begin // lets reset to the original state
      body_h[0] <= 15;
      body_v[0] <= 11;
      for (i=1; i<maxlen; i++) begin
        body_h[i] <= 42;
        body_v[i] <= 42;
        body_counter <= 1;
      end
    end
  end

  always @(negedge frame_clk) begin
    if ((head_h > 31) | (head_v > 23)) begin // departed screen on the right
      dead <= 1;
    end
    for (i=1; i<maxlen; i++) begin 
      if ((head_h == body_h[i]) & (head_v == body_v[i])) begin
        dead <= 1;
      end
    end
    if (rst) begin
      dead <= 0;
    end
  end
  
endmodule