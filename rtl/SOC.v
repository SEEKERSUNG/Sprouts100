module SOC(input wire clk,
           input wire rstn);

    wire [31:0] IR,PC;
    wire busWriteEn;
    wire [31:0] busAddr,busWriteData,busReadData;

    wire romWriteEnable;
    wire [31:0] romAddr,romWriteData,romReadData;

    wire ramWriteEnable;
    wire [31:0] ramReadData,ramAddr,ramWriteData;


    
    core u_core(
    .clk(clk),
    .rstn(rstn),
    
    .IR(IR),    //PC to IR
    .PC(PC),    //PC value
    
    .busReadData(busReadData),      //bus read data reg
    .busWriteEn(busWriteEn),        //bus read data reg
    .busAddr(busAddr),              //bus address
    .busWriteData(busWriteData)     //bus write enable
    );


    rib u_rib(
    .rstn(rstn),

    .busWriteEnable(busWriteEn),   //bus write enable
    .busAddr(busAddr),  //bus address
    .busWriteData(busWriteData),   //bus write data
    .busReadData(busReadData),  //bus read data
    
    .romReadData(romReadData),  //rom read data
    .romWriteEnable(romWriteEnable),    //rom write enable
    .romAddr(romAddr),  //rom address
    .romWriteData(romWriteData),    //rom write data
    
    .ramReadData(ramReadData),  //ram read data
    .ramWriteEnable(ramWriteEnable),    //ram write enable
    .ramAddr(ramAddr),  //ram address
    .ramWriteData(ramWriteData) //ram write data
    );
    
    ROM u_rom(
    .clk(clk),
    .rstn(rstn),
    
    .PC(PC),    //PC value
    .IR(IR),    //PC to IR
    
    .writeEnable(romWriteEnable),   //rom write enable
    .addr(romAddr), //rom address
    .writeData(romWriteData),   //rom write data
    .readData(romReadData)  //rom read data
    );

    RAM u_ram(
    .clk(clk),
    .rstn(rstn),
    
    .writeEnable(ramWriteEnable),   //ram write data enable
    .addr(ramAddr), //ram address
    .writeData(ramWriteData),   //ram write data
    .readData(ramReadData)  //ram read data
    );
    
endmodule
