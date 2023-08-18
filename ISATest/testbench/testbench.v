//UTF-8
//用于ISATest的testbench文件，如vivdado要用�?要另�?
`timescale 1ns / 1ps

module test( );
    // Inputs
	reg sys_clk;
	reg rst_n;
    wire [31:0] PC=u_soc.PC;
    wire [31:0] IR=u_soc.IR;
    integer fd,r;
    
    SOC u_soc(.clk(sys_clk),.rstn(rst_n));
    
    initial begin
    
        $readmemh (`INPUT, u_soc.u_rom.rom);
        $dumpfile("test.vcd");
        $dumpvars(0, test);
        // Initialize Inputs
		sys_clk = 0;
		rst_n = 0;

		#1000;
		rst_n=1;
		
		wait(u_soc.u_ram.ram[4] == 32'h1);  // wait sim end
        
        fd = $fopen("signature.output");   // OUTPUT
        for (r = u_soc.u_ram.ram[2]; r < u_soc.u_ram.ram[3]; r = r + 4) begin
            $fdisplay(fd, "%x", u_soc.u_rom.rom[r[31:2]]);
        end
        $fclose(fd);
        $finish;
        
    end
    
    always #10 sys_clk = ~ sys_clk;
    
    
endmodule
