----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2019 22:12:15
-- Design Name: 
-- Module Name: project - Behavioral
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

entity project_reti_logiche is
    port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end project_reti_logiche;
    
architecture Behavioral of project_reti_logiche is
    
    type state is (RST,
                   WAIT_S,
                   START,
                   POINT_X,
                   POINT_Y,
                   READ_X,
                   READ_Y,
                   FINALIZE);
    
    signal  curr_state      :   state := RST;
    signal  next_state      :   state := WAIT_S;
    signal  loop_sig        :   std_logic := '0';
    signal  mask            :   std_logic_vector(7 downto 0);
    signal  o_mask            :   std_logic_vector(7 downto 0);
    signal  p_x             :   unsigned(7 downto 0);
    signal  p_y             :   unsigned(7 downto 0);
    signal  distance        :   unsigned(8 downto 0) := (others => '0');
    signal  min_distance    :   unsigned(8 downto 0) := (others => '1');
    signal  addr_buff       :   unsigned(15 downto 0) := (others => '0');
    
    
    
begin
    
    SYNCHRO: process(i_clk)
    begin
        
        if(i_clk'event and i_clk='1') then
            if(curr_state=next_state) then
                loop_sig <= not loop_sig;
            end if;
            curr_state <= next_state;
        end if;
    end process SYNCHRO;
    
    CASES: process(curr_state, loop_sig)
    begin
    
        case curr_state is
            when RST        => min_distance<= (others=>'1');
                               o_mask      <= (others=>'0'); 
                               o_en        <= '0';
                               o_we        <= '0';
                               o_done      <= '0';
                               next_state  <= WAIT_S;
            when WAIT_S     => if(i_start='1') then
                                   o_en <= '1';
                                   o_address   <= (others => '0');
                                   next_state <= START;
                               else
                                   next_state <= WAIT_S;
                               end if;
            when START      => mask <= i_data;
                               o_address <= "0000000000010001";
                               next_state <= POINT_X;
            when POINT_X    => p_x <= unsigned(i_data);
                               o_address <= "0000000000010010";                                  
                               next_state <= POINT_Y;
            when POINT_Y    => p_y <= unsigned(i_data);
                               addr_buff <= "0000000000000001";
                               o_address <= std_logic_vector(addr_buff);
                               next_state <= READ_X;
           when READ_X     =>  if(unsigned(addr_buff) = 17) then
                                   o_address <= "0000000000010011";
                                   o_we <= '1';
                                   o_data <= o_mask;
                                   next_state <= FINALIZE;
                               else
                                    if(mask(0)='0') then
                                       o_mask <= '0' & o_mask(7 downto 1);
                                       addr_buff <= addr_buff + 2;
                                       o_address <= std_logic_vector(addr_buff);
                                       next_state <= READ_X;
                                   else
                                       if(unsigned(i_data) < p_x) then
                                           distance <=unsigned('0' & std_logic_vector(p_x - unsigned(i_data)));
                                       else
                                           distance <= unsigned('0' & std_logic_vector(unsigned(i_data) - p_x));
                                       end if;
                                       addr_buff <= addr_buff + 1;
                                       o_address <= std_logic_vector(addr_buff);
                                       next_state <= READ_Y;
                                       if(distance > min_distance) then
                                           addr_buff <= addr_buff + 1;
                                           o_address <= std_logic_vector(addr_buff);
                                           o_mask <= '0' & o_mask(7 downto 1);
                                           next_state <= READ_X;
                                       end if;
                                   end if;
                                   mask <= '0' & mask(7 downto 1);
                               end if;
           when READ_Y      => if(unsigned(i_data) < p_y) then
                                   distance <= distance + p_y - unsigned('0' & i_data);
                               else
                                   distance <= distance + unsigned('0' & i_data) - p_y;
                               end if;
                               if(distance=min_distance) then
                                   o_mask <= '1' & o_mask(7 downto 1);
                               elsif(distance<min_distance) then
                                   o_mask <= (7=>'1', others=>'0');
                                   min_distance <= distance;
                               else
                                   o_mask <= '0' & o_mask(7 downto 1);
                               end if;
                               addr_buff <= addr_buff + 1;
                               o_address <= std_logic_vector(addr_buff);
                               next_state <= READ_X;
          when FINALIZE     => o_done <= '1';
                               o_en <= '0';
                               o_we <= '0';
                               if(i_start='1') then
                                   next_state <= FINALIZE;
                               else
                                   next_state <= RST;
                               end if;
    
        end case;
    end process CASES;
    

end Behavioral;
