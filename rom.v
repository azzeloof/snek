module rom (
address , // Address input
data    , // Data output
en , // Read Enable 
);
input [11:0] address;
output [31:0] data; 
input en;
           
reg [639:0] mem [0:479] ;  
      
assign data = en ? mem[address] : 32'b0;

initial begin
  $readmemb("splash.bin", mem);
end

endmodule