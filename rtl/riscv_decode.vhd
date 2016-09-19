----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:56:47 09/18/2016 
-- Design Name: 
-- Module Name:    riscv_decode - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--   riscv instruction set decoder for lxp32 processor
--   (c) 2016 Thomas Hornschuh
--   Second stage of lxp32 pipeline. Designed as "plug-in" replacement for the lxp32 orginal deocoder 

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


use work.riscv_decodeutil.all;

entity riscv_decode is
port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		word_i: in std_logic_vector(31 downto 0); -- actual instruction to decode
		next_ip_i: in std_logic_vector(29 downto 0); -- ip (PC) of next instruction 
		valid_i: in std_logic;  -- input valid
		jump_valid_i: in std_logic;
		ready_o: out std_logic;  -- decode stage ready to decode next instruction 
		
		interrupt_valid_i: in std_logic;
		interrupt_vector_i: in std_logic_vector(2 downto 0);
		interrupt_ready_o: out std_logic;
		
		sp_raddr1_o: out std_logic_vector(7 downto 0);
		sp_rdata1_i: in std_logic_vector(31 downto 0);
		sp_raddr2_o: out std_logic_vector(7 downto 0);
		sp_rdata2_i: in std_logic_vector(31 downto 0);
		
		ready_i: in std_logic; -- ready signal from execute stage
		valid_o: out std_logic; -- output status valid 
		
		cmd_loadop3_o: out std_logic;
		cmd_signed_o: out std_logic;
		cmd_dbus_o: out std_logic;
		cmd_dbus_store_o: out std_logic;
		cmd_dbus_byte_o: out std_logic;
		cmd_addsub_o: out std_logic;
		cmd_mul_o: out std_logic;
		cmd_div_o: out std_logic;
		cmd_div_mod_o: out std_logic;
		cmd_cmp_o: out std_logic;
		cmd_jump_o: out std_logic;
		cmd_negate_op2_o: out std_logic;
		cmd_and_o: out std_logic;
		cmd_xor_o: out std_logic;
		cmd_shift_o: out std_logic;
		cmd_shift_right_o: out std_logic;
		
		jump_type_o: out std_logic_vector(3 downto 0);
		
		op1_o: out std_logic_vector(31 downto 0);
		op2_o: out std_logic_vector(31 downto 0);
		op3_o: out std_logic_vector(31 downto 0);
		dst_o: out std_logic_vector(7 downto 0)
	);
end riscv_decode;

architecture rtl of riscv_decode is

-- RISCV instruction fields
signal opcode : t_opcode;
signal rd, rs1, rs2 : std_logic_vector(4 downto 0);
signal funct3 : t_funct3;
signal funct7 : std_logic_vector(6 downto 0);

