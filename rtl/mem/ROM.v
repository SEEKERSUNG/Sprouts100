module ROM (input wire clk,
            input wire rstn,
            input wire [31:0] PC,        //PC value
            output reg [31:0] IR,        //PC to IR
            input wire writeEnable,      //rom write enable
            input wire [31:0] addr,      //rom address
            input wire [31:0] writeData, //rom write data
            output reg [31:0] readData); //rom read data
    
    reg [31:0] rom [0:4095];
    
    //read IR and data
    always @(*) begin
        if (~rstn)begin
            IR       = 0;
            readData = 0;
        end
        else begin
            IR       = rom[PC[31:2]];
            readData = rom[addr[31:2]];
        end
    end
    
    
    //write data
    always @(posedge clk) begin
        if (writeEnable&&rstn) begin
            rom[addr[31:2]] <= writeData;
        end
        else begin
            
        end
    end
endmodule //ROM
