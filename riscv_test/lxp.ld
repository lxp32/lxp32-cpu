MEMORY
{
	RAM (rwx)    : ORIGIN = 0x00000000, LENGTH = 0x10000000 
}


ENTRY(_start)

SECTIONS
{
  . = 0x0;
  .text : { *(.text) } > RAM
  . = 0x1000;
  .data : { *(.data) } > RAM
  .bss : { *(.bss) }   > RAM
}

monitor = 0x10000000;
