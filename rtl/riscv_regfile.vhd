----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Thomas Hornschuh
-- 
-- Create Date:    14:19:06 12/04/2016 
-- Design Name: 
-- Module Name:    riscv_regfile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Regfile for RISC V.
-- For compatiblity reasons the interface still uses 8 Bit addresses like the lxp implementation
-- Internally only 5 Bits are used
-- The Implementation details (e.g. how to implement a 3-Port RAM) is left to the Xilinx  tools
-- This makes code cleaner and also simulation easier, because it shows only one register file
-- The implementation supports block and distributed RAM
-- For this a  generic parameter REG_RAM_STYLE is added 

-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity riscv_regfile is
generic (
  REG_RAM_STYLE : string := "block"
);
port(
		clk_i: in std_logic;
		
		raddr1_i: in std_logic_vector(7 downto 0);
		rdata1_o: out std_logic_vector(31 downto 0);
		raddr2_i: in std_logic_vector(7 downto 0);
		rdata2_o: out std_logic_vector(31 downto 0);
		
		waddr_i: in std_logic_vector(7 downto 0);
		we_i: in std_logic;
		wdata_i: in std_logic_vector(31 downto 0)
	);
end riscv_regfile;

architecture rtl of riscv_regfile is

type reg_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal regfile : reg_type :=(others=>(others=>'0')); -- zero-initialize for SRAM-based FPGAs

attribute ram_style: string; -- for Xilinx
attribute ram_style of regfile: signal is REG_RAM_STYLE;


signal wdata_reg: std_logic_vector(wdata_i'range);
signal ram1_rdata: std_logic_vector(31 downto 0);
signal ram2_rdata: std_logic_vector(31 downto 0);

signal ram1_collision: std_logic;
signal ram2_collision: std_logic;

begin

assert REG_RAM_STYLE="block" or REG_RAM_STYLE="distributed" 
	report "Invalid REG_RAM_STYLE generic value: block or distributed are expected"
	severity failure;


  -- RAM access
  -- The code defines a tripple-port RAM
  -- let Xilinx inference solve this...  
  process(clk_i) 
  begin
    if rising_edge(clk_i) then
      ram1_rdata <= regfile(to_integer(unsigned(raddr1_i(4 downto 0))));
      ram2_rdata <= regfile(to_integer(unsigned(raddr2_i(4 downto 0))));
      if we_i='1' then
        regfile(to_integer(unsigned(waddr_i(4 downto 0)))) <= wdata_i;
      end if;  
    end if;
    
  end process;


-- Read/write collision detection

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         wdata_reg<=wdata_i;
         if waddr_i(4 downto 0)=raddr1_i(4 downto 0) and we_i='1' then
            ram1_collision<='1';
         else
            ram1_collision<='0';
         end if;
         if waddr_i(4 downto 0)=raddr2_i(4 downto 0) and we_i='1' then
            ram2_collision<='1';
         else
            ram2_collision<='0';
         end if;
      end if;
   end process;

rdata1_o<=ram1_rdata when ram1_collision='0' else wdata_reg;
rdata2_o<=ram2_rdata when ram2_collision='0' else wdata_reg;

end rtl;

