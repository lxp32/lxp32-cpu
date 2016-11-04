---------------------------------------------------------------------
-- Execution unit
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- The third stage of the LXP32 pipeline.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity lxp32_execute is
   generic(
      DBUS_RMW: boolean;
      DIVIDER_EN: boolean;
      MUL_ARCH: string;
      USE_RISCV : boolean := false
   );
   port(
      clk_i: in std_logic;
      rst_i: in std_logic;
      
      cmd_loadop3_i: in std_logic;
      cmd_signed_i: in std_logic;
      cmd_dbus_i: in std_logic;
      cmd_dbus_store_i: in std_logic;
      cmd_dbus_byte_i: in std_logic;
      cmd_dbus_hword_i : in std_logic; -- TH
      cmd_addsub_i: in std_logic;
      cmd_mul_i: in std_logic;
      cmd_div_i: in std_logic;
      cmd_div_mod_i: in std_logic;
      cmd_cmp_i: in std_logic;
      cmd_jump_i: in std_logic;
      cmd_negate_op2_i: in std_logic;
      cmd_and_i: in std_logic;
      cmd_xor_i: in std_logic;
      cmd_shift_i: in std_logic;
      cmd_shift_right_i: in std_logic;
      cmd_mul_high_i : in std_logic; -- TH: Get high word of mult result
      cmd_slt_i : in std_logic; -- TH: RISC-V SLT/SLTU command 
      
      -- Control Unit 
      cmd_csr_i : in std_logic;
      csr_x0_i : in STD_LOGIC; -- should be set when rs field is x0
      csr_op_i : in  STD_LOGIC_VECTOR (1 downto 0);
      
      cmd_trap_i : in STD_LOGIC; -- TH: Execute trap 
      cmd_tret_i : in STD_LOGIC; -- TH: return from trap 
      trap_cause_i : in STD_LOGIC_VECTOR(3 downto 0); -- TH: Trap/Interrupt cause
      interrupt_i : in STD_LOGIC; -- Trap is interrupt 
      epc_i : in  std_logic_vector(31 downto 2); 
      
      -- epc and tvec output to decode stage
      
      epc_o : out std_logic_vector(31 downto 2);
      tvec_o : out std_logic_vector(31 downto 2);
      
      jump_type_i: in std_logic_vector(3 downto 0);
      
      op1_i: in std_logic_vector(31 downto 0);
      op2_i: in std_logic_vector(31 downto 0);
      op3_i: in std_logic_vector(31 downto 0);
      dst_i: in std_logic_vector(7 downto 0);
      
      sp_waddr_o: out std_logic_vector(7 downto 0);
      sp_we_o: out std_logic;
      sp_wdata_o: out std_logic_vector(31 downto 0);
      
      displacement_i : in std_logic_vector(11 downto 0);
      
      valid_i: in std_logic;
      ready_o: out std_logic;
      
      dbus_cyc_o: out std_logic;
      dbus_stb_o: out std_logic;
      dbus_we_o: out std_logic;
      dbus_sel_o: out std_logic_vector(3 downto 0);
      dbus_ack_i: in std_logic;
      dbus_adr_o: out std_logic_vector(31 downto 2);
      dbus_dat_o: out std_logic_vector(31 downto 0);
      dbus_dat_i: in std_logic_vector(31 downto 0);
      
      jump_valid_o: out std_logic;
      jump_dst_o: out std_logic_vector(29 downto 0);
      jump_ready_i: in std_logic;
      
      interrupt_return_o: out std_logic
   );
end entity;

architecture rtl of lxp32_execute is

-- Pipeline control signals

signal busy: std_logic;
signal can_execute: std_logic;

-- ALU signals

signal alu_result: std_logic_vector(31 downto 0);
signal alu_we: std_logic;
signal alu_busy: std_logic;

signal alu_cmp_eq: std_logic;
signal alu_cmp_ug: std_logic;
signal alu_cmp_sg: std_logic;

-- OP3 loader signals

signal loadop3_we: std_logic;

-- Jump machine signals

