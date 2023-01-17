module id_ex (input wire rstn,
              input wire holdFlag,

              input wire [31:0] PC,
              input wire [31:0] IRin,

              output reg jumpEn,            //PC write enable
              output reg [31:0] jumpAddr,       //PC write data reg

              input wire [31:0] rs1Data,
              input wire [31:0] rs2Data,
              output reg [4:0] rs1,
              output reg [4:0] rs2,

              output reg rdWriteEn,                  //rd write enable
              output reg [4:0] rd,
              output reg [31:0] rdData,         //rd write data reg

              input wire [31:0] busReadData,    //bus read data reg
              output reg busWriteEn,            //bus write enable
              output reg [31:0] busAddr,        //bus address
              output reg [31:0] busWriteData,   //bus write data reg

              input wire [31:0] CSRsReadData,   //CSRs read reg
              output reg CSRsWriteEn,           //CSRs write enable
              output reg [11:0] CSRsAddr,       //CSRs address reg
              output reg [31:0] CSRsWriteData); //CSRs write reg
    
    reg [31:0] IR;
    reg [6:0] opcode;   
    reg [2:0] funct3;   
    reg [6:0] funct7;   
    reg [31:0] jaljumpAddr;      //PC jump addr for jal inst
    reg [31:0] instBjumpAddr;    //PC jump addr for B class inst
    
    //multi, div and % model
    reg [31:0] multiplier1,multiplier2,dividend,divisor;
    reg [31:0] rs1DataInvert,rs2DataInvert,divResult,divResultInvert,remReasult,remReasultInvert;
    reg [63:0] mulitReasult,mulitReasultInvert;
    
    
    //IR预处理
    always @(*) begin
        if (~rstn|holdFlag) begin
            IR = 32'h0000_0001; //NOP
        end
        else begin
            IR = IRin;
        end
    end
    
    
    //译码
    always @(*) begin
        opcode   = IR[6:0];
        funct3   = IR[14:12];
        funct7   = IR[31:25];
        rd       = IR[11:7];
        rs1      = IR[19:15];
        rs2      = IR[24:20];
        CSRsAddr = IR[31:20];
        
        //jal指令使用的跳转地址译码
        jaljumpAddr[19:12] = IR[19:12];
        jaljumpAddr[11]    = IR[20];
        jaljumpAddr[10:1]  = IR[30:21];
        jaljumpAddr[20]    = IR[31];
        jaljumpAddr[0]     = 0;
        jaljumpAddr[31:21] = {11{IR[31]}};
        
        //B型指令使用的跳转地址译码
        instBjumpAddr[0]     = 0;
        instBjumpAddr[4:1]   = IR[11:8];
        instBjumpAddr[11]    = IR[7];
        instBjumpAddr[10:5]  = IR[30:25];
        instBjumpAddr[12]    = IR[31];
        instBjumpAddr[31:13] = {19{IR[31]}};
    end
    
    
    //jump数据和使能
    always @(*) begin
        case(opcode)
            7'b1101111:begin    //jal
                jumpAddr   = jaljumpAddr+PC;
                jumpEn = 1;
            end
            7'b1100111:begin
                jumpAddr   = (rs1Data+{{20{IR[31]}},IR[31:20]})&(~32'b1);
                case (funct3)
                    3'b000:begin    //jalr
                        jumpEn = 1;
                    end
                    default:begin
                        jumpEn = 0;
                    end
                endcase
            end
            7'b1100011:begin
                jumpAddr   = instBjumpAddr+PC;
                case (funct3)
                    3'b000:begin    //beq
                        if (rs1Data == rs2Data)begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    3'b001:begin    //bne
                        if (rs1Data != rs2Data)begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    3'b100:begin    //blt
                        if ({{~rs1Data[31]},rs1Data[30:0]}<{{~rs2Data[31]},rs2Data[30:0]})begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    3'b101:begin    //bge
                        if ({{~rs1Data[31]},rs1Data[30:0]} >= {{~rs2Data[31]},rs2Data[30:0]})begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    3'b110:begin    //bltu
                        if (rs1Data<rs2Data)begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    3'b111:begin    //bgeu
                        if (rs1Data >= rs2Data)begin
                            jumpEn = 1;
                        end
                        else begin
                            jumpEn = 0;
                        end
                    end
                    default:begin
                        jumpEn = 0;
                    end
                endcase
            end
            default:begin
                jumpAddr   = 0;
                jumpEn = 0;
            end
        endcase
    end
    
    
    //访存地址的译码
    always @(*) begin
        case(opcode)
            7'b0000011:begin
                busAddr = rs1Data+{{20{IR[31]}},IR[31:20]};
            end
            7'b0100011:begin
                busAddr = rs1Data+{{20{IR[31]}},IR[31:25],IR[11:7]};//内存地址
            end
            default:begin
                busAddr = 0;
            end
        endcase
    end
    //访存写数据和使能
    always @(*) begin
        case (opcode)
            7'b0100011:begin
                case (funct3)
                    3'b000:begin    //sb
                        busWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00:begin
                                busWriteData = {busReadData[31:8],rs2Data[7:0]};
                            end
                            2'b01: begin
                                busWriteData = {busReadData[31:16], rs2Data[7:0], busReadData[7:0]};
                            end
                            2'b10: begin
                                busWriteData = {busReadData[31:24], rs2Data[7:0], busReadData[15:0]};
                            end
                            default: begin
                                busWriteData = {rs2Data[7:0], busReadData[23:0]};
                            end
                        endcase
                    end
                    3'b001:begin    //sh
                        busWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00:begin
                                busWriteData = {busReadData[31:16],rs2Data[15:0]};
                            end
                            default: begin
                                busWriteData = {rs2Data[15:0], busReadData[15:0]};
                            end
                        endcase
                    end
                    3'b010:begin    //sw
                        busWriteEn   = 1;
                        busWriteData = rs2Data;
                    end
                    default:begin
                        busWriteEn   = 0;
                        busWriteData = 0;
                    end
                endcase
            end
            default:begin
                busWriteEn   = 0;
                busWriteData = 0;
            end
        endcase
    end
    
    
    //CSR写数据和使能
    always @(*) begin
        case(opcode)
            7'b1110011:begin
                case (funct3)
                    3'b001:begin    //csrrw
                        CSRsWriteData = rs1Data;
                        CSRsWriteEn   = 1;
                    end
                    3'b010:begin    //csrrs
                        CSRsWriteData = rdData|rs1Data;
                        CSRsWriteEn   = 1;
                    end
                    3'b011:begin    //csrrc
                        CSRsWriteData = rdData & (~rs1Data);
                        CSRsWriteEn   = 1;
                    end
                    3'b101:begin    //csrrwi
                        CSRsWriteData = rs1;
                        CSRsWriteEn   = 1;
                    end
                    3'b110:begin    //csrrsi
                        CSRsWriteData = rdData|rs1;
                        CSRsWriteEn   = 1;
                    end
                    3'b111:begin    //csrrci
                        CSRsWriteData = rdData & (~rs1);
                        CSRsWriteEn   = 1;
                    end
                    default:begin
                        CSRsWriteData = 0;
                        CSRsWriteEn   = 0;
                    end
                endcase
            end
            default:begin
                CSRsWriteData = 0;
                CSRsWriteEn   = 0;
            end
        endcase
    end
    

    //乘除法的临时变量译码
    always @(*) begin
        rs1DataInvert      = ~rs1Data+1;//求补码
        rs2DataInvert      = ~rs2Data+1;//求补码

        case (funct3)
            3'b000:begin    //mul
                multiplier1 = rs1Data;
                multiplier2 = rs2Data;
            end
            3'b001:begin    //mulh
                multiplier1 = (rs1Data[31] == 1)? rs1DataInvert: rs1Data;
                multiplier2 = (rs2Data[31] == 1)? rs2DataInvert: rs2Data;
            end
            3'b010:begin    //mulhsu
                multiplier1 = (rs1Data[31] == 1)? rs1DataInvert: rs1Data;
                multiplier2 = rs2Data;
            end
            3'b011:begin    //mulhu
                multiplier1 = rs1Data;
                multiplier2 = rs2Data;
            end
            default:begin
                multiplier1 = 0;
                multiplier2 = 0;
            end
        endcase

        case (funct3)
            3'b100:begin//div
                dividend = (rs1Data[31] == 1)? rs1DataInvert: rs1Data;
                divisor  = (rs2Data[31] == 1)? rs2DataInvert: rs2Data;
            end
            3'b101:begin//divu
                dividend = rs1Data;
                divisor  = rs2Data;
            end
            3'b110:begin//rem
                dividend = (rs1Data[31] == 1)? rs1DataInvert: rs1Data;
                divisor  = (rs2Data[31] == 1)? rs2DataInvert: rs2Data;
            end
            3'b111:begin//remu
                dividend = rs1Data;
                divisor  = rs2Data;
            end
            default:begin
                dividend = 0;
                divisor  = 0;
            end
        endcase

        mulitReasult       = multiplier1*multiplier2;
        mulitReasultInvert = ~mulitReasult+1;//求补码
        divResult          = dividend/divisor;//求商
        divResultInvert    = ~divResult+1;//求补码
        remReasult         = dividend%divisor;//求余数
        remReasultInvert   = ~remReasult+1;//求补码
    end
    
    
    //rd写入数据和使能
    always @(*) begin
        case (opcode)
            7'b0110111:begin    //lui
                rdData = {IR[31:12],12'b0};
                rdWriteEn   = 1;
            end
            
            7'b0010111:begin    //auipc
                rdData = PC+{IR[31:12],12'b0};
                rdWriteEn   = 1;
            end
            
            7'b1101111:begin    //jal
                rdData = PC+4;
                rdWriteEn   = 1;
            end
            
            7'b1100111:begin
                case (funct3)
                    3'b000:begin    //jalr
                        rdData = PC+4;
                        rdWriteEn   = 1;
                    end
                    default:begin
                        rdData = 0;
                        rdWriteEn   = 0;
                    end
                endcase
            end
            
            7'b0000011:begin
                case (funct3)
                    3'b000:begin    //lb
                        rdWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00: begin
                                rdData = {{24{busReadData[7]}}, busReadData[7:0]};
                            end
                            2'b01: begin
                                rdData = {{24{busReadData[15]}}, busReadData[15:8]};
                            end
                            2'b10: begin
                                rdData = {{24{busReadData[23]}}, busReadData[23:16]};
                            end
                            default: begin
                                rdData = {{24{busReadData[31]}}, busReadData[31:24]};
                            end
                        endcase
                    end
                    3'b001:begin    //lh
                        rdWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00: begin
                                rdData = {{16{busReadData[15]}}, busReadData[15:0]};
                            end
                            default: begin
                                rdData = {{16{busReadData[31]}}, busReadData[31:16]};
                            end
                        endcase
                    end
                    3'b010:begin    //lw
                        rdData = busReadData;
                        rdWriteEn   = 1;
                    end
                    3'b100:begin    //lbu
                        rdWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00: begin
                                rdData = {24'b0, busReadData[7:0]};
                            end
                            2'b01: begin
                                rdData = {24'b0, busReadData[15:8]};
                            end
                            2'b10: begin
                                rdData = {24'b0, busReadData[23:16]};
                            end
                            default: begin
                                rdData = {24'b0, busReadData[31:24]};
                            end
                        endcase
                    end
                    3'b101:begin    //lhu
                        rdWriteEn = 1;
                        case (busAddr[1:0])
                            2'b00: begin
                                rdData = {16'b0, busReadData[15:0]};
                            end
                            default: begin
                                rdData = {16'b0, busReadData[31:16]};
                            end
                        endcase
                    end
                    default:begin
                        rdData = 0;
                        rdWriteEn   = 0;
                    end
                endcase
            end
            
            7'b0010011:begin
                case (funct3)
                    3'b000:begin    //addi
                        rdData = rs1Data+{{20{IR[31]}},IR[31:20]};
                        rdWriteEn   = 1;
                    end
                    3'b010:begin    //slti
                        rdWriteEn = 1;
                        if ({{~rs1Data[31]},rs1Data[30:0]}<{{~IR[31]},{19{IR[31]}},IR[31:20]}) begin
                            rdData = 1;
                        end
                        else begin
                            rdData = 0;
                        end
                    end
                    3'b011:begin    //sltiu
                        rdWriteEn = 1;
                        if (rs1Data<{{20{IR[31]}},IR[31:20]}) begin
                            rdData = 1;
                        end
                        else begin
                            rdData = 0;
                        end
                    end
                    3'b100:begin    //xori
                        rdData = rs1Data^{{20{IR[31]}},IR[31:20]};
                        rdWriteEn   = 1;
                    end
                    3'b110:begin    //ori
                        rdData = rs1Data|{{20{IR[31]}},IR[31:20]};
                        rdWriteEn   = 1;
                    end
                    3'b111:begin    //andi
                        rdData = rs1Data&{{20{IR[31]}},IR[31:20]};
                        rdWriteEn   = 1;
                    end
                    3'b001:begin
                        case (funct7)
                            7'b0000000:begin    //slli
                                rdData = rs1Data<<rs2;
                                rdWriteEn   = 1;
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b101:begin
                        case (funct7)
                            7'b0000000:begin    //srli
                                rdData = rs1Data>>rs2;
                                rdWriteEn   = 1;
                            end
                            7'b0100000:begin    //srai
                                rdData = rs1Data>>rs2;
                                rdData = rdData | ({32{rs1Data[31]}} & (~(32'hffff_ffff>>rs2)));
                                rdWriteEn   = 1;
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    default:begin
                        rdData = 0;
                        rdWriteEn   = 0;
                    end
                endcase
            end
            
            7'b0110011:begin
                case (funct3)
                    3'b000:begin
                        case (funct7)
                            7'b0000000:begin    //add
                                rdData = rs1Data+rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0100000:begin    //sub
                                rdData = rs1Data-rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //mul
                                rdData      = mulitReasult;
                                rdWriteEn        = 1;
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b001:begin
                        case (funct7)
                            7'b0000000:begin    //sll
                                rdData = rs1Data<<rs2Data[4:0];
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //mulh
                                rdWriteEn        = 1;
                                if (rs1Data[31]^rs2Data[31]) begin
                                    rdData = mulitReasultInvert[63:32];
                                end
                                else begin
                                    rdData = mulitReasult[63:32];
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b010:begin
                        case (funct7)
                            7'b0000000:begin    //slt
                                if ({{~rs1Data[31]},rs1Data[30:0]}<{{~rs2Data[31]},rs2Data[30:0]}) begin
                                    rdData = 1;
                                    rdWriteEn   = 1;
                                end
                                else begin
                                    rdData = 0;
                                    rdWriteEn   = 1;
                                end
                            end
                            7'b0000001:begin    //mulhsu
                                rdWriteEn        = 1;
                                if (rs1Data[31] == 1'b1) begin
                                    rdData = mulitReasultInvert[63:32];
                                end
                                else begin
                                    rdData = mulitReasult[63:32];
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b011:begin
                        case (funct7)
                            7'b0000000:begin    //sltu
                                rdWriteEn = 1;
                                if (rs1Data<rs2Data) begin
                                    rdData = 1;
                                end
                                else begin
                                    rdData = 0;
                                end
                            end
                            7'b0000001:begin    //mulhu
                                rdData      = mulitReasult[63:32];
                                rdWriteEn        = 1;
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b100:begin
                        case (funct7)
                            7'b0000000:begin    //xor
                                rdData = rs1Data^rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //div
                                if (rs2Data == 0) begin
                                    rdData = 32'hffff_ffff;
                                    rdWriteEn   = 1;
                                end
                                else begin
                                    rdWriteEn     = 1;
                                    if (rs1Data[31]^rs2Data[31]) begin
                                        rdData = divResultInvert;
                                    end
                                    else begin
                                        rdData = divResult;
                                    end
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b101:begin
                        case (funct7)
                            7'b0000000:begin    //srl
                                rdData = rs1Data>>rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0100000:begin    //sra
                                rdData = rs1Data>>rs2Data;
                                rdData = rdData | ({32{rs1Data[31]}} & (~(32'hffff_ffff>>rs2Data)));
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //divu
                                rdWriteEn = 1;
                                if (rs2Data == 0) begin
                                    rdData = 32'hffff_ffff;
                                end
                                else begin
                                    rdData   = divResult;
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b110:begin
                        case (funct7)
                            7'b0000000:begin    //or
                                rdData = rs1Data|rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //rem
                                rdWriteEn = 1;
                                if (rs2Data == 0) begin
                                    rdData = rs1Data;
                                end
                                else begin
                                    if (rs1Data[31]) begin
                                        rdData = remReasultInvert;
                                    end
                                    else begin
                                        rdData = remReasult;
                                    end
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    3'b111:begin
                        case (funct7)
                            7'b0000000:begin    //and
                                rdData = rs1Data&rs2Data;
                                rdWriteEn   = 1;
                            end
                            7'b0000001:begin    //remu
                                rdWriteEn = 1;
                                if (rs2Data == 0) begin
                                    rdData = rs1Data;
                                end
                                else begin
                                    rdData   = remReasult;
                                end
                            end
                            default:begin
                                rdData = 0;
                                rdWriteEn   = 0;
                            end
                        endcase
                    end
                    default:begin
                        rdData = 0;
                        rdWriteEn   = 0;
                    end
                endcase
            end
            
            //fence.i 为空命令
            
            7'b1110011:begin
                rdData = CSRsReadData;
                case (funct3)
                    3'b001,3'b010,3'b011,3'b101,3'b110,3'b111:begin    //csrrw
                        rdWriteEn   = 1;
                    end
                    default:begin
                        rdData = 0;
                        rdWriteEn   = 0;
                    end
                endcase
            end

            default:begin
                rdData = 0;
                rdWriteEn   = 0;
            end
        endcase
    end
    
endmodule //id_ex
