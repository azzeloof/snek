module top(
    input CLK,      // 16 MHz Clock
    input PIN_7,    // rst
    input PIN_2,    // up
    input PIN_6,    // down
    input PIN_3,    // left
    input PIN_24,   // right
    output LED,     // User/boot LED next to pwr
    output PIN_11,  // hsync
    output PIN_12,  // vsync
    output PIN_21,  // red
    output PIN_20,  // green
    output PIN_19,  // blue
    output PIN_1,   // debug
    output USBPU    // USB pull-up resistor
);

// drive USB pul-up to 0 to disable USB
assign USBPU = 0;
wire rst;
assign rst = PIN_7;
wire clk_25MHz; // VGA clock

SB_PLL40_CORE usb_pll_inst (
  .REFERENCECLK(CLK),
  .PLLOUTCORE(clk_25MHz),
  .RESETB(1),
  .BYPASS(0)
);

// Fin=16, Fout=10;
defparam usb_pll_inst.DIVR = 0;
defparam usb_pll_inst.DIVF = 24;
defparam usb_pll_inst.DIVQ = 4;
defparam usb_pll_inst.FILTER_RANGE = 3'b001;
defparam usb_pll_inst.FEEDBACK_PATH = "SIMPLE";
defparam usb_pll_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam usb_pll_inst.FDA_FEEDBACK = 4'b0000;
defparam usb_pll_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam usb_pll_inst.FDA_RELATIVE = 4'b0000;
defparam usb_pll_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam usb_pll_inst.PLLOUT_SELECT = "GENCLK";
defparam usb_pll_inst.ENABLE_ICEGATE = 1'b0;

reg red;
reg green;
reg blue;
reg hsync;
reg vsync;

assign PIN_21 = red;
assign PIN_20 = green;
assign PIN_19 = blue;
assign PIN_11 = hsync;
assign PIN_12 = vsync;

wire debug;
wire frame_clk;
assign PIN_1 = frame_clk;
assign LED = frame_clk;

/*wire btns [3:0];
SB_IO #(
  .PIN_TYPE(6'b 0000_01),
  .PULLUP(1'b 1)
) button_input(
  .PACKAGE_PIN({PIN_12, PIN_6, PIN_3, PIN_24}),
  .D_IN_0(btns)
);*/

wire btn0_state, btn0_dn, btn0_up;
debounce d_btn0 (
  .clk(CLK),
  .i_btn(PIN_2),
  .o_state(btn0_state),
  .o_ondn(btn0_dn),
  .o_onup(btn0_up)
);

wire btn1_state, btn1_dn, btn1_up;
debounce d_btn1 (
  .clk(CLK),
  .i_btn(PIN_6),
  .o_state(btn1_state),
  .o_ondn(btn1_dn),
  .o_onup(btn1_up)
);

wire btn2_state, btn2_dn, btn2_up;
debounce d_btn2 (
  .clk(CLK),
  .i_btn(PIN_3),
  .o_state(btn2_state),
  .o_ondn(btn2_dn),
  .o_onup(btn2_up)
);

wire btn3_state, btn3_dn, btn3_up;
debounce d_btn3 (
  .clk(CLK),
  .i_btn(PIN_24),
  .o_state(btn3_state),
  .o_ondn(btn3_dn),
  .o_onup(btn3_up)
);

wire [3:0] buttons; // {up, down, left, right}
assign buttons = {btn0_dn, btn1_dn, btn2_dn, btn3_dn};

snek mygame(
    .clk(clk_25MHz),
    .rst(rst),
    .buttons(buttons),
    .hsync(hsync),
    .vsync(vsync),
    .rgb({red, green, blue}),
    .fc(debug)
);

clk_divider frame_clk_div (
    .clk(CLK),
    .rst(0),
    .cycles(32'd66666),
    .clk_div(frame_clk)
  );



endmodule