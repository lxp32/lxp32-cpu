
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package csr_def is

subtype t_csr_adrprefix is std_logic_vector(3 downto 0);
constant m_stdprefix : t_csr_adrprefix := x"3";
constant m_nonstdprefix : t_csr_adrprefix :=x"7";
constant m_roprefix : t_csr_adrprefix :=x"F";

subtype t_csr_adr is std_logic_vector(7 downto 0);
subtype t_csr_word is std_logic_vector(31 downto 0);

-- trap setup registers
constant status : t_csr_adr:= x"00"; --  Machine status register.
constant isa    : t_csr_adr:=x"01";
constant edeleg : t_csr_adr:= x"02";
constant ideleg : t_csr_adr:= x"03";
constant ie     : t_csr_adr:= x"04";
constant tvec : t_csr_adr:=   x"05";

--Read only Machine Information Registers
constant vendorid : t_csr_adr:=  X"11";
constant marchid :  t_csr_adr:=  X"12";
constant impid   :  t_csr_adr:=  X"13";
constant hartid  :  t_csr_adr:=  X"14";

constant scratch : t_csr_adr:=   x"40";
constant epc: t_csr_adr:=        x"41";
constant cause : t_csr_adr:=     x"42";
constant ip : t_csr_adr:=        x"44";

-- non standard registers
constant icontrol : t_csr_adr:=x"C0"; -- full address is 0x7C0

constant impvers : std_logic_vector(31 downto 0) := X"0001000C";

function get_misa(divider_en:boolean;mul_arch:string) return t_csr_word;
function get_mstatus(pie : std_logic; ie : std_logic) return t_csr_word;

end csr_def;

package body csr_def is

function get_misa(divider_en:boolean;mul_arch:string) return t_csr_word is
variable misa : t_csr_word := "0100" & X"0000000";
begin
  misa(8):='1';
  if divider_en and mul_arch /= "none" then
    misa(12):='1';
  end if;
  return misa;
end;    

function get_mstatus(pie : std_logic; ie : std_logic) return t_csr_word is
variable s : t_csr_word := (others=>'0');
begin
  s(12 downto 11) := "11"; -- MPP previous privilege level, always "machine" currently
  s(7) := pie;
  s(3) := ie;
  
  return s;

end;
    

end csr_def;
