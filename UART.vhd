----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2019 10:06:13 PM
-- Design Name: 
-- Module Name: UART - Behavioral
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

entity UART is
    Port ( CLK100MHz : in STD_LOGIC;

           Tx : out STD_LOGIC := '1';
           Rx : in STD_LOGIC_VECTOR (0 downto 0);
            
           A_RESET : in STD_LOGIC;
           
           Tx_FIFO_CLK  : out STD_LOGIC := '0';
           FIFO_RD : out STD_LOGIC := '0';
           FIFO_IN : in STD_LOGIC_VECTOR (7 downto 0);
           FIFO_AE : in STD_LOGIC;
           FIFO_EM : in STD_LOGIC;
           
           Rx_FIFO_CLK  : out STD_LOGIC := '0';
           FIFO_WT : out STD_LOGIC := '0';
           FIFO_OT : out STD_LOGIC_VECTOR (7 downto 0) := x"00";
           FIFO_AF : in STD_LOGIC;
           FIFO_FU : in STD_LOGIC
           );
end UART;

architecture Behavioral of UART is
    
    type Tx_UART is (
        OFF,
        IDLE,
        START,
        MSG,
        STOP
    );
    
    type Tx_FIFO is (
        IDLE,
        READ_EN,
        READ,
        WA1T1,
        WA1T2
    );    
    
    type Rx_UART is (
        RESET,
        IDLE,
        RECEIVE,
        EVAL,
        PUSH,
        WA1T
    );
    
    type Rx_FIFO is (
        IDLE,
        WRITE,
        WRITE_EN,
        WA1T
    );
    
    signal Transmit_State : Tx_UART := OFF;
    signal Tx_FIFO_State : Tx_FIFO := IDLE;
    
    signal Receive_State : Rx_UART := RESET;
    signal Rx_FIFO_State : Rx_FIFO := IDLE;
    
    signal CLK9600   : unsigned (15 downto 0) := x"0000";
    signal CLK9600_D : STD_LOGIC := '0';
    
    signal Tx_Word_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal Tx_Word_Cnt : natural := 0;
    
    signal CLK9600_8   : unsigned (15 downto 0) := x"0000";
    signal CLK9600_8_D : STD_LOGIC := '0';
    
    signal Rx_Word_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal Rx_Word_Cnt : natural := 0;
    
    signal Rx_RCV_Cnt : unsigned (7 downto 0) := x"00";

    signal RX_SBR_7   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_6   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_5   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_4   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_3   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_2   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_1   : unsigned (3 downto 0) := x"0";
    signal RX_SBR_0   : unsigned (3 downto 0) := x"0";
    
    signal RX_BIT_0   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_1   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_2   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_3   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_4   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_5   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_6   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal RX_BIT_7   : STD_LOGIC_VECTOR (0 downto 0) := "0";
    
    signal RX_MSG     : STD_LOGIC_VECTOR (7 downto 0) := x"00";
    
