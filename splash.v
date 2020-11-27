module splash (
    input clk,
    input rst,
    input [9:0] hpos,
    input [9:0] vpos,
    output r,
    output g,
    output b
);

reg [639:0] mem [0:479];

initial begin
  $readmemb("splash.bin", mem);
end

assign r = mem[vpos+1][hpos];
assign g = 1;
assign b = 0; // only works if vpos is offset for some reason

endmodule