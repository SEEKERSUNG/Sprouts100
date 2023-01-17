module regfiles (input clk,
                 input rstn,
                 
                 input rdWriteEn,                 //rd write enable
                 input [4:0] rd,             //rd addr
                 input [31:0] rdData,        //rd write data

                 input [4:0] rs1,            //rs1 addr
                 input [4:0] rs2,            //rs2 addr
                 output reg [31:0] rs1Data,  //rs1 read data
                 output reg [31:0] rs2Data); //rs2 read data
    
    //regs
    reg [31:0] regs [0:31];
    
    //regs 读取
    always @(*) begin
            rs1Data = regs[rs1];
            rs2Data = regs[rs2];
    end
    
    //regs 写入
    always @(posedge clk,negedge rstn) begin
        if (~rstn) begin
            regs[0] <= 0;
        end
        else if (rdWriteEn && rd!= 0) begin
            regs[rd] <= rdData;
        end
        else begin
            regs[0] <= 0;
        end
    end
endmodule
