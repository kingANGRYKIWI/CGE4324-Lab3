----------------------------------------------------------------------------------
-- Design Name: 
-- Module Name: top_module - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.oled_pkg.all;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module is
    Port ( clk         : in std_logic;
           rst         : in std_logic;
           oled_sdin   : out std_logic;
           oled_sclk   : out std_logic;
           oled_dc     : out std_logic;
           oled_res    : out std_logic;
           oled_vbat   : out std_logic;
           oled_vdd    : out std_logic;
           SW          : in STD_LOGIC_VECTOR (7 downto 0);
           N           : in STD_LOGIC;
           S           : in STD_LOGIC;
           W           : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (7 downto 0));
end top_module;

architecture Behavioral of top_module is

component oled_ctrl is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            oled_sdin   : out std_logic;
            oled_sclk   : out std_logic;
            oled_dc     : out std_logic;
            oled_res    : out std_logic;
            oled_vbat   : out std_logic;
            oled_vdd    : out std_logic;
            data        : in oled_mem);
end component;



component booth is
	port (operand_a : in std_logic_vector (5 downto 0);
	      operand_b : in std_logic_vector (5 downto 0);
	      rst       : in std_logic;
	      clk       : in std_logic;
	      z         : out std_logic_vector (11 downto 0));
end component;


signal data, dataA, dataB, dataAs, dataBs, Aval, Bval,Ldata : std_logic_vector (5 downto 0);
signal result,Rval                         : std_logic_vector (11 downto 0); 
signal lRval                               : std_logic_vector (3 downto 0);
signal load, end_flag, A, B, C             : std_logic;
signal ones, twos                          : std_logic_vector (7 downto 0);
 
signal oled_sdin_s,oled_sclk_s,oled_dc_s,oled_res_s,oled_vbat_s,oled_vdd_s : std_logic;


SIGNAL opA, opB : add_pkg;
SIGNAL opR : mult_pkg;

SIGNAL three : STD_LOGIC_VECTOR(3 downto 0):="0011";
SIGNAL four  : STD_LOGIC_VECTOR(3 downto 0):="0100";
SIGNAL one   : STD_LOGIC :='1';
SIGNAL zero  : STD_LOGIC :='0';

SIGNAL finalA,finalB: STD_LOGIC_VECTOR(3 downto 0);

constant data_val : oled_mem := ( (x"20", x"20", x"20", x"20", x"52", x"41", x"44", x"49", x"58", x"2D", x"32", x"20", x"20", x"20", x"20", x"20"),
                                  (x"42", x"4F", x"4F", x"54", x"48", x"20", x"4D", x"55", x"4C", x"54", x"49", x"50", x"4C", x"49", x"45", x"52"),
                                  (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                  (x"20", opA(2),opA(1),opA(0),x"2A", opB(2),opB(1),opB(0),x"3D", opR(4),opR(3),opR(2),opR(1),opR(0),x"20", x"20"));
                                  

begin

oled_sdin<=oled_sdin_s;
oled_sclk<=oled_sclk_s;
oled_dc<=oled_dc_s;
oled_res<=oled_res_s;
oled_vbat<=oled_vbat_s;
oled_vdd<=oled_vdd_s;

--data(7)<=SW(7);
--data(6)<=SW(6);
data(5)<=SW(5);
data(4)<=SW(4);
data(3)<=SW(3);
data(2)<=SW(2);
data(1)<=SW(1);
data(0)<=SW(0);

--LED(7)<=Ldata(7);
--LED(6)<=Ldata(6);
LED(5)<=Ldata(5);
LED(4)<=Ldata(4);
LED(3)<=Ldata(3);
LED(2)<=Ldata(2);
LED(1)<=Ldata(1);
LED(0)<=Ldata(0);

A<=N;       --load data A
B<=S;       --load data B
load<=W;    --load data A and B to Oled

Comp_th: oled_ctrl port map (   clk, 
                                rst,                   
                                oled_sdin_s,   
                                oled_sclk_s,   
                                oled_dc_s,     
                                oled_res_s,    
                                oled_vbat_s,   
                                oled_vdd_s,
                                data_val); 


booth_Th: booth port map (operand_a => dataAs, operand_b => dataBs, rst=>rst,clk=>clk,z=>result);       



Rval<=result; --result of the booth multiplier


-- process to load data to A and B
process(clk)
    begin
        if(rising_edge(clk)) then
                if(A='1') then
                    dataAs<=data;
                    Ldata(5 downto 0)<=data;
                else
                    dataAs<=dataAs;
                end if;
                
                if(B='1') then
                    dataBs<=data;
                    Ldata(5 downto 0)<=data;
                else
                    dataBs<=dataBs;
                end if;
                
                if(rst = '1') then
                    Aval<="000000";
                    Bval<="000000";
                    opA(2)<=x"20";
                    opB(2)<=x"20";
                    opR(4)<=X"20";
                elsif ( Load = '1') then
                            Aval<=dataAs;
                            Bval<=dataBs;
                        if(dataAs(5) = '1') then
                            opA(2)<=x"2D";
                            opB(2)<=x"2B";
                            opR(4)<=X"2D";
                        elsif(dataBs(5) = '1') then 
                            opA(2)<=x"2B";
                            opB(2)<=x"2D";
                            opR(4)<=X"2D";
                        elsif((dataBs(5) = '0') and (dataAs(5) = '0')) then 
                                opA(2)<=x"2B";
                                opB(2)<=x"2B";
                                opR(4)<=X"2B";
                       end if;
                end if;
        end if;
end process;

--process to Load negative data to A and positive data to B

--to display data on Oled
process(clk)
    begin
        if(rising_edge(clk)) then
--          A
          
--            if(Aval(6) = '1') then
--                finalA<= one & Aval(6 downto 4);
--                  if(finalA >"1001") then
--                        opA(1)<= four & ( finalA - "1001");
--                  else
--                        opA(1)<= three & finalA;
--                  end if;          
--            else
                finalA<= "00" & Aval(5 downto 4);
                      if(finalA >"1001") then
                            opA(1)<= four & ( finalA - "1001");
                      else
                            opA(1)<= three & finalA;
                      end if; 
--            end if;
            
            if(Aval(3 downto 0)>"1001") then
                opA(0)<= four & ( Aval(3 downto 0) - "1001");
            else
                opA(0)<= three & Aval(3 downto 0);
            end if;

            
--          B
     
--            if(Bval(6) = '1') then
--                finalB<= one & Bval(6 downto 4);
--                  if(finalB >"1001") then
--                        opB(1)<= four & ( finalB - "1001");
--                  else
--                        opB(1)<= three & finalB;
--                  end if;          
--            else
                finalB<= "00" & Bval(5 downto 4);
                      if(finalB >"1001") then
                            opB(1)<= four & ( finalB - "1001");
                      else
                            opB(1)<= three & finalB;
                      end if; 
--            end if;
            
            if(Bval(3 downto 0)>"1001") then
                opB(0)<= four & ( Bval(3 downto 0) - "1001");
            else
                opB(0)<= three & Bval(3 downto 0);
            end if;
            
--          RESULT

--            lRval<=('0' & Rval(14 downto 12));
--            if(lRval>"1001") then
--                opR(3)<= four & (lRval - "1001");
--            else
--                opR(3)<= three & (lRval);
--            end if;
           
            if(Rval(11 downto 8)>"1001") then
                opR(2)<= four & ( Rval(11 downto 8) - "1001");
            else
                opR(2)<= three & Rval(11 downto 8);
            end if;
            if(Rval(7 downto 4)>"1001") then
                opR(1)<= four & ( Rval(7 downto 4) - "1001");
            else
                opR(1)<= three & Rval(7 downto 4);
            end if;
            if(Rval(3 downto 0)>"1001") then
                opR(0)<= four & ( Rval(3 downto 0) - "1001");
            else
                opR(0)<= three & Rval(3 downto 0);
            end if;
                                                                                                                      
            
        end if;
end process;

       
end Behavioral;        
        
