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
--
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
           mtrap_strobe_i : in STD_LOGIC; -- indicates that mcause_i and mepc_i should be registered

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
   csr_in <= mtvec&"00" when tvec,
             mscratch   when scratch,
             X"0000000"&mcause when cause,
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
         --busy <= '0';
     else
        -- always deassert exception after one cycle
        if exception='1' then
           exception <= '0';
        end if;
        if we='1' then
          we <= '0';
        end if;
        -- mtrap_strobe_i has precedence over ce_i.
        -- When both signals are asserted in the same clock cycle, the CSR processing
        -- will be delayed by one cycle
        -- execution control must ensure that no data hazzards are created.
        if mtrap_strobe_i='1' then
          mcause <= mcause_i;
          mepc <= mepc_i;
        else
           if ce_i='1' then
             l_exception:='0';
             if csr_adr(11 downto 8)=m_stdprefix then
               case csr_adr(7 downto 0) is
                 when tvec =>
                    mtvec<=csr_out(31 downto 2);
                 when scratch =>
                    mscratch<=csr_out;
                 when epc =>
                    mepc <= csr_out(31 downto 2);
                 when cause =>
                    mcause <= csr_out(3 downto 0);
                 when others=>
                   l_exception:='1';
               end case;
             elsif csr_adr(11 downto 8) /= m_roprefix then
               l_exception:='1';
             end if;
             if l_exception = '0'  then -- and csr_x0_i='0'
               wdata_o <= csr_in;
               we <= '1'; -- Pipeline control, latency one cycle
             else
               wdata_o <= (others => '0');
             end if;
             exception<=l_exception;
           end if;
        end if;
      end if;
   end if;
end process;



end Behavioral;

