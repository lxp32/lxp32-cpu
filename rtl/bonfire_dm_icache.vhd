----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:05 01/30/2017 
-- Design Name: 
-- Module Name:    bonfire_dm_icache - Behavioral 
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

use work.log2;

entity bonfire_dm_icache is

generic (
  LINE_SIZE : natural :=8; -- Line size in 32 Bit words
  CACHE_SIZE : natural :=2048; -- Cache Size in 32 Bit words
  ADDRESS_BITS : natural := 30  -- Number of bits of chacheable address range
);
port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		lli_re_i: in std_logic;
		lli_adr_i: in std_logic_vector(29 downto 0);
		lli_dat_o: out std_logic_vector(31 downto 0);
		lli_busy_o: out std_logic;
		
		wbm_cyc_o: out std_logic;
		wbm_stb_o: out std_logic;
		wbm_cti_o: out std_logic_vector(2 downto 0);
		wbm_bte_o: out std_logic_vector(1 downto 0);
		wbm_ack_i: in std_logic;
		wbm_adr_o: out std_logic_vector(29 downto 0);
		wbm_dat_i: in std_logic_vector(31 downto 0);
      
      dbus_cyc_snoop_i : std_logic -- TH
	);


end bonfire_dm_icache;

architecture Behavioral of bonfire_dm_icache is

constant CL_BITS : natural :=log2.log2(LINE_SIZE); -- Bits for cache line
constant CACHE_ADR_BITS : natural := log2.log2(CACHE_SIZE); -- total adress bits for cache
constant LINE_SELECT_ADR_BITS : natural := CACHE_ADR_BITS-CL_BITS; -- adr bits for selecting a cache line
constant TAG_RAM_SIZE : natural := log2.power2(LINE_SELECT_ADR_BITS); -- the Tag RAM size is defined by the size of line select address
constant TAG_RAM_BITS: natural := ADDRESS_BITS-CACHE_ADR_BITS; -- the Tag RAM needs to compare all remaining address bits
constant TAG_RAM_WIDTH : natural := TAG_RAM_BITS+1;  -- The Tag RAM will also contain a valid bit in is upper position

constant LINE_MAX : std_logic_vector(CL_BITS downto 0) := (others=>'1');

subtype t_tag_value is unsigned(TAG_RAM_BITS-1 downto 0);

type t_tag_data is record
   valid : std_logic;
   address : t_tag_value;
end record;
type t_tag_ram is array (0 to TAG_RAM_SIZE-1) of std_logic_vector(TAG_RAM_WIDTH-1 downto 0);
type t_cache_ram is array (0 to CACHE_SIZE-1) of std_logic_vector(31 downto 0);

signal tag_value : t_tag_value;
signal tag_index : unsigned(LINE_SELECT_ADR_BITS-1 downto 0); -- Offset into TAG RAM

signal tag_ram : t_tag_ram := (others => (others=> '0')) ;
signal cache_ram : t_cache_ram;

signal adr :  std_logic_vector(29 downto 0);

signal tag_buffer : t_tag_data; -- last buffered tag value
signal buffer_index : unsigned(LINE_SELECT_ADR_BITS-1 downto 0); -- index of last buffered tag value

signal hit,miss : std_logic;

signal read_address : std_logic_vector(29 downto 0);

signal wb_enable : std_logic;

signal burst_counter : unsigned(CL_BITS-1 downto 0);

type t_wb_state is (wb_idle,wb_burst,wb_finish);

signal wb_state : t_wb_state;


begin
  lli_busy_o<= not hit;

  wbm_adr_o<=read_address;
  wbm_cyc_o<=wb_enable;
  wbm_stb_o<=wb_enable;
  wbm_bte_o<="00";
  wbm_adr_o<=adr(adr'high downto CL_BITS) & std_logic_vector(burst_counter);
  
  adr <= lli_adr_i;  
  
 
  tag_value <= unsigned(adr(adr'high downto adr'high-TAG_RAM_BITS+1));
--  tag_index <= unsigned(adr(adr'high-TAG_RAM_BITS-1 downto adr'high-TAG_RAM_BITS-1-LINE_SELECT_ADR_BITS)); 
  tag_index <= unsigned(adr(LINE_SELECT_ADR_BITS+CL_BITS-1 downto CL_BITS));
  
  
  check_hitmiss : process(adr,tag_value,tag_buffer) 
  variable index_match,tag_match : boolean;
  
  begin
    index_match:=buffer_index = tag_index;
    tag_match:=tag_buffer.valid='1' and tag_buffer.address=tag_value;
    
    if  index_match and tag_match then 
      hit<='1';
    else
      hit<='0';
    end if;
    
    -- A miss only occurs when the tag buffer contains data for the right index but
    -- the tag itself does not match
    if index_match and not tag_match then
      miss<='1';
    else
      miss<='0';
    end if;      
  end process;
  
  
  proc_tag_ram:process(clk_i) 
  
  variable rd,wd : std_logic_vector(TAG_RAM_WIDTH-1 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i='1' then
       tag_buffer<= ('0',others=>to_unsigned(0,t_tag_value'length));
      else  
         -- read tag RAM into buffer
         if hit='0' and lli_re_i='1' then 
           
           rd:=tag_ram(to_integer(tag_index));
           
           tag_buffer.valid<=rd(rd'high);           
           tag_buffer.address<= unsigned(rd(TAG_RAM_BITS-1 downto 0));
           buffer_index<=tag_index;
         end if;  
         
         if wb_state=wb_finish then 
           wd(wd'high):='1';
           wd(TAG_RAM_BITS-1 downto 0):=std_logic_vector(tag_value);
           tag_ram(to_integer(tag_index))<=wd;
         end if;  
      end if;
    end if;
  
  end process;
  
  
  
  proc_cache_ram: process(clk_i) begin
  
    if rising_edge(clk_i) then
      -- in case of hit read cache
      if hit='1' and lli_re_i='1' then
        lli_dat_o <= cache_ram(to_integer(unsigned(adr(CACHE_ADR_BITS-1 downto 0))));
      end if;  
      -- read data from Wisbone bus into Cache RAM on ACK 
      if wbm_ack_i='1' and wb_enable='1' then
        cache_ram(to_integer(unsigned(read_address(CACHE_ADR_BITS-1 downto 0))))<=wbm_dat_i;
      end if;    
    end if;
  end process;
  
  
  proc_wb_read: process(clk_i) 
  variable n : unsigned(burst_counter'high downto 0);
  begin  
     if rising_edge(clk_i) then
       if rst_i='1' then 
         wb_enable<='0';
         wb_state<=wb_idle;
         burst_counter<=to_unsigned(0,burst_counter'length);
       else
         case wb_state is
           when wb_idle =>
             if miss='1' then
               wb_enable<='1';
               wbm_cti_o<="010";
               burst_counter<=to_unsigned(0,burst_counter'length);
               wb_state<=wb_burst;
             end if;
           when wb_burst =>
             n:=burst_counter+1;
             if std_logic_vector(n)=LINE_MAX then 
               wbm_cti_o<="111";
               wb_state<=wb_finish;
             end if;
             burst_counter<=n;             
           when wb_finish=>
              wb_state<= wb_idle;
         end case;               
       end if;  
     end if;
  end process;
  
end Behavioral;
