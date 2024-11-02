---------------------------------------------------------------------
-- Interrupt multiplexer
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Manages LXP32 interrupts. Interrupts with lower numbers have
-- higher priority.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_interrupt_mux is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		irq_i: in std_logic_vector(7 downto 0);
		
		interrupt_valid_o: out std_logic;
		interrupt_vector_o: out std_logic_vector(2 downto 0);
		interrupt_ready_i: in std_logic;
		interrupt_return_i: in std_logic;

		wakeup_o: out std_logic;
		
		sp_waddr_i: in std_logic_vector(7 downto 0);
		sp_we_i: in std_logic;
		sp_wdata_i: in std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of lxp32_interrupt_mux is

signal irq: std_logic_vector(irq_i'range);
signal irq_reg: std_logic_vector(irq_i'range):=(others=>'0');

type state_type is (Ready,Requested,WaitForExit);
signal state: state_type:=Ready;

signal pending_interrupts: std_logic_vector(irq_i'range):=(others=>'0');

signal interrupt_valid: std_logic:='0';

signal interrupts_enabled: std_logic_vector(7 downto 0):=(others=>'0');
signal interrupts_wakeup: std_logic_vector(7 downto 0):=(others=>'0');
signal interrupts_level: std_logic_vector(7 downto 0):=(others=>'0');
signal interrupts_invert: std_logic_vector(7 downto 0):=(others=>'0');

begin

irq<=irq_i xor interrupts_invert;

-- Note: "disabled" interrupts (i.e. for which interrupts_enabled_i(i)='0')
-- are ignored completely, meaning that the interrupt handler won't be
-- called even if the interrupt is enabled later.

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			irq_reg<=(others=>'0');
			pending_interrupts<=(others=>'0');
			state<=Ready;
			interrupt_valid<='0';
			interrupt_vector_o<=(others=>'-');
			wakeup_o<='0';
		else
			irq_reg<=irq;
			
			pending_interrupts<=(pending_interrupts or 
				(irq and not irq_reg)) and
				interrupts_enabled and not interrupts_wakeup;
			
			case state is
			when Ready =>
				for i in irq'reverse_range loop -- lower interrupts have priority
					if (interrupts_level(i)='0' and pending_interrupts(i)='1') or (interrupts_level(i)='1' and irq(i)='1') then
						pending_interrupts(i)<='0';
						interrupt_valid<='1';
						interrupt_vector_o<=std_logic_vector(to_unsigned(i,3));
						state<=Requested;
						exit;
					end if;
				end loop;
			when Requested =>
				if interrupt_ready_i='1' then
					interrupt_valid<='0';
					state<=WaitForExit;
				end if;
			when WaitForExit =>
				if interrupt_return_i='1' then
					state<=Ready;
				end if;
			end case;

			if (irq and (not irq_reg) and interrupts_enabled and interrupts_wakeup)/=X"00" then
				wakeup_o<='1';
			else
				wakeup_o<='0';
			end if;
		end if;
	end if;
end process;

interrupt_valid_o<=interrupt_valid;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			interrupts_enabled<=(others=>'0');
			interrupts_wakeup<=(others=>'0');
			interrupts_level<=(others=>'0');
			interrupts_invert<=(others=>'0');
		elsif sp_we_i='1' and sp_waddr_i=X"FC" then
			interrupts_enabled<=sp_wdata_i(7 downto 0);
			interrupts_wakeup<=sp_wdata_i(15 downto 8);
			interrupts_level<=sp_wdata_i(23 downto 16);
			interrupts_invert<=sp_wdata_i(31 downto 24);
		end if;
	end if;
end process;

end architecture;
