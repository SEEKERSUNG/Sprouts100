module RAM (input wire clk,
            input wire rstn,
            input wire writeEnable,      //ram write data enable
            input wire [31:0] addr,      //ram address
            input wire [31:0] writeData, //ram write data
            output reg [31:0] readData); //ram read data
    
    reg [31:0] ram [0:1023];
    
    //read data
    always @(*) begin
        if (~rstn) begin
            readData = 0;
        end
        else begin
            readData = ram[addr[31:2]];
        end
    end
    
    //write data
    always @(posedge clk) begin
        if (writeEnable&&rstn) begin
            ram[addr[31:2]] <= writeData;
        end
        else begin
            
        end
    end
endmodule
