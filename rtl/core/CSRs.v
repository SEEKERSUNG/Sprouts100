module CSRs (input wire clk,
             input wire rstn,

             input wire exWriteEn,             //CSR write enable
             input wire [11:0] exAddr,         //csr addr
             input wire [31:0] exWriteData,    //csr wirte data
             output reg [31:0] exReadData,     //csr read data

             input wire clintWriteEn,          //clint write enable
             input wire [11:0] clintAddr,      //clint addr
             input wire [31:0] clintWriteData, //clint wirte data
             
             output reg [31:0] mtvec,
             output reg [31:0] mepc,
             output reg [31:0] mstatus);
    
    reg [31:0] misa,mie,mscratch,mcause,mtval,mip,minstret,minstreth;
    reg [63:0] cycle;
    parameter [31:0] mvendorid = 0,marchid = 0,mimpid = 0,mhartid = 0;
    
    reg writeEn;
    reg [11:0] addr;
    reg [31:0] writeData;
    always @(*) begin
        writeEn    = exWriteEn|clintWriteEn;
        addr       = clintWriteEn?clintAddr:exAddr;
        writeData  = clintWriteEn?clintWriteData:exWriteData;
    end
    
    
    //CSRs write
    always @(posedge clk,negedge rstn) begin
        if (~rstn) begin
            mstatus   <= 0;
            misa      <= 0;
            mie       <= 0;
            mtvec     <= 0;
            mscratch  <= 0;
            mepc      <= 0;
            mcause    <= 0;
            mtval     <= 0;
            mip       <= 0;
            cycle     <= 0;
            minstret  <= 0;
            minstreth <= 0;
        end
        else begin
            cycle <= cycle+1; //cycle add self
            if (writeEn) begin
                case (addr)
                    12'h300:begin
                        mstatus <= writeData;
                    end
                    12'h301:begin
                        misa <= writeData;
                    end
                    12'h304:begin
                        mie <= writeData;
                    end
                    12'h305:begin
                        mtvec <= writeData;
                    end
                    12'h340:begin
                        mscratch <= writeData;
                    end
                    12'h341:begin
                        mepc <= writeData;
                    end
                    12'h342:begin
                        mcause <= writeData;
                    end
                    12'h343:begin
                        mtval <= writeData;
                    end
                    12'h344:begin
                        mip <= writeData;
                    end
                    12'hb00:begin
                        cycle[31:0] <= writeData;
                    end
                    12'hb02:begin
                        minstret <= writeData;
                    end
                    12'hb80:begin
                        cycle[63:32] <= writeData;
                    end
                    12'hb82:begin
                        minstreth <= writeData;
                    end
                    default:begin
                        
                    end
                endcase
            end
            else begin
                
            end
        end
    end
    
    //CSRs ex read
    always @(*) begin
        case (exAddr)
            12'hf11:begin
                exReadData = mvendorid;
            end
            12'hf12:begin
                exReadData = marchid;
            end
            12'hf13:begin
                exReadData = mimpid;
            end
            12'hf14:begin
                exReadData = mhartid;
            end
            12'h300:begin
                exReadData = mstatus;
            end
            12'h301:begin
                exReadData = misa;
            end
            12'h304:begin
                exReadData = mie;
            end
            12'h305:begin
                exReadData = mtvec;
            end
            12'h340:begin
                exReadData = mscratch;
            end
            12'h341:begin
                exReadData = mepc;
            end
            12'h342:begin
                exReadData = mcause;
            end
            12'h343:begin
                exReadData = mtval;
            end
            12'h344:begin
                exReadData = mip;
            end
            12'hb00:begin
                exReadData = cycle[31:0];
            end
            12'hb02:begin
                exReadData = minstret;
            end
            12'hb80:begin
                exReadData = cycle[63:32];
            end
            12'hb82:begin
                exReadData = minstreth;
            end
            default:begin
                exReadData = 0;
            end
        endcase
    end
    
endmodule
