---------------------------------------------------------------------
-- Generic FPGA memory block
--
-- Copyright (c) 2015 by Alex I. Kuznetsov
--
-- Portable description of a dual-port memory block with one write
-- port.
--
-- Parameters:
--     * DATA_WIDTH:  data port width
--     * ADDR_WIDTH:  address port width
--     * SIZE:        memory size
--     * MODE:        read/write synchronization mode for port A
--                      DONTCARE: choose the most efficient design
--                      WR_FIRST: feed written value to the output
--                      RD_FIRST: read old value 
--                      NOCHANGE: don't change output during write
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_dpram is
	generic(
		DATA_WIDTH: integer;
		ADDR_WIDTH: integer;
		SIZE: integer;
		MODE: string:="DONTCARE"
	);
	port(
		clka_i: in std_logic;
		cea_i: in std_logic;
		wea_i: in std_logic;
		addra_i: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		da_i: in std_logic_vector(DATA_WIDTH-1 downto 0);
		da_o: out std_logic_vector(DATA_WIDTH-1 downto 0);
		
		clkb_i: in std_logic;
		ceb_i: in std_logic;
		addrb_i: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		db_o: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of generic_dpram is

type ram_type is array(SIZE-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal ram: ram_type;

attribute syn_ramstyle: string;
attribute syn_ramstyle of ram: signal is "no_rw_check";
attribute ram_style: string; -- for Xilinx
attribute ram_style of ram: signal is "block";

begin

-- Ensure that generics have valid values

assert SIZE<=2**ADDR_WIDTH
	report "SIZE must be less or equal than 2^ADDR_WIDTH"
	severity failure;

assert MODE="DONTCARE" or MODE="WR_FIRST" or MODE="RD_FIRST" or MODE="NOCHANGE"
	report "Unrecognized MODE value (DONTCARE, WR_FIRST, RD_FIRST or NOCHANGE expected)"
	severity failure;

-- Port A (read/write)

port_a_dont_care_gen: if MODE="DONTCARE" generate
	process (clka_i) is
	begin
		if rising_edge(clka_i) then
			if cea_i='1' then
				if wea_i='1' then
					ram(to_integer(unsigned(addra_i)))<=da_i;
					da_o<=(others=>'-');
				else
					if is_x(addra_i) then
						da_o<=(others=>'X');
					else
						da_o<=ram(to_integer(unsigned(addra_i)));
					end if;
				end if;
			end if;
		end if;
	end process;
end generate;

port_a_write_first_gen: if MODE="WR_FIRST" generate
	process (clka_i) is
	begin
		if rising_edge(clka_i) then
			if cea_i='1' then
				if wea_i='1' then
					ram(to_integer(unsigned(addra_i)))<=da_i;
					da_o<=da_i;
				else
					if is_x(addra_i) then
						da_o<=(others=>'X');
					else
						da_o<=ram(to_integer(unsigned(addra_i)));
					end if;
				end if;
			end if;
		end if;
	end process;
end generate;

port_a_read_first_gen: if MODE="RD_FIRST" generate
	process (clka_i) is
	begin
		if rising_edge(clka_i) then
			if cea_i='1' then
				if wea_i='1' then
					ram(to_integer(unsigned(addra_i)))<=da_i;
				end if;
				if is_x(addra_i) then
					da_o<=(others=>'X');
				else
					da_o<=ram(to_integer(unsigned(addra_i)));
				end if;
			end if;
		end if;
	end process;
end generate;

port_a_no_change_gen: if MODE="NOCHANGE" generate
	process (clka_i) is
	begin
		if rising_edge(clka_i) then
			if cea_i='1' then
				if wea_i='1' then
					ram(to_integer(unsigned(addra_i)))<=da_i;
				else
					if is_x(addra_i) then
						da_o<=(others=>'X');
					else
						da_o<=ram(to_integer(unsigned(addra_i)));
					end if;
				end if;
			end if;
		end if;
	end process;
end generate;

-- Port B (read only)

process (clkb_i) is
begin
	if rising_edge(clkb_i) then
		if ceb_i='1' then
			if is_x(addrb_i) then
				db_o<=(others=>'X');
			else
				db_o<=ram(to_integer(unsigned(addrb_i)));
			end if;
		end if;
	end if;
end process;

end architecture;
