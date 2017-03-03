----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    20:54:38 10/24/2016
-- Design Name:
-- Module Name:    riscv_control_unit - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--   Bonfire CPU 
--   (c) 2016,2017 Thomas Hornschuh
--   See license.md for License 
--   Control unit, implements the RISC-V CSR instruction and associated state registers
--   riscv instruction set decoder
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

use work.csr_def.all;


entity riscv_control_unit is
    generic
    (
       DIVIDER_EN: boolean;
       MUL_ARCH: string
    );
    Port ( op1_i : in  STD_LOGIC_VECTOR (31 downto 0);
           wdata_o : out  STD_LOGIC_VECTOR (31 downto 0);

           we_o : out  STD_LOGIC;
           csr_exception : out STD_LOGIC;
           csr_adr : in  STD_LOGIC_VECTOR (11 downto 0);
           ce_i : in STD_LOGIC;
           busy_o : out STD_LOGIC;
           csr_x0_i : in STD_LOGIC; -- should be set when rs field is x0
           csr_op_i : in  STD_LOGIC_VECTOR (1 downto 0);
           -- export CSR registers

           mtvec_o : out std_logic_vector(31 downto 2);
           mepc_o  : out std_logic_vector(31 downto 2);
           -- trap info import
           mcause_i : in STD_LOGIC_VECTOR (3 downto 0);
           mepc_i : in std_logic_vector(31 downto 2);
           adr_i  : in std_logic_vector(31 downto 0);
           mtrap_strobe_i : in STD_LOGIC; -- indicates that mcause_i, mepc_i and adr_i  should be registered
           cmd_tret_i : in STD_LOGIC; -- return command

           clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC);
end riscv_control_unit;

architecture Behavioral of riscv_control_unit is

signal csr_in, csr_out : STD_LOGIC_VECTOR (31 downto 0); -- Signals for CSR "ALU"
signal csr_offset : std_logic_vector(7 downto 0); -- lower 8 Bits of CSR address

signal busy : std_logic := '0';
signal we : std_logic :='0';
signal exception : std_logic :='0';


-- Local Control registers

signal mtvec : std_logic_vector(31 downto 2) := (others=>'0');
signal mscratch : std_logic_vector(31 downto 0) := (others=>'0');

-- trap info
signal mepc : std_logic_vector(31 downto 2) := (others=>'0');
signal mcause : std_logic_vector(3 downto 0) := (others=>'0');
signal mbadaddr : std_logic_vector(31 downto 0) := (others=>'0');

signal mie : std_logic := '0';  -- Interrupt Enable
signal mpie : std_logic :='0';  -- Previous Interrupt enable


begin

-- output wiring
we_o <= we;
busy_o<=we or exception;
csr_exception <= exception;
mtvec_o <= mtvec;
mepc_o <= mepc;

csr_offset <= csr_adr(7 downto 0);

--csr select mux
with csr_offset select
   csr_in <= get_mstatus(mpie,mie) when status,
             get_misa(DIVIDER_EN,MUL_ARCH) when isa,
             mtvec&"00" when tvec,
             mscratch   when scratch,
             X"0000000"&mcause when cause,
             mbadaddr when badaddr,
             mepc&"00" when epc,        
             impvers when impid,
             
             (others=>'0') when others;


csr_alu: process(op1_i,csr_in,csr_op_i)
begin
  case csr_op_i is
    when "01" => csr_out<=op1_i; -- CSRRW
    when "10" => csr_out <= csr_in or op1_i; --CSRRS
    when "11" => csr_out <= csr_in and (not op1_i); -- CSRRC
    when others => csr_out <= (others => 'X');
  end case;

end process;



process(clk_i)
variable l_exception : std_logic;
begin

   if rising_edge(clk_i) then
     if rst_i='1' then
         exception  <= '0';
         mtvec <=  (others=>'0');
         mepc <= (others=>'0');
         mcause <= (others=>'0');
         we <= '0';
         mie <= '0';
         mpie <= '0';
         
         --busy <= '0';
     else
        -- always deassert exception after one cycle
        if exception='1' then
           exception <= '0';
        end if;
        if we='1' then
          we <= '0';
        end if;
      
        if mtrap_strobe_i='1' then
          mcause <= mcause_i;
          mepc <= mepc_i;
          -- save IE and disable
          mpie <= mie;
          mie <= '0'; 
          case mcause_i is 
            when X"4"|X"6"|X"0" =>
              mbadaddr <= adr_i;
            when X"2"|X"3" =>
              mbadaddr <= mepc_i & "00";
            when others =>  
          end case;
          
        elsif cmd_tret_i='1' then
          mie<=mpie;
        end if;  
       
        if ce_i='1' then
         
          if csr_adr(11 downto 8)=m_stdprefix then
            l_exception:='0';
            case csr_adr(7 downto 0) is
              when status =>
                mie <= csr_out(3);
              when isa =>
                -- no register to write here...
              when tvec =>
                 mtvec<=csr_out(31 downto 2);
              when scratch =>
                 mscratch<=csr_out;
              when epc =>
                 mepc <= csr_out(31 downto 2);
              when cause =>
                 mcause <= csr_out(3 downto 0);
              when badaddr =>
                 mbadaddr <= csr_out;    
              when edeleg|ideleg=>
                -- currently read only              
              when others=>
                 l_exception:='1';
            end case;
          elsif csr_adr(11 downto 8) /= m_roprefix then
            l_exception:='1';
          else
            case csr_adr(7 downto 0) is
              when vendorid|marchid|impid|hartid => l_exception:='0';
              when others => l_exception:='1';  
            end case;              
          end if;
          if l_exception = '0'  then 
            wdata_o <= csr_in;
            we <= '1'; -- Pipeline control, latency one cycle
          else
            wdata_o <= (others => '0');
          end if;
          exception<=l_exception;
        end if;
       
      end if;
   end if;
end process;


end Behavioral;

