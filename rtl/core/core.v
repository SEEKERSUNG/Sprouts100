module core (input wire clk,
             input wire rstn,
             input wire [31:0] IR,             //PC value
             output wire [31:0] PC,            //PC to IR
             input wire [31:0] busReadData,    //bus read data reg
             output wire busWriteEn,           //bus write enable
             output wire [31:0] busAddr,       //bus address
             output wire [31:0] busWriteData); //bus write data reg
    
    wire holdFlag,clintWriteCSRsEn,clintWritePCEn;
    wire [11:0] clintCSRsAddr;
    wire [31:0] csrMtvecData,csrMepcData,csrMstatusData,clintWriteCSRsData,clintWritePCData;

    wire exWriteCSRsEn;
    wire [11:0] exCSRsAddr;
    wire [31:0] exWriteCSRsData,exReadCSRsData;

    wire exWritePCEn;
    wire [31:0] exWritePCData;

    wire rdEn;
    wire [4:0] rd,rs1,rs2;
    wire [31:0] rdData,rs1Data,rs2Data;

    
    Clint u_Clint(
    .clk(clk),
    .rstn(rstn),

    .PC(PC),
    .IR(IR),

    .intFlag(8'b0),       //interruptor flag
    .holdFlag(holdFlag),           //holdFlag

    .csrMtvecData(csrMtvecData),
    .csrMepcData(csrMepcData),
    .csrMstatusData(csrMstatusData),


    .csrWriteEn(clintWriteCSRsEn),
    .csrAddr(clintCSRsAddr),
    .csrWriteData(clintWriteCSRsData),

    .jumpEn(clintWritePCEn),
    .jumpAddr(clintWritePCData)
    );

    CSRs u_CSRs(
    .clk(clk),
    .rstn(rstn),

    .exWriteEn(exWriteCSRsEn),      //ex write enable
    .exAddr(exCSRsAddr),            //ex addr
    .exWriteData(exWriteCSRsData),  //ex wirte data
    .exReadData(exReadCSRsData),     //ex read data

    .clintWriteEn(clintWriteCSRsEn),            //clint write enable
    .clintAddr(clintCSRsAddr),                   //clint addr
    .clintWriteData(clintWriteCSRsData),    //clint wirte data

    .mtvec(csrMtvecData),
    .mepc(csrMepcData),
    .mstatus(csrMstatusData)
    );

    
    PCReg u_PCReg(
    .clk(clk),
    .rstn(rstn),
    .holdFlag(holdFlag),

    .exJumpEn(exWritePCEn),    //PC write enable
    .exJumpAddr(exWritePCData),//PC read data

    .clintJumpEn(clintWritePCEn),        //clint write enable
    .clintJumpAddr(clintWritePCData),          //clint write data

    .PC(PC)                 //PC value
    );
    
    regfiles u_regfiles(
    .clk(clk),
    .rstn(rstn),
    
    .rdWriteEn(rdEn),        //rd write enable
    .rd(rd),            //rd addr
    .rdData(rdData),    //rd write data
    
    .rs1(rs1),          //rs1 addr
    .rs2(rs2),          //rs2 addr
    .rs1Data(rs1Data),  //rs1 read data
    .rs2Data(rs2Data)   //rs2 read data
    );
    
    
    id_ex u_id_ex(
    .rstn(rstn),
    .holdFlag(holdFlag),
    
    .PC(PC),
    .IRin(IR),

    .jumpEn(exWritePCEn),      //PC write data reg
    .jumpAddr(exWritePCData),          //PC write enable
    
    .rs1Data(rs1Data),
    .rs2Data(rs2Data),
    .rs1(rs1),
    .rs2(rs2),

    .rdWriteEn(rdEn),                    //rd write enable
    .rd(rd),
    .rdData(rdData),                //rd write data reg
    
    .busReadData(busReadData),      //bus read data reg
    .busWriteEn(busWriteEn),        //bus write enable
    .busAddr(busAddr),              //bus address
    .busWriteData(busWriteData),    //bus write data reg

    .CSRsReadData(exReadCSRsData),    //CSRs read reg
    .CSRsWriteEn(exWriteCSRsEn),      //CSRs write enable
    .CSRsAddr(exCSRsAddr),            //CSRs address reg
    .CSRsWriteData(exWriteCSRsData)   //CSRs write reg
    );
    
endmodule //core
