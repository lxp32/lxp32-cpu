# lxp32-cpu

LXP32 is a small and FPGA friendly 32-bit CPU IP core based on a simple, original instruction set. Its key features include:

* portability (described in behavioral VHDL, not tied to any particular vendor);
* 3-stage hazard-free pipeline;
* 256 registers implemented as a RAM block;
* only 30 distinct opcodes;
* separate instruction and data buses, optional instruction cache;
* WISHBONE compatibility;
* 8 interrupts with hardwired priorities;
* optional divider.

The LXP32 processor was successfully used in commercial projects, is [well documented](https://github.com/lxp32/lxp32-cpu/raw/develop/doc/lxp32-trm.pdf) and comes with a verification environment.

LXP32 lacks some features of more advanced processors, such as nested interrupt handling, debugging support, floating-point and memory management units. LXP32 ISA (Instruction Set Architecture) does not currently have a C compiler, only assembly based workflow is supported.

Project website: [https://lxp32.github.io/](https://lxp32.github.io/)
