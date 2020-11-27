module snek(
  input clk,
  input rst,
  input [3:0] buttons,
  output hsync,
  output vsync,
  output [2:0] rgb,
  output fc
);

  wire hsync;
  wire vsync;
  wire [2:0] rgb;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  wire snek_loc;
  wire food_loc;
  reg frame_clk;
  reg grow_flag = 0;
  reg [2:0] snek_dir = 0;
  wire [4:0] head_h;
  wire [4:0] head_v;
  
  reg new_food_flag = 1;
  wire [4:0] food_h;
  wire [4:0] food_v;

  reg newgame;
  reg millis_clk;
  reg gamestate = 0; // 0=splash screen, 1=playing
  reg [15:0] splashctr = 0;

  snekgen mysnek (
    .frame_clk(frame_clk),
    .hpos(hpos),
    .vpos(vpos),
    .grow_flag(grow_flag),
    .dir(snek_dir),
    .run(gamestate),
    .snek_loc(snek_loc),
    .head_h(head_h),
    .head_v(head_v)
  );
  
  foodgen kitchen(
    .clk(clk),
    .frame_clk(frame_clk),
    .rst(rst),
    .hpos(hpos),
    .vpos(vpos),
    .new_food_flag(new_food_flag),
    .food_h(food_h),
    .food_v(food_v),
    .food_loc(food_loc)
  );
  
  clk_divider frame_clk_div (
    .clk(clk),
    .rst(0),
    .cycles(24'd6250000),
    .clk_div(frame_clk)
  );

  clk_divider millis_clk_div (
    .clk(clk),
    .rst(0),
    .cycles(24'd9000),
    .clk_div(millis_clk)
  );

  wire splash_r;
  wire splash_g;
  wire splash_b;

  splash splashscreen (
    .clk(frame_clk),
    .rst(0),
    .hpos(hpos),
    .vpos(vpos),
    .r(splash_r),
    .g(splash_g),
    .b(splash_b),
  );

  wire fc;
  assign fc =  frame_clk;
  
  // I think we're running at 640x480
  // Let's use a grid 32x24 (x20 factor)
  
  wire r = display_on & ((splash_r & ~gamestate) | (gamestate & ~(snek_loc)));
  wire g = display_on & ((splash_g & ~gamestate) | (gamestate & ~(food_loc)));
  wire b = display_on & ((splash_b & ~gamestate) | (gamestate & ~(snek_loc ^ food_loc)));
  
  assign rgb = {r, g, b};

  always @(posedge millis_clk) begin
    if (~gamestate) begin
      splashctr <= splashctr + 1;
      if (splashctr > 10000) begin
        gamestate <= 1;
      end
    end
  end
  
  always @(posedge clk) begin
    if (buttons[1]) begin // left
      snek_dir <= 0;
    end else if (buttons[0]) begin //right
      snek_dir <= 1;
    end else if (buttons[2]) begin //up
      snek_dir <= 2;
    end else if (buttons[3]) begin //down
      snek_dir <= 3;
    end
  end
  
  always @(posedge frame_clk) begin
    if (new_food_flag) begin
      new_food_flag <= 0;
    end
    if (grow_flag) begin
      grow_flag <= 0;
    end
    if ((head_h == food_h) & (head_v == food_v)) begin
      new_food_flag <= 1;
      grow_flag <= 1;
    end
  end
  
endmodule