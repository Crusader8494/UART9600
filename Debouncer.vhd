----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2019 09:50:11 PM
-- Design Name: 
-- Module Name: Debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Debouncer is
    Port ( CLK100MHz: in STD_LOGIC;
           Reset_In  : in STD_LOGIC;
           Reset_Out : out STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is

    signal Line_In_Cnt : unsigned (3 downto 0);

begin

    Debouncer : process(CLK100MHz) is
    begin
    
        if rising_edge(CLK100MHz) then
        
            if Reset_In = '1' then
                
                if Line_In_Cnt < x"F" then
                    Line_In_Cnt <= Line_In_Cnt + x"1";
                else
                    Line_In_Cnt <= x"F";
                    Reset_Out <= '1';
                end if;
                
            else
            
                Reset_Out <= '0';
                Line_In_Cnt <= x"0";
            
            end if;
            
        end if;
    
    end process;

end Behavioral;
