module top(
    input CLK,      // 16 MHz Clock
    input PIN_7,    // rst
    input PIN_2,    // up
    input PIN_6,    // down
    input PIN_3,    // left
    input PIN_24,   // right
    //output LED,     // User/boot LED next to pwr
    output PIN_11,  // hsync
    output PIN_12,  // vsync
    output PIN_21,  // red
    output PIN_20,  // green
    output PIN_19,  // blue
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

wire [3:0] buttons; // {up, down, left, right}
assign buttons = {PIN_2, PIN_6, PIN_3, PIN_24};

assign PIN_21 = red;
assign PIN_20 = green;
assign PIN_19 = blue;
assign PIN_11 = hsync;
assign PIN_12 = vsync;

snek mygame(
    .clk(clk_25MHz),
    .rst(rst),
    .buttons(buttons),
    .hsync(hsync),
    .vsync(vsync),
    .rgb({red, green, blue})
);

endmodule