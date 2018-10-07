--Origional Source: http://www.dejazzer.com/eigenpi/digital_camera/digital_camera.html

--VGA address generator
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Address_Generator is
  Port (   
    CLK25,enable : in  STD_LOGIC;  -- 25MHz input clock
    vsync        : in  STD_LOGIC;
    address      : out STD_LOGIC_VECTOR (16 downto 0) -- output address
  );  
end Address_Generator;

architecture Behavioral of Address_Generator is

  signal val: STD_LOGIC_VECTOR(address'range):= (others => '0');
  
begin

  address <= val;

  process(CLK25)
    begin
      if rising_edge(CLK25) then
      
        if (enable='1') then           -- If enable is 0, module goes into reset and stops generation

--          if rez_160x120 = '1' then
--            if (val < 160*120) then    -- si l'espace memoire est balay completement        
--              val <= val + 1 ;
--            end if;
--          elsif rez_320x240 = '1' then
--            if (val < 320*240) then    -- si l'espace memoire est balay completement        
--              val <= val + 1 ;
--            end if;
--          else
--            if (val < 640*480) then    -- si l'espace memoire est balay completement        
--              val <= val + 1 ;
--            end if;
--          end if;

         -- if (val < 320*240) then			-- si l'espace memoire est balay completement     
			if (val < 320*240) then			
            val <= val + 1 ;
          end if;
        end if;
        
        if vsync = '0' then 
           val <= (others => '0');
        end if;
        
      end if;  
    end process;
end Behavioral;
