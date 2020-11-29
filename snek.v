/*
snek.v
snek
Adam Zeloof
11/27/2020
*/

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

  // VGA controller
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  wire snek_loc; // HIGH when hpos and vpos intersect with the snek
  wire food_loc; // HIGH when hpos and vpos intersect with the food
  reg frame_clk; // Slower clock to control snek motion
  reg grow_flag = 0;
  reg [2:0] snek_dir = 0;
  wire [5:0] head_h;
  wire [5:0] head_v;
  
  reg new_food_flag = 1;
  wire [4:0] food_h;
  wire [4:0] food_v;

  reg game_rst = 0;
  wire deadsnek;
  reg millis_clk; // Clock that tocks every ms
  reg gamestate = 0; // 0=splash screen, 1=playing
  reg [31:0] splashctr = 0;
  wire [7:0] snek_len;

  // Generate the snek
  snekgen mysnek (
    .clk(clk),
    .frame_clk(frame_clk),
    .rst(game_rst),
    .hpos(hpos),
    .vpos(vpos),
    .grow_flag(grow_flag),
    .dir(snek_dir),
    .run(gamestate),
    .snek_loc(snek_loc),
    .head_h(head_h),
    .head_v(head_v),
    .body_counter(snek_len),
    .dead(deadsnek)
  );
  
  // Make some food
  foodgen kitchen(
    .clk(clk),
    .rst(game_rst),
    .hpos(hpos),
    .vpos(vpos),
    .new_food_flag(new_food_flag),
    .food_h(food_h),
    .food_v(food_v),
    .food_loc(food_loc)
  );
  
  // Create the frame_clk
  // Fun bug- there's no lower limit on cycles here
  clk_divider frame_clk_div (
    .clk(clk),
    .rst(0),
    .cycles(24'd3125000 - 200000*snek_len), // speed up as the game goes on
    .clk_div(frame_clk)
  );

  // Create the millis_clk
  clk_divider millis_clk_div (
    .clk(clk),
    .rst(0),
    .cycles(24'd12500),
    .clk_div(millis_clk)
  );

  // RGB signals for splash screen
  // HIGH when hpos and vpos intersect with a pixel of the color
  wire splash_r;
  wire splash_g;
  wire splash_b;

  // --- Create the splashscreen (with stream RGB) ---
  // Bit address alias.
  `define active 0:0
  `define VS     1:1
  `define HS     2:2
  `define YC     12:3
  `define XC     22:13
  `define R      23:23
  `define G      24:24
  `define B      25:25

  // Zip RGB stream.
  wire [25:0] strRGB_i, strRGB_o;
  assign strRGB_i = {3'b100, hpos, vpos, hsync, vsync, display_on};

  splash_str splashscreen (
    .px_clk(clk),
    .strRGB_i(strRGB_i),
    .strRGB_o(strRGB_o)
  );

  // Unzip stream RGB.
  assign splash_r = strRGB_o[`R];
  assign splash_g = strRGB_o[`G];
  assign splash_b = strRGB_o[`B];

  // --- End of splash screen with stream RGB ---

  wire fc;
  assign fc = frame_clk;
  
  // I think we're running at 640x480
  // Let's use a grid 32x24 (x20 factor)
  
  // Connect all of the graphics wires
  wire r = display_on & ((splash_r & ~gamestate) | (gamestate & ~(snek_loc)));
  wire g = display_on & ((splash_g & ~gamestate) | (gamestate & ~(food_loc & ~deadsnek)));
  wire b = display_on & ((splash_b & ~gamestate) | (gamestate & ~(snek_loc ^ (food_loc & ~deadsnek))));
  
  assign rgb = {r, g, b};

  always @(posedge millis_clk) begin
    if (~gamestate) begin
      splashctr <= splashctr + 1;
      if (splashctr > 10000) begin
        gamestate <= 1;
      end
    end
  end

  // Check for button press events
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
    if (new_food_flag) begin
      new_food_flag <= 0;
    end
    if (grow_flag) begin
      grow_flag <= 0;
    end
    if ((head_h == {0,food_h}) & (head_v == {0,food_v})) begin
      new_food_flag <= 1;
      grow_flag <= 1;
    end
    if (game_rst) begin
      game_rst <= 0;
    end
    if (deadsnek) begin
      game_rst <= 1;
    end
    if (food_v > 23) begin
      new_food_flag <= 1;
    end
  end
  
endmodule