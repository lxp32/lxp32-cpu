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

package csr_def is

subtype t_csr_adrprefix is std_logic_vector(3 downto 0);
constant m_stdprefix : t_csr_adrprefix := x"3";
constant m_nonstdprefix : t_csr_adrprefix :=x"7";

subtype t_csr_adr is std_logic_vector(7 downto 0);

-- Standard registers
constant status : t_csr_adr:= x"00"; --  Machine status register.
constant edeleg : t_csr_adr:= x"02"; 
constant ideleg : t_csr_adr:= x"03"; 
constant ie     : t_csr_adr:= x"04"; 
constant tvec : t_csr_adr:=   x"05"; 
constant scratch : t_csr_adr:=   x"40"; 
constant epc: t_csr_adr:=        x"41"; 
constant cause : t_csr_adr:=     x"43"; 
constant ip : t_csr_adr:=        x"44"; 

-- non standard registers 
constant icontrol : t_csr_adr:=x"C0"; -- full address is 0x7C0



-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end csr_def;

package body csr_def is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end csr_def;
