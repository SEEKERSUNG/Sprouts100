module Clint(input wire clk,
             input wire rstn,
             
             input wire [31:0] PC,
             input wire [31:0] IR,

             input wire [7:0] intFlag,        //interruptor flag 外部中断预留
             output reg holdFlag,             //holdFlag

             input wire[31:0] csrMtvecData,
             input wire[31:0] csrMepcData,
             input wire[31:0] csrMstatusData,

             output reg csrWriteEn,
             output reg [11:0] csrAddr,
             output reg [31:0] csrWriteData,

             output reg jumpEn,
             output reg [31:0] jumpAddr);
    
    
    reg globalIntEnable;
    
    reg [1:0] intState; //inpterrupt state
    parameter [1:0] sIntIdle = 0,sException = 1,sInterrupt = 2,sMret = 3;//inpterrupt check parameter
    reg [31:0] cause,toMepc;//interrupt cause
    
    reg [2:0] csrState; //CSR state
    parameter [2:0] sCSRIdle = 0,sCSRMstatus = 1,sCSRMepc = 2,sCSRMret = 3,sCSRMcause = 4,sCSRWait = 5;//CSR operation state
    
    always @(*) begin
        if (~rstn) begin
            globalIntEnable = 0;
            holdFlag        = 0;
        end
        else begin
            globalIntEnable = csrMstatusData[3]; //global interrupt enable
            holdFlag        = ((intState != sIntIdle) | (csrState != sCSRIdle))? 1:0; //holdFlag output
        end
    end
    
    
    // interrupt check
    always @ (*) begin
        if (~rstn) begin
            intState = sIntIdle;
            cause    = 0;
            toMepc   = 0;
        end
        else begin
            if (IR == 32'h73) begin //ecall
                intState = sException;
                cause    = 32'd11;
                toMepc   = PC;
            end
            else if (IR == 32'h00100073) begin //ebreak
                intState = sException;
                cause    = 32'd3;
                toMepc   = PC;
            end
            else if (intFlag != 0 && globalIntEnable) begin
                //now only support time interrupt
                intState = sInterrupt;
                cause    = 32'h80000004;
                toMepc   = PC-4;
            end
            else if (IR == 32'h30200073) begin //mret
                intState = sMret;
                cause    = 0;
                toMepc   = 0;
            end
            else begin
                intState = sIntIdle;
                cause    = 0;
                toMepc   = 0;
            end
        end
    end
    
    //CSR operation
    always @ (posedge clk, negedge rstn) begin
        if (~rstn) begin
            csrState     <= sCSRIdle;
            csrWriteEn   <= 0;
            csrAddr      <= 0;
            csrWriteData <= 0;
            
            jumpEn <= 0;
            jumpAddr   <= 0;
        end
        else begin
            case (csrState)
                sCSRIdle:begin
                    case(intState)
                        sException:begin
                            csrState <= sCSRMepc;
                        end
                        sInterrupt:begin
                            csrState <= sCSRMepc;
                        end
                        sMret:begin
                            csrState <= sCSRMret;
                        end
                        default:begin
                            csrState <= sCSRIdle;
                        end
                    endcase
                    
                    csrWriteEn   <= 0;
                    csrAddr      <= 0;
                    csrWriteData <= 0;
                    
                    jumpEn <= 0;
                    jumpAddr   <= 0;
                end
                sCSRMepc: begin // PC to mepc
                    csrWriteEn   <= 1;
                    csrAddr      <= 12'h341;
                    csrWriteData <= toMepc;
                    csrState     <= sCSRMstatus;
                    
                    jumpEn <= 0;
                    jumpAddr   <= 0;
                end
                sCSRMstatus: begin  // disable global interrupt
                    csrWriteEn   <= 1;
                    csrAddr      <= 12'h300;
                    csrWriteData <= {csrMstatusData[31:4], 1'b0, csrMstatusData[2:0]};
                    csrState     <= sCSRMcause;
                    
                    jumpEn <= 0;
                    jumpAddr   <= 0;
                end
                sCSRMcause: begin   // write interrupt cause
                    csrWriteEn   <= 1;
                    csrAddr      <= 12'h342;
                    csrWriteData <= cause;
                    csrState     <= sCSRWait;
                    
                    jumpEn <= 1;
                    jumpAddr   <= csrMtvecData;
                end
                sCSRMret: begin // interrupt return
                    csrWriteEn   <= 1;
                    csrAddr      <= 12'h300;
                    csrWriteData <= {csrMstatusData[31:4], csrMstatusData[7], csrMstatusData[2:0]};
                    csrState     <= sCSRWait;
                    
                    jumpEn <= 1;
                    jumpAddr   <= csrMepcData;
                end
                sCSRWait:begin  //wait a clock to synchronous
                    csrWriteEn   <= 0;
                    csrAddr      <= 0;
                    csrWriteData <= 0;
                    csrState     <= sCSRIdle;
                    
                    jumpEn <= 0;
                    jumpAddr   <= 0;
                end
                default: begin
                    csrWriteEn   <= 0;
                    csrAddr      <= 0;
                    csrWriteData <= 0;
                    csrState     <= sCSRIdle;
                    
                    jumpEn <= 0;
                    jumpAddr   <= 0;
                end
            endcase
        end
    end
endmodule
