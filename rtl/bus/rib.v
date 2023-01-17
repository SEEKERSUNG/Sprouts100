module rib (input rstn,

            input wire busWriteEnable,            //bus write enable
            input wire [31:0] busAddr,            //bus address
            input wire [31:0] busWriteData,       //bus write data
            output reg [31:0] busReadData,        //bus read data

            input wire [31:0] romReadData,        //rom read data
            output reg romWriteEnable,            //rom write enable
            output reg [31:0] romAddr,            //rom address
            output reg [31:0] romWriteData,       //rom write data

            input wire [31:0] ramReadData,        //ram read data
            output reg ramWriteEnable,            //ram write enable
            output reg [31:0] ramAddr,            //ram address
            output reg [31:0] ramWriteData        //ram write data
            );
    
    reg writeEnable;
    reg [31:0] addr,readData,writeData;
    
    //arbitration
    always @(*) begin
        if (~rstn) begin
            addr              = 0;
            busReadData       = 0;
            writeEnable       = 0;
            writeData         = 0;
        end
        else begin
            addr              = busAddr;
            busReadData       = readData;
            writeEnable       = busWriteEnable;
            writeData         = busWriteData;
        end
    end
    
    
    //peripherals read and write
    always @(*) begin
        case(addr[31:28])
            4'h0:begin
                readData = romReadData;
                
                romWriteEnable = writeEnable;
                romAddr        = {4'b0,addr[27:0]};
                romWriteData   = writeData;
                
                ramWriteEnable = 0;
                ramAddr        = 0;
                ramWriteData   = 0;
            end
            4'h1:begin
                readData = ramReadData;
                
                romWriteEnable = 0;
                romAddr        = 0;
                romWriteData   = 0;
                
                ramWriteEnable = writeEnable;
                ramAddr        = {4'b0,addr[27:0]};
                ramWriteData   = writeData;
            end
            4'h2:begin
                readData = 0;
                
                romWriteEnable = 0;
                romAddr        = 0;
                romWriteData   = 0;
                
                ramWriteEnable = 0;
                ramAddr        = 0;
                ramWriteData   = 0;
            end
            default:begin
                readData = 0;
                
                romWriteEnable = 0;
                romAddr        = 0;
                romWriteData   = 0;
                
                ramWriteEnable = 0;
                ramAddr        = 0;
                ramWriteData   = 0;
            end
        endcase
    end
    
endmodule //rib
