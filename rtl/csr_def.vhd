
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package csr_def is

subtype t_csr_adrprefix is std_logic_vector(3 downto 0);
constant m_stdprefix : t_csr_adrprefix := x"3";
constant m_nonstdprefix : t_csr_adrprefix :=x"7";
constant m_roprefix : t_csr_adrprefix :=x"F";

subtype t_csr_adr is std_logic_vector(7 downto 0);

-- Standard registers
constant status : t_csr_adr:= x"00"; --  Machine status register.
constant edeleg : t_csr_adr:= x"02"; 
constant ideleg : t_csr_adr:= x"03"; 
constant ie     : t_csr_adr:= x"04"; 
constant tvec : t_csr_adr:=   x"05"; 
constant impid : t_csr_adr:=  X"13";
constant scratch : t_csr_adr:=   x"40"; 
constant epc: t_csr_adr:=        x"41"; 
constant cause : t_csr_adr:=     x"42"; 
constant ip : t_csr_adr:=        x"44"; 

-- non standard registers 
constant icontrol : t_csr_adr:=x"C0"; -- full address is 0x7C0

constant impvers : std_logic_vector(31 downto 0) := X"00010001";


end csr_def;

package body csr_def is

 
end csr_def;