signal current_ip: unsigned(next_ip_i'range);

-- Signals related to pipeline control

signal downstream_busy: std_logic;
signal self_busy: std_logic:='0';
signal busy: std_logic;
signal valid_out: std_logic:='0';

-- Signals related to interrupt handling

signal interrupt_ready: std_logic:='0';

-- Signals related to RD operand decoding

signal rd1,rd1_reg: std_logic_vector(7 downto 0);
signal rd2,rd2_reg: std_logic_vector(7 downto 0);

signal rd1_select: std_logic;
signal rd1_direct: std_logic_vector(31 downto 0);
signal rd2_select: std_logic;
signal rd2_direct: std_logic_vector(31 downto 0);


signal dst_out,radr1_out,radr2_out : std_logic_vector(7 downto 0);

-- Decoder FSM state

type DecoderState is (Regular,Halt);
signal state: DecoderState:=Regular;


begin

 -- extract instruction fields
   opcode<=word_i(6 downto 0);
	rd<=word_i(11 downto 7);
	funct3<=word_i(14 downto 12);
	rs1<=word_i(19 downto 15);
	rs2<=word_i(24 downto 20);
	funct7<=word_i(31 downto 25);
	
	-- decode Register addresses 
	rd1<="000"&rs1; 
	rd2<="000"&rs2; 
	
-- Pipeline control

   downstream_busy<=valid_out and not ready_i;
   busy<=downstream_busy or self_busy;
   current_ip<=unsigned(next_ip_i)-1;

-- Control outputs 	
	valid_o<=valid_out;
   dst_o<=dst_out;
   ready_o<=not busy;
   interrupt_ready_o<=interrupt_ready;
	

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			valid_out<='0';
			self_busy<='0';
			state<=Regular;
			interrupt_ready<='0';
			cmd_loadop3_o<='-';
			cmd_signed_o<='-';
			cmd_dbus_o<='-';
			cmd_dbus_store_o<='-';
			cmd_dbus_byte_o<='-';
			cmd_addsub_o<='-';
			cmd_negate_op2_o<='-';
			cmd_mul_o<='-';
			cmd_div_o<='-';
			cmd_div_mod_o<='-';
			cmd_cmp_o<='-';
			cmd_jump_o<='-';
			cmd_and_o<='-';
			cmd_xor_o<='-';
			cmd_shift_o<='-';
			cmd_shift_right_o<='-';
			rd1_select<='-';
			rd1_direct<=(others=>'-');
			rd2_select<='-';
			rd2_direct<=(others=>'-');
			op3_o<=(others=>'-');
			jump_type_o<=(others=>'-');
			dst_out<=(others=>'-');
		else
		  if jump_valid_i='1' then
		      -- When exeuction stage exeuctes jump do nothing
				valid_out<='0';
				self_busy<='0';
				state<=Regular;  
		  elsif downstream_busy='0' then 
		    case state is 
			   when Regular =>
				   cmd_loadop3_o<='0';
					cmd_signed_o<='0';
					cmd_dbus_o<='0';
					cmd_dbus_store_o<='0';
					cmd_dbus_byte_o<='0';
					cmd_addsub_o<='0';
					cmd_negate_op2_o<='0';
					cmd_mul_o<='0';
					cmd_div_o<='0';
					cmd_div_mod_o<='0';
					cmd_cmp_o<='0';
					cmd_jump_o<='0';
					cmd_and_o<='0';
					cmd_xor_o<='0';
					cmd_shift_o<='0';
					cmd_shift_right_o<='0';

				   if opcode=OP_IMM then 
					 
					  rd1_select<='1';
					  rd2_direct<=std_logic_vector(get_I_immediate(word_i));
					  rd2_select<='0';
					  dst_out<="000"&rd;
					  case funct3 is 
					    when ADDI =>
						   cmd_addsub_o<='1';
							cmd_negate_op2_o<='0';
						 when ANDI =>
                     cmd_and_o<='1';
                   when XORI =>							
							cmd_xor_o<='1';
						 when ORI =>	
							cmd_and_o<='1';
							cmd_xor_o<='1';
						 when others => 	
					  end case;
					  valid_out<='1';
					elsif opcode=OP_JAL then
                  rd1_select<='0';
                  rd1_direct<=std_logic_vector(signed(current_ip&"00")+get_UJ_immediate(word_i));
                  cmd_jump_o<='1';			
                  jump_type_o<="0000";		
                  valid_out<='1';						
				   end if;
				
				when Halt =>
					if interrupt_valid_i='1' then
						self_busy<='0';
						state<=Regular;
					end if;
			  end case;
		  end if; 
		end if;   
    end if;		
end process;


-- Operand handling 

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if busy='0' then
			rd1_reg<=rd1;
			rd2_reg<=rd2;
		end if;
	end if;
end process;

radr1_out<= rd1_reg when busy='1' else 	rd1;
sp_raddr1_o <= radr1_out;

radr2_out<=rd2_reg when busy='1' else rd2;
sp_raddr2_o <= radr2_out;

process(rd1_direct,rd1_select,sp_rdata1_i,radr1_out) is
begin
  if rd1_select='0' then
    op1_o<= rd1_direct;
  else 
    if radr1_out = X"00" then
   	op1_o<=X"00000000";
	 else
      op1_o<=sp_rdata1_i;
    end if;
  end if;
end process;  

--op1_o<=  rd1_direct when rd1_select='0' else 
--         sp_rdata1_i when rd1_select='1' and not radr1_out=X"00"  else
--         X"00000000" when rd1_select='1' and radr1_out=X"00"; -- r0 is constant zero in RISCV               

process(rd2_direct,rd2_select,sp_rdata2_i,radr2_out) is
begin
  if rd2_select='0' then
    op2_o<= rd2_direct;
  else 
    if radr2_out = X"00" then
   	op2_o<=X"00000000";
	 else
      op2_o<=sp_rdata2_i;
    end if;
  end if;
end process;  

		   
--						 
--op2_o<=  rd2_direct when rd2_select='0' else 
--         sp_rdata2_i when rd2_select='1' and not radr2_out=X"00"  else 
--         X"00000000" when rd2_select='1' and radr2_out=X"00";  -- r0 is constant zero in RISCV     
        




end rtl;

