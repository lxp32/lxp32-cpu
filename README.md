# lxp32-cpu

LXP32 is a small, FPGA friendly 32-bit CPU IP core. Its key features include:

* portability (described in behavioral VHDL-93, not tied to any particular vendor);
* 3-stage hazard-free pipeline;
* 256 registers implemented as a RAM block;
* a simple instruction set with only 30 distinct opcodes;
* separate instruction and data buses, optional instruction cache;
* WISHBONE compatibility;
* 8 interrupts with hardwired priorities;
* optional divider.

As a lightweight CPU core, LXP32 lacks some features of more advanced processors, such as nested interrupt handling, debugging support, floating-point and memory management units. LXP32 is based on an original ISA (Instruction Set Architecture) which does not currently have a C compiler. It can be programmed in the assembly language covered in the manual.

Project website: [https://lxp32.github.io/](https://lxp32.github.io/)
