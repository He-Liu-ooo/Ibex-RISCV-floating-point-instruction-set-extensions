# Ibex RISCV
This is a project about ibex-riscv floating-point instruction set extension. Ibex-riscv is originally a light-weighted riscv cpu which only supports integer instruction set.\
\
I extend part of the **RV32F** instruction set based on integer ibex cpu, and handwrite the assembly of **NMS** algorithm. The assembly go through the test on FPGA successfully.\
\
Compared with the original ibex cpu, this cpu has the following modifications:
1. Add an uart and a gpio as perpherial.
2. Add an divide-by-10 module. 
3. Combine the 4 8&times;1024 srams into a 32&times;1024 sram
4. Extend following instructions:
+ **RV32F:** FLW / FSW / FMADD.S / FMSUB.S / FNMSUB.S / FNMADD.S / FADD.S / FSUB.S / FMUL.S / FDIV.S / FMIN.S / FMAX.S / FEQ.S / FLT.S / FCVT.S.W
+ **custom RV32F:** FSUBABS.S / FADDDIV.S
+ **custom RV32I:** MUL / addrtwo / addrfive / plusonelt
