
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity booth is
	port (operand_a : in std_logic_vector (5 downto 0);
	      operand_b : in std_logic_vector (5 downto 0);
	      rst       : in std_logic;
	      clk       : in std_logic;
	      z         : out std_logic_vector (11 downto 0));
end booth;



architecture rtl of booth is
	component RCA is
        generic(N:integer:=11);
        port(   A,B: in std_logic_vector(N-1 downto 0);
		Ci: in std_logic;
		Co: out std_logic;
                S: out std_logic_vector(N-1 downto 0));
end component;
--Declare  Signals

signal x, y, nx : std_logic_vector (5 downto 0);
signal y1, y2, y3 : std_logic_vector (2 downto 0);
signal x_p1, x_p2, x_p3, p1, p2, p3 : std_logic_vector (10 downto 0);
signal Co1, Co2 : std_logic; 
begin 
	process(operand_a, operand_b)
	begin
		if(operand_a(5) = '1') then
			x <= operand_b;
			y <= operand_a;
		elsif (operand_b(5) = '1') then
			x <= operand_a;
			y <= operand_b;
		else 
			x <= operand_a;
			y <= operand_b;
		end if;
	end process;

	y1 <= y(1 downto 0) & '0';
	y2 <= y(3 downto 1);
	y3 <= y(5 downto 3);

	nx <= not(x) + 1;


--Declare  Components
process(y1, y2, y3)
	begin
		case (y1) is
			when "000" => x_p1 <= "00000000000";
			when "001" => x_p1 <= "00000" & x;
			when "010" => x_p1 <= "00000" & x;
			when "011" => x_p1 <= "0000" & x & '0';
			when "100" => x_p1 <= "1111" & nx & '0';
			when "101" => x_p1 <= "11111" & nx;
			when "110" => x_p1 <= "11111" & nx;
			when "111" => x_p1 <= "00000000000"; 
			when others => x_p1 <= "00000000000";
		end case;

		case (y2) is
			when "000" => x_p2 <= "00000000000";
			when "001" => x_p2 <= "000" & x & "00";
			when "010" => x_p2 <= "000" & x & "00";
			when "011" => x_p2 <= "00" & x & "000";
			when "100" => x_p2 <= "11" & nx & "000";
			when "101" => x_p2 <= "111" & nx & "00";
			when "110" => x_p2 <= "111" & nx & "00";
			when "111" => x_p2 <= "00000000000"; 
			when others => x_p2 <= "00000000000";
		end case;

		case (y3) is
			when "000" => x_p3 <= "00000000000";
			when "001" => x_p3 <= "0" & x & "0000";
			when "010" => x_p3 <= "0" & x & "0000";
			when "011" => x_p3 <=  x & "00000";
			when "100" => x_p3 <= nx & "00000";
			when "101" => x_p3 <= "1" & nx & "0000";
			when "110" => x_p3 <= "1" & nx & "0000";
			when "111" => x_p3 <= "00000000000"; 
			when others => x_p3 <= "00000000000";
		end case;
	end process;

	p1 <= x_p1; 

add1: rca generic map(N=>11) port map (A=> p1, B => x_p2, Ci => '0', Co => Co1, s => p2);
add2: rca generic map(N=>11) port map (A=> p2, B => x_p3, Ci => '0', Co => Co2, s => p3);

z <= p3(10) & p3; 

end;
