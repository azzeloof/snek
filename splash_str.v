/*
 * Description: Splash with stream RGB.
 * Author:      Juan Manuel Rico
 * Date:        29/11/2020
 */
module splash_str (
    input wire px_clk,
    input wire [25:0] strRGB_i,
    input wire [25:0] strRGB_o
);

    reg [639:0] mem [0:479];

    initial begin
        $readmemb("splash.bin", mem);
    end

    // Bit address alias.
    `define active 0:0
    `define VS     1:1
    `define HS     2:2
    `define YC     12:3
    `define XC     22:13
    `define R      23:23
    `define G      24:24
    `define B      25:25

    // Output RGB stream register.
    reg [25:0] strRGB_reg;
    assign strRGB_o = strRGB_reg;

    // Processing RGB stream.
    always @(posedge px_clk)
    begin
        // Clone input RGB stream.
        strRGB_reg <= strRGB_i;

        // Get image from memory.
        strRGB_reg[`R] <= 0;
        strRGB_reg[`G] <= mem [strRGB_i [`YC] + 1] [strRGB_i [`XC]];
        strRGB_reg[`B] <= 0;
    end

endmodule