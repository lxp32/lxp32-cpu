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

type SourceSelect  is (Undef,Reg,Imm,Base); -- Source selector Register, Immediate, Base+Immediate

signal rd1_select: SourceSelect;
signal rd1_direct: std_logic_vector(31 downto 0);
signal rd2_select: SourceSelect;
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
			rd1_select<=Undef;
			rd1_direct<=(others=>'-');
			rd2_select<=Undef;
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

				   if opcode=OP_IMM or opcode=OP_OP then 
					  rd1_select<=Reg;
					  dst_out<="000"&rd;
					  if opcode(5)='1' then -- OP_OP...
					    rd2_select<=Reg;						 		
					  else --OP_IMM
					    rd2_direct<=std_logic_vector(get_I_immediate(word_i));
					    rd2_select<=Imm;
					  end if;	
					
					  case funct3 is 
					    when ADD =>
						   cmd_addsub_o<='1';							
							if opcode(5)='1' then
                       cmd_negate_op2_o<=word_i(30);
							end if;  
						 when F_AND =>
                     cmd_and_o<='1';
                   when F_XOR =>							
							cmd_xor_o<='1';
						 when F_OR =>	
							cmd_and_o<='1';
							cmd_xor_o<='1';
						 when SL  =>
                     cmd_shift_o<='1';
                   when SR => 
						   cmd_shift_o<='1';
							cmd_shift_right_o<='1';
						   cmd_signed_o<=word_i(30);						
						 when others => 	
					  end case;
					  valid_out<='1';
					elsif opcode=OP_JAL then
                  rd1_select<=Imm;
                  rd1_direct<=std_logic_vector(signed(current_ip&"00")+get_UJ_immediate(word_i));
                  cmd_jump_o<='1';			
                  jump_type_o<="0000";		
                  valid_out<='1';	
               elsif opcode=OP_LOAD  then
                  rd1_select<=Base;
                  rd1_direct<=std_logic_vector(get_I_immediate(word_i));
						cmd_dbus_o<='1';
						dst_out<="000"&rd;
						if funct3(1 downto 0)="00" then -- Byte access
						  cmd_dbus_byte_o<='1';
						end if; -- TODO: Implement 16 BIT (H) instructons
                  cmd_signed_o <= not funct3(2); 	
                  valid_out<='1';						
               elsif opcode=OP_STORE then
                  rd1_select<=Base;
                	rd1_direct<=std_logic_vector(get_S_immediate(word_i));
                  rd2_select<=Reg;						
                  cmd_dbus_o<='1';	
                  cmd_dbus_store_o<='1';	
                  if funct3(1 downto 0)="00" then -- Byte access
						  cmd_dbus_byte_o<='1';
						end if; -- TODO: Implement 16 BIT (H) instructons		
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


--Operand 1 multiplexer
process(rd1_direct,rd1_select,sp_rdata1_i,rd1_reg) is
variable rdata : std_logic_vector(31 downto 0);
begin
  if rd1_reg = X"00" then -- Register x0 is contant zero 
    rdata:=X"00000000";
  else
    rdata:=sp_rdata1_i;
  end if;	 
  
  case rd1_select is 
    when Imm =>
      op1_o<= rd1_direct; -- Imediate operand 
	 when Base =>
      op1_o <= std_logic_vector(signed(rdata)+signed(rd1_direct)); -- Base + Offset
    when Reg =>		
        op1_o<=rdata;
	 when Undef =>
	   op1_o <= (others=> 'X'); -- don't care...
  end case;
end process;  

            
--operand 2 multiplexer
process(rd2_direct,rd2_select,sp_rdata2_i,rd2_reg) is
begin
  if rd2_select=Imm then
    op2_o<= rd2_direct;
  else 
    if rd2_reg = X"00" then
   	op2_o<=X"00000000";
	 else
      op2_o<=sp_rdata2_i;
    end if;
  end if;
end process;  

  
end rtl;