begin
    
    ClockMod : Process(CLK100MHz) is
    begin
        if rising_edge(CLK100MHz) then
        
            if CLK9600 = x"28B1" then
                CLK9600 <= x"0000";
            else
                CLK9600 <= CLK9600 + "1";
            end if;
            
            if CLK9600 > x"1458" then
                CLK9600_D <= '1';
                Tx_FIFO_CLK <= '1';
            elsif CLK9600 <= x"1457" then
                CLK9600_D <= '0';
                Tx_FIFO_CLK <= '0';
            else
                CLK9600_D <= '0';
                Tx_FIFO_CLK <= '0';
            end if;
            
            if CLK9600_8 = x"0516" then
                CLK9600_8 <= x"0000";
            else
                CLK9600_8 <= CLK9600_8 + "1";
            end if;
            
            if CLK9600_8 > x"028B" then
                CLK9600_8_D <= '1';
                Rx_FIFO_CLK <= '1';
            elsif CLK9600_8 <= x"028B" then
                CLK9600_8_D <= '0';
                Rx_FIFO_CLK <= '0';
            else
                CLK9600_8_D <= '0';
                Rx_FIFO_CLK <= '0';
            end if;
            
        end if;
    end process;
    
    Tx_Process : Process(CLK9600_D) is
    begin
    
        if rising_edge(CLK9600_D) then
            
            case Tx_FIFO_State is
                when IDLE =>
                    
                    FIFO_RD <= '0';
                    Transmit_State <= OFF;
                    
                    if FIFO_EM = '1' then
                        Tx_FIFO_State <= IDLE;
                    else
                        Tx_FIFO_State <= READ_EN;
                    end if;
                    
                when READ_EN =>
                    FIFO_RD <= '1';
                    Tx_FIFO_State <= WA1T1;
                when WA1T1 =>
                    FIFO_RD <= '0';
                    --Tx_Word_1 <= FIFO_IN;
                    --Transmit_State <= IDLE;
                    Tx_FIFO_State <= READ;
                when READ =>
                    Tx_Word_1 <= FIFO_IN;
                    Transmit_State <= IDLE;
                    Tx_FIFO_State <= WA1T2;
                when WA1T2 =>
                    null;
                when others =>
                    Tx_FIFO_State <= IDLE;
            end case;
            
            case Transmit_State is
                when OFF =>  -- Determine if there is something in the FIFO to be Read
                    Tx <= '1';
                                        
                when IDLE => -- Read off FIFO
                    Tx <= '1';
                    Transmit_State <= START;
                when START => -- Start Message
                    Tx <= '0';
                    Tx_Word_Cnt <= 0;
                    Transmit_State <= MSG;
                when MSG => -- Data Bits
                    Tx <= Tx_Word_1(Tx_Word_Cnt);
                    if Tx_Word_Cnt = 7 then
                        Transmit_State <= STOP;
                    else
                        Tx_Word_Cnt <= Tx_Word_Cnt + 1;
                    end if;
                when STOP => -- Stop Bit / Cleanup
                    Tx <= '1';
                    Transmit_State <= OFF;
                    Tx_FIFO_State <= IDLE;
            end case;
            
        end if;
    
    end process;
    
    Rx_Process : Process(CLK9600_8_D) is --Oversample this later
    begin
    
        if rising_edge(CLK9600_8_D) then
            
            case Receive_State is
                when RESET =>
                    RX_SBR_0 <= (others=>'0');
                    RX_SBR_1 <= (others=>'0');
                    RX_SBR_2 <= (others=>'0');
                    RX_SBR_3 <= (others=>'0');
                    RX_SBR_4 <= (others=>'0');
                    RX_SBR_5 <= (others=>'0');
                    RX_SBR_6 <= (others=>'0');
                    RX_SBR_7 <= (others=>'0');
                    
                    RX_BIT_0 <= (others=>'0');
                    RX_BIT_1 <= (others=>'0');
                    RX_BIT_2 <= (others=>'0');
                    RX_BIT_3 <= (others=>'0');
                    RX_BIT_4 <= (others=>'0');
                    RX_BIT_5 <= (others=>'0');
                    RX_BIT_6 <= (others=>'0');
                    RX_BIT_7 <= (others=>'0');
                    
                    Rx_RCV_Cnt <= (others=>'0');
                    
                    Receive_State <= IDLE;
                when IDLE =>
                
                    if Rx = "0" then
                        Rx_RCV_Cnt <= Rx_RCV_Cnt + x"1";
                    else
                        Rx_RCV_Cnt <= x"00";
                    end if;
                    
                    if Rx_RCV_Cnt >= x"04" then
                        Receive_State <= Receive;
                        Rx_RCV_Cnt <= x"00";
                    else
                        null;
                    end if;                    
                when Receive =>
                    
                    if Rx_RCV_Cnt <= "01000000" then
                        if Rx_RCV_Cnt >= "00000000" and Rx_RCV_Cnt < "00001000" then
                            RX_SBR_0 <= RX_SBR_0 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00001000" and Rx_RCV_Cnt < "00010000" then
                            RX_SBR_1 <= RX_SBR_1 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00010000" and Rx_RCV_Cnt < "00011000" then
                            RX_SBR_2 <= RX_SBR_2 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00011000" and Rx_RCV_Cnt < "00100000" then
                            RX_SBR_3 <= RX_SBR_3 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00100000" and Rx_RCV_Cnt < "00101000"  then
                            RX_SBR_4 <= RX_SBR_4 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00101000" and Rx_RCV_Cnt < "00110000"  then
                            RX_SBR_5 <= RX_SBR_5 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00110000" and Rx_RCV_Cnt < "00111000" then
                            RX_SBR_6 <= RX_SBR_6 + unsigned(Rx);
                        elsif Rx_RCV_Cnt >= "00111000" and Rx_RCV_Cnt < "01000000" then
                            RX_SBR_7 <= RX_SBR_7 + unsigned(Rx);
                        else
                            null;
                        end if;
                    else
                        Receive_State <= EVAL;
                        Rx_RCV_Cnt <= x"00";
                    end if;
                    
                    Rx_RCV_Cnt <= Rx_RCV_Cnt + x"1";
                
                when EVAL =>
                
                    if RX_SBR_0 >= 5 then
                        RX_BIT_0 <= "1";
                    else
                        RX_BIT_0 <= "0";
                    end if;
                    
                    if RX_SBR_1 >= 5 then
                        RX_BIT_1 <= "1";
                    else
                        RX_BIT_1 <= "0";
                    end if;
                    
                    if RX_SBR_2 >= 5 then
                        RX_BIT_2 <= "1";
                    else
                        RX_BIT_2 <= "0";
                    end if;
                    
                    if RX_SBR_3 >= 5 then
                        RX_BIT_3 <= "1";
                    else
                        RX_BIT_3 <= "0";
                    end if;
                    
                    if RX_SBR_4 >= 5 then
                        RX_BIT_4 <= "1";
                    else
                        RX_BIT_4 <= "0";
                    end if;
                    
                    if RX_SBR_5 >= 5 then
                        RX_BIT_5 <= "1";
                    else
                        RX_BIT_5 <= "0";
                    end if;
                    
                    if RX_SBR_6 >= 5 then
                        RX_BIT_6 <= "1";
                    else
                        RX_BIT_6 <= "0";
                    end if;
                    
                    if RX_SBR_7 >= 5 then
                        RX_BIT_7 <= "1";
                    else
                        RX_BIT_7 <= "0";
                    end if;
                    
                    Receive_State <= PUSH;
                    
                when PUSH =>
                    
                    RX_MSG <= RX_BIT_7 & RX_BIT_6 & RX_BIT_5 & RX_BIT_4 & RX_BIT_3 & RX_BIT_2 & RX_BIT_1 & RX_BIT_0;
                    
                    Receive_State <= WA1T;
                    
                when WA1T =>
                    Receive_State <= RESET;
                    Rx_FIFO_State <= WRITE;
            end case;
            
            case Rx_FIFO_State is
                when IDLE =>
                    FIFO_WT <= '0';
                    FIFO_OT <= x"00";
                when WRITE =>
                    if FIFO_FU = '1' or FIFO_AF = '1' then
                        Rx_FIFO_State <= IDLE;
                    else
                        FIFO_OT <= RX_MSG;
                        Rx_FIFO_State <= WRITE_EN;
                    end if;
                when WRITE_EN =>
                    if FIFO_FU = '1' or FIFO_AF = '1' then
                        Rx_FIFO_State <= IDLE;
                    else
                        FIFO_WT <= '1';
                        Rx_FIFO_State <= WA1T;
                    end if;
                when WA1T =>
                    FIFO_WT <= '0';
                    Rx_FIFO_State <= IDLE;                                       
            end case;
            
        end if;
    
    end process;
    
end Behavioral;
