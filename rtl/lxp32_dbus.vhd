---------------------------------------------------------------------
-- DBUS master
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Manages data bus (DBUS) access.

-- Extension TH 22.10.2016:
-- Support for hword (16 Bit) Bus Access analogous to byte access
-- needed to implement lhu/lh/shu/sh RISC-V instructions.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_dbus is
	generic(
		RMW: boolean
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		valid_i: in std_logic;
		
		cmd_dbus_i: in std_logic;
		cmd_dbus_store_i: in std_logic;
		cmd_dbus_byte_i: in std_logic;
      cmd_dbus_hword_i : in std_logic; -- TH: half word (16Bit) access
		cmd_signed_i: in std_logic;
		addr_i: in std_logic_vector(31 downto 0);
		wdata_i: in std_logic_vector(31 downto 0);
      		
		rdata_o: out std_logic_vector(31 downto 0);
		we_o: out std_logic;
		busy_o: out std_logic;
		
		dbus_cyc_o: out std_logic;
		dbus_stb_o: out std_logic;
		dbus_we_o: out std_logic;
		dbus_sel_o: out std_logic_vector(3 downto 0);
		dbus_ack_i: in std_logic;
		dbus_adr_o: out std_logic_vector(31 downto 2);
		dbus_dat_o: out std_logic_vector(31 downto 0);
		dbus_dat_i: in std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of lxp32_dbus is

signal strobe: std_logic:='0';
signal we_out: std_logic:='0';
signal we: std_logic;
signal byte_mode,hword_mode: std_logic;
signal sel: std_logic_vector(3 downto 0);
signal sig: std_logic;
signal rmw_mode: std_logic;
signal adr_reg : std_logic_vector(1 downto 0); -- TH: Lower two bits of address bus

signal dbus_rdata: std_logic_vector(31 downto 0);
signal selected_byte: std_logic_vector(7 downto 0);

begin

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			we_out<='0';
			strobe<='0';
			sig<='-';
			byte_mode<='-';
			sel<=(others=>'-');
			we<='-';
			rmw_mode<='-';
			dbus_adr_o<=(others=>'-');
			dbus_dat_o<=(others=>'-');
		else
			we_out<='0';
			if strobe='0' then
				if valid_i='1' and cmd_dbus_i='1' then
					strobe<='1';
					sig<=cmd_signed_i;					
					
					dbus_adr_o<=addr_i(31 downto 2);
               adr_reg<=addr_i(1 downto 0);
               
               if cmd_dbus_byte_i='1' then
                 byte_mode<='1';
                 hword_mode<='0';
						dbus_dat_o<=wdata_i(7 downto 0)&wdata_i(7 downto 0)&
							wdata_i(7 downto 0)&wdata_i(7 downto 0);
						
						case addr_i(1 downto 0) is
						when "00" => sel<="0001";
						when "01" => sel<="0010";
						when "10" => sel<="0100";
						when "11" => sel<="1000";
						when others =>
						end case;
               elsif cmd_dbus_hword_i='1' then   
                 byte_mode<='0';
                 hword_mode<='1';
                 dbus_dat_o<=wdata_i(15 downto 0)&wdata_i(15 downto 0);
                 -- synthesis translate_off
						assert addr_i(0)='0'
							report "Misaligned word-granular access on data bus"
							severity warning;
						-- synthesis translate_on                 
                  if addr_i(1)='0' then
                    sel<="0011";
                  else
                    sel<="1100";
                  end if;                    
					
					else -- word mode 
						byte_mode<='0';
                  hword_mode<='0';
						dbus_dat_o<=wdata_i;
						sel<="1111";
						
						-- synthesis translate_off
						assert addr_i(1 downto 0)="00"
							report "Misaligned word-granular access on data bus"
							severity warning;
						-- synthesis translate_on
					end if;
						
					
					if not RMW then
						we<=cmd_dbus_store_i;
						rmw_mode<='0';
					else
						we<=cmd_dbus_store_i and not (cmd_dbus_byte_i or cmd_dbus_hword_i);
						rmw_mode<=cmd_dbus_store_i and (cmd_dbus_byte_i or cmd_dbus_hword_i);
					end if;
				end if;
			else
				if dbus_ack_i='1' then
					if rmw_mode='1' and we='0' and RMW then
						we<='1';
						for i in sel'range loop
							if sel(i)='0' then
								dbus_dat_o(i*8+7 downto i*8)<=
									dbus_dat_i(i*8+7 downto i*8);
							end if;
						end loop;
					else
						strobe<='0';
						if we='0' then
							we_out<='1';
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

dbus_cyc_o<=strobe;
dbus_stb_o<=strobe;
dbus_we_o<=we;

sel_no_rmw_gen: if not RMW generate
	dbus_sel_o<=sel;
end generate;

sel_rmw_gen: if RMW generate
	dbus_sel_o<=(others=>'1');
end generate;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		dbus_rdata<=dbus_dat_i;
	end if;
end process;

-- TH: New mux coding...
rdata_mux: process(dbus_rdata,sel,byte_mode,hword_mode,sig,adr_reg)
variable byte : std_logic_vector(7 downto 0);
variable hword : std_logic_vector(15 downto 0);
begin
  if byte_mode='1' then
    case adr_reg is 
      when "00" =>  byte:=dbus_rdata(7 downto 0);
      when "01" =>  byte:=dbus_rdata(15 downto 8);
      when "10" =>  byte:=dbus_rdata(23 downto 16);
      when "11" =>  byte:=dbus_rdata(31 downto 24);
      when others => byte:=(others=> 'X');
    end case;
    if sig='0' or byte(7)='0' then    
      rdata_o<=X"000000"&byte;
    else
      rdata_o<=X"FFFFFF"&byte;    
    end if;
  elsif hword_mode='1' then 
    case adr_reg(1) is
      when '0' => hword:=dbus_rdata(15 downto 0);
      when '1' => hword:=dbus_rdata(31 downto 16);
      when others => hword:=(others => 'X');
    end case;
    if sig='0' or hword(15)='0' then    
      rdata_o<=X"0000"&hword;
    else
      rdata_o<=X"FFFF"&hword;    
    end if;
  else   
    rdata_o<=dbus_rdata;
  end if;  
end process;

we_o<=we_out;
busy_o<=strobe or we_out;

end architecture;
