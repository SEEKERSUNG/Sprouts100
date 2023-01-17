module PCReg (input wire clk,
              input wire rstn,
              input wire holdFlag,
              input wire exJumpEn,             //ex write enable
              input wire [31:0] exJumpAddr,    //ex read data
              input wire clintJumpEn,          //clint write enable
              input wire [31:0] clintJumpAddr, //clint write data
              output reg [31:0] PC);            //PC value
    
    
    //PC write
    always @(posedge clk,negedge rstn) begin
        if (~rstn) begin
            PC <= 0;
        end
        else if (clintJumpEn) begin
            PC <= clintJumpAddr;
        end
        else if (exJumpEn) begin
            PC <= exJumpAddr;
        end
        else if (holdFlag) begin
            PC <= PC;
        end
        else begin
            PC <= PC+4;
        end
    end
    
endmodule
