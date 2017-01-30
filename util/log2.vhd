--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package log2 is

function LOG2(C:INTEGER) return INTEGER;

function power2(n:natural) return natural;

end log2;

package body log2 is

function LOG2(C:INTEGER) return INTEGER is -- C should be >0 
variable TEMP,COUNT:INTEGER; 
begin 
  TEMP:=0; 
  COUNT:=C;
  while COUNT>1 loop 
    TEMP:=TEMP+1; 
    COUNT:=COUNT/2; 
  end loop; 
  
  return TEMP; 
end; 

function power2(n:natural) return natural is
variable res: natural;
begin
  res:=1;
  for i in 1 to n loop
    res:=res*2;
  end loop;  
  return res;
end;

end log2;
