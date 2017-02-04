-- Memory module to be synthesized as block RAM
-- can be initalized with a file 

-- New "single process" version as recommended by Xilinx XST user guide


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library STD;
use STD.textio.all;



entity sim_MainMemory is
    generic (RamFileName : string := "meminit.ram";
	          mode : string := "B";
              ADDR_WIDTH: integer;
              SIZE : integer;
              EnableSecondPort : boolean := true -- enable inference of the second port 
            );
    Port ( DBOut : out  STD_LOGIC_VECTOR (31 downto 0);
           DBIn : in  STD_LOGIC_VECTOR (31 downto 0);
           AdrBus : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
           ENA : in  STD_LOGIC;
           WREN : in  STD_LOGIC_VECTOR (3 downto 0);        
              CLK : in  STD_LOGIC;
	   -- Second Port ( read only)
		  CLKB : in STD_LOGIC;
		  ENB : in STD_LOGIC;
		  AdrBusB : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		  DBOutB : out  STD_LOGIC_VECTOR (31 downto 0)

              );
end sim_MainMemory;


architecture Behavioral of sim_MainMemory is

attribute keep_hierarchy : string;
attribute keep_hierarchy of Behavioral: architecture is "TRUE";


type tRam is array (0 to SIZE-1) of STD_LOGIC_VECTOR (31 downto 0);
subtype tWord is std_logic_vector(31 downto 0);


signal DOA,DOB,DIA : tWord;
signal WEA : STD_LOGIC_VECTOR (3 downto 0);  


-- Design time code...
-- Initalizes block RAM form memory file
-- The file does either contain hex values (mode = 'H') or binary values
 
impure function InitFromFile  return tRam is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable word : tWord;
variable r : tRam;

begin
  for I in tRam'range loop
    if not endfile(RamFile) then
      readline (RamFile, RamFileLine);
		if mode="H" then 
		   hread (RamFileLine, word); -- alternative: HEX read 
		else  	
         read(RamFileLine,word);  -- Binary read
      end if;		  
      r(I) := word;              
     else
       r(I) := (others=>'0'); 
    end if;     
  end loop;
  return r; 
end function;

signal ram : tRam:= InitFromFile;


begin
 
 DIA<=DBIn;
 DBOut<=DOA;
 DBOutB<=DOB;
 WEA<=WREN;


  process(clk) 
  variable adr : integer;
  begin
    if rising_edge(clk) then 
        if ena = '1' then
           adr :=  to_integer(unsigned(AdrBus));       

           for i in 0 to 3 loop
             if WEA(i) = '1' then
                ram(adr)((i+1)*8-1 downto i*8)<= DIA((i+1)*8-1 downto i*8);
             end if;
           end loop;
                         
           DOA <= ram(adr);
                    
         end if;    
     end if;
  
  end process;

  
  portb:  if EnableSecondPort generate
  
     process(clkb) begin
        if rising_edge(clkb) then
            if ENB='1' then
               DOB <= ram(to_integer(unsigned(AdrBusB)));
             end if;    
         end if;
     end process;
     
  end generate;
   
end Behavioral;

