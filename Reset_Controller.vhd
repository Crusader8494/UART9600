----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2019 11:30:25 PM
-- Design Name: 
-- Module Name: Reset_Controller - Behavioral
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

entity Reset_Controller is
    Port ( CLK100MHz : in STD_LOGIC;
           Reset_In : in STD_LOGIC;
           Reset_1 : out STD_LOGIC;
           Reset_2 : out STD_LOGIC;
           Reset_3 : out STD_LOGIC);
end Reset_Controller;

architecture Behavioral of Reset_Controller is
   
    type Reset_SM is (
        Idle_State,
        Reset_1_State,
        Reset_2_State,
        Reset_3_State,
        Wait_State
    );
    
    signal Reset_State : Reset_SM := Idle_State;
        
    signal Reset_Cnt : natural := 0;

begin

    Reset : process(CLK100MHz) is
    begin
    
        if rising_edge(CLK100MHz) then
        
            case Reset_State is
                when Idle_State =>
                
                    Reset_1 <= '1';
                    Reset_2 <= '1';
                    Reset_3 <= '1';
                    
                    Reset_Cnt <= 0;
                    
                    if Reset_In = '0' then
                        Reset_State <= Reset_1_State;
                    else
                        null;
                    end if;
                    
                when Reset_1_State =>
                
                    Reset_1 <= '0';
                    
                    if Reset_Cnt = 15 then
                        Reset_Cnt <= 0;
                        Reset_State <= Reset_2_State;
                    else
                        Reset_Cnt <= Reset_Cnt + 1;
                    end if;
                    
                when Reset_2_State =>
                
                    Reset_2 <= '0';
                    
                    if Reset_Cnt = 15 then
                        Reset_Cnt <= 0;
                        Reset_State <= Reset_3_State;
                    else
                        Reset_Cnt <= Reset_Cnt + 1;
                    end if;
                                    
                when Reset_3_State =>
                
                    Reset_3 <= '0';
                    
                    if Reset_Cnt = 15 then
                        Reset_Cnt <= 0;
                        Reset_State <= Wait_State;
                    else
                        Reset_Cnt <= Reset_Cnt + 1;
                    end if;
                    
                when Wait_State =>
                    
                    if Reset_Cnt = 65535 then
                        Reset_Cnt <= 65535;
                        if Reset_In = '0' then
                            null;
                        else
                            Reset_State <= Idle_State;
                        end if;
                    else
                        Reset_Cnt <= Reset_Cnt + 1;
                    
                    end if;
                    
                when others =>
                    Reset_State <= Idle_State;
            end case;
        end if;
    
    end process;

end Behavioral;