signal jump_condition: std_logic;
signal jump_valid: std_logic:='0';
signal jump_dst, jump_dst_r: std_logic_vector(jump_dst_o'range);
signal cond_reg : std_logic_vector (2 downto 0);

-- SLT 
signal slt_we,slt_ce : std_logic;
signal slt_result : std_logic_vector(31 downto 0) := (others=>'0');
signal slt_busy : std_logic :='0';

-- Control unit
signal csr_we : std_logic := '0';
signal csr_ce,csr_exception : std_logic;
signal csr_busy : std_logic := '0';
signal csr_result :  std_logic_vector(31 downto 0);

signal mepc,mtvec :  std_logic_vector(31 downto 2);
signal mtrap_strobe : std_logic;


-- Target Address for load/store/jump

signal target_address : std_logic_vector(31 downto 0);

-- DBUS signals

signal dbus_result : std_logic_vector(31 downto 0);
signal dbus_busy: std_logic;
signal dbus_we: std_logic;

-- Result mux signals

signal result_mux: std_logic_vector(31 downto 0);
signal result_valid: std_logic;
signal result_regaddr: std_logic_vector(7 downto 0);

signal dst_reg: std_logic_vector(7 downto 0);

-- Signals related to interrupt handling

signal interrupt_return: std_logic:='0';

begin

tvec_o <= mtvec;
epc_o  <= mepc;

-- Pipeline control

busy<=alu_busy or dbus_busy or slt_busy or csr_busy;
ready_o<=not busy;
can_execute<=valid_i and not busy;

-- ALU

alu_inst: entity work.lxp32_alu(rtl)
   generic map(
      DIVIDER_EN=>DIVIDER_EN,
      MUL_ARCH=>MUL_ARCH
   )
   port map(
      clk_i=>clk_i,
      rst_i=>rst_i,
      
      valid_i=>can_execute,
      
      cmd_signed_i=>cmd_signed_i,
      cmd_addsub_i=>cmd_addsub_i,
      cmd_mul_i=>cmd_mul_i,
      cmd_div_i=>cmd_div_i,
      cmd_div_mod_i=>cmd_div_mod_i,
      cmd_cmp_i=>cmd_cmp_i,
      cmd_negate_op2_i=>cmd_negate_op2_i,
      cmd_and_i=>cmd_and_i,
      cmd_xor_i=>cmd_xor_i,
      cmd_shift_i=>cmd_shift_i,
      cmd_shift_right_i=>cmd_shift_right_i,
      cmd_mul_high_i=>cmd_mul_high_i,
      op1_i=>op1_i,
      op2_i=>op2_i,
      
      result_o=>alu_result,
      
      cmp_eq_o=>alu_cmp_eq,
      cmp_ug_o=>alu_cmp_ug,
      cmp_sg_o=>alu_cmp_sg,
      
      we_o=>alu_we,
      busy_o=>alu_busy
   );

-- OP3 loader

loadop3_we<=can_execute and cmd_loadop3_i;

-- Jump logic

lxp32jump: if not USE_RISCV  generate 
begin 
  jump_condition<=(not cmd_cmp_i) or (jump_type_i(3) and alu_cmp_eq) or
     (jump_type_i(2) and not alu_cmp_eq) or (jump_type_i(1) and alu_cmp_ug) or
     (jump_type_i(0) and alu_cmp_sg);
     
end generate;

riscvjump: if USE_RISCV generate
 
  process(cmd_cmp_i,jump_type_i,alu_cmp_eq,alu_cmp_ug,alu_cmp_sg) 
  variable c: std_logic;
  
  begin
    
      case cond_reg is
        when "000" => c:= alu_cmp_eq; -- BEQ
        when "001" => c:= not alu_cmp_eq; -- BNE
        when "100" => c:=  not alu_cmp_eq and not alu_cmp_sg; -- BLT
        when "101" => c:= alu_cmp_eq or alu_cmp_sg; -- BGE
        when "110" => c:= not alu_cmp_eq and not alu_cmp_ug; -- BLTU
        when "111" => c:= alu_cmp_eq or alu_cmp_ug; -- BGEU
        when others => c:= 'X'; -- dont care
      end case;  
      slt_result(0)<=c;
      if cmd_cmp_i = '0' then
        jump_condition<='1';
      else 
        jump_condition<=c;
      end if;    
    
  end process;  

end generate;

--SLT/SLTU command
-- will use the jump logic above. so for executing SLT(U) cmd_cmp_i and cmd_neg_op2_i together with cmd_slt_i should be set
-- jumptype must be set to 100 or 110 (see above)

slt_ce <=   cmd_slt_i and can_execute;

slt_ctrl: process(clk_i) begin
  if rising_edge(clk_i) then
     -- Write cond code register, will also be used for branches
     if cmd_cmp_i='1' then
       cond_reg <= jump_type_i(2 downto 0); --TH
     end if;
  
     -- ALU comparator results have a latency of one clock     
       slt_we <= slt_ce;
       if slt_we='1' or rst_i='1' then
         slt_busy<='0';
       elsif slt_ce='1' then
          slt_busy<='1';
       end if;          
  end if;   
end process;  
  
     
-- Displacement adder
-- is used for load/store but also as jump target 
process(op1_i,displacement_i) 
variable d : signed(displacement_i'length-1 downto 0);
begin
  d:=signed(displacement_i);
  target_address<=std_logic_vector(signed(op1_i)+resize(d,op1_i'length));
end process;

-- Jump Destination determination
--process(target_address,mtvec,mepc,cmd_tret_i,cmd_trap_i)
--begin
--   if cmd_tret_i = '1' then
--     jump_dst<=mepc;
--   elsif cmd_trap_i = '1' then
--     jump_dst<=mtvec;
--   else              
--     jump_dst<=target_address(31 downto 2);
--   end if; 
--end process;

jump_dst <= target_address(31 downto 2);

process (clk_i) is
begin
   if rising_edge(clk_i) then
      if rst_i='1' then
         jump_valid<='0';
         interrupt_return<='0';
         jump_dst_r<=(others=>'-');
      else
         if jump_valid='0' then    
            jump_dst_r <= jump_dst; -- latch jump destination 
            if can_execute='1' and cmd_jump_i='1' and jump_condition='1' then
               jump_valid<='1';
               if not USE_RISCV then interrupt_return<=op1_i(0); end if;
            end if;
         elsif jump_ready_i='1' then
            jump_valid<='0';
            interrupt_return<='0';
         end if;
      end if;
   end if;
end process;

jump_valid_o<=jump_valid or (can_execute and cmd_jump_i and jump_condition);
jump_dst_o<=jump_dst_r when jump_valid='1' else jump_dst;
  

interrupt_return_o<=interrupt_return;

-- DBUS access

dbus_inst: entity work.lxp32_dbus(rtl)
   generic map(
      RMW=>DBUS_RMW
   )
   port map(
      clk_i=>clk_i,
      rst_i=>rst_i,
      
      valid_i=>can_execute,
      
      cmd_dbus_i=>cmd_dbus_i,
      cmd_dbus_store_i=>cmd_dbus_store_i,
      cmd_dbus_byte_i=>cmd_dbus_byte_i,
      cmd_dbus_hword_i=>cmd_dbus_hword_i, -- TH
      cmd_signed_i=>cmd_signed_i,
      addr_i=>target_address,
      wdata_i=>op2_i,
      
      rdata_o=>dbus_result,
      busy_o=>dbus_busy,
      we_o=>dbus_we,
      
      dbus_cyc_o=>dbus_cyc_o,
      dbus_stb_o=>dbus_stb_o,
      dbus_we_o=>dbus_we_o,
      dbus_sel_o=>dbus_sel_o,
      dbus_ack_i=>dbus_ack_i,
      dbus_adr_o=>dbus_adr_o,
      dbus_dat_o=>dbus_dat_o,
      dbus_dat_i=>dbus_dat_i
   );


-- RISCV control unit

riscv_cu: if USE_RISCV  generate

   csr_ce <= cmd_csr_i and can_execute;
   mtrap_strobe <= cmd_trap_i and can_execute;
   
   
   csr_inst: entity work.riscv_control_unit PORT MAP(
		op1_i => op1_i,
		wdata_o => csr_result,
		we_o => csr_we ,
		csr_exception =>csr_exception ,
		csr_adr => displacement_i,
		ce_i => csr_ce,
		busy_o => csr_busy,
		csr_x0_i => csr_x0_i,
		csr_op_i => csr_op_i,
		clk_i => clk_i ,
		rst_i => rst_i,
      
      mtvec_o => mtvec,
      mepc_o  => mepc,
      
      mcause_i => trap_cause_i,
      mepc_i => epc_i,
      mtrap_strobe_i => mtrap_strobe
	);

end generate;




-- Result multiplexer

result_mux_gen: for i in result_mux'range generate
   result_mux(i)<=(alu_result(i) and alu_we) or
      (op3_i(i) and loadop3_we) or
      (dbus_result(i) and dbus_we) or 
      (csr_result(i) and csr_we) or 
      (slt_result(i) and slt_we);
end generate;

result_valid<=alu_we or loadop3_we or dbus_we or slt_we or csr_we;

-- Write destination register


process (clk_i) is
begin
   if rising_edge(clk_i) then
      if can_execute='1' then
         dst_reg<=dst_i;
         
      end if;
   end if;
end process;

result_regaddr<=dst_i when can_execute='1' else dst_reg;

sp_we_o<=result_valid;
sp_waddr_o<=result_regaddr;
sp_wdata_o<=result_mux;

end architecture;
