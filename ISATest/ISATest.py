import sys
import filecmp
import subprocess
import sys
import os


def compileRtlSrc(hexPath):

    iverilog_cmd = ['iverilog']
    iverilog_cmd += ['-o', r'out.vvp']
    iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    iverilog_cmd += ['-D', r'INPUT="'+hexPath+r'"']
    iverilog_cmd.append(r'testbench/testbench.v')
    iverilog_cmd.append(r'../rtl/*.v')
    iverilog_cmd.append(r'../rtl/core/*.v')
    iverilog_cmd.append(r'../rtl/bus/*.v')
    iverilog_cmd.append(r'../rtl/mem/*.v')

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

def runSim():
    logfile = open('run.log', 'w')
    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'out.vvp')
    process = subprocess.Popen(vvp_cmd, stdout=logfile, stderr=logfile)
    process.wait(timeout=10)
    logfile.close()

def compareOut(ref_file):
    if (ref_file != None):
        # 如果文件大小不一致，直接报fail
        if (os.path.getsize('signature.output') != os.path.getsize(ref_file)):
            print('!!! FAIL, size != !!!')
            return
        f1 = open('signature.output')
        f2 = open(ref_file)
        f1_lines = f1.readlines()
        i = 0
        # 逐行比较
        mainName = os.path.splitext(ref_file)[0] #获取文件名
        for line in f2.readlines():
            # 只要有一行内容不一样就报fail
            if (f1_lines[i] != line):
                print(mainName+'\t!!! FAIL, content != !!!')
                f1.close()
                f2.close()
                return
            i = i + 1
        f1.close()
        f2.close()  
        print(mainName+'\t### PASS ###')
    else:
        print(ref_file+'\t没找到ref文件！')




def ISAtest(testISA):
    HexDirPath=testISA+'/rom/'
    referDirPath=testISA+'/references/'

    files= os.listdir(HexDirPath)
    for file in files:
        compileRtlSrc(HexDirPath+file)
        runSim()
        mainName = os.path.splitext(file)[0] 
        compareOut(referDirPath+mainName+'.reference_output')






testISA=['RV32I','RV32M','RV32Zicsr','RV32Zifencei']
for i in testISA:
    ISAtest(i)


os.remove("out.vvp")
os.remove("signature.output")
os.remove("test.vcd")