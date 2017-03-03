---------------------------------------------------------------------
-- A basic parallel 16x16 multiplier with an output register
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- A straightforward behavioral description. Can be replaced
-- with a library component wrapper if needed.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_mul16x16 is
   generic (
     pipelined : boolean := false
   ); 
	port(
		clk_i: in std_logic;
		a_i: in std_logic_vector(15 downto 0);
		b_i: in std_logic_vector(15 downto 0);
		p_o: out std_logic_vector(31 downto 0)
	);
end entity;



architecture rtl of lxp32_mul16x16 is
signal a,b : std_logic_vector(15 downto 0);
signal prod_reg, prod : std_logic_vector(31 downto 0);

begin

mul16_piplined : if pipelined generate

  prod <= std_logic_vector(unsigned(a)*unsigned(b));  
  p_o <= prod_reg;

process (clk_i) is
begin
	if rising_edge(clk_i) then
	  a <= a_i;
     b <= b_i;	
     prod_reg <= prod; 
	end if;
   
end process;


end generate;
 
 
mul16_not_piplined : if  not pipelined generate

process (clk_i) is
begin
	if rising_edge(clk_i) then
		p_o<=std_logic_vector(unsigned(a_i)*unsigned(b_i));
	end if;
end process;

end generate;







end architecture;
