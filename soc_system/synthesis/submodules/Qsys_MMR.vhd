library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

LIBRARY altera;
USE altera.altera_primitives_components.all;

entity Qsys_MMR is
	port (
		clk 		: in std_logic;
		reset_n  : in std_logic; -- reset asserted low
		avs_s1_address : in std_logic_vector(2 downto 0);
		avs_s1_write 	: in std_logic;
		avs_s1_writedata : in std_logic_vector(31 downto 0);
		avs_s1_read 	  : in std_logic;
		avs_s1_readdata : out std_logic_vector(31 downto 0);
		LEDs : out std_logic_vector(7 downto 0)
);
end Qsys_MMR;

architecture Qsys_MMR_arch of Qsys_MMR is

   -- Component Instantiations
		
	component ALU is
		port (Clock, Reset	    : in std_logic; -- system reset
				Opcode 				 : in std_logic_vector(2 downto 0);
				OperandA, OperandB : in std_logic_vector(31 downto 0);
				Status				 : out std_logic_vector(3 downto 0);
				Result_low		 	 : out std_logic_vector(31 downto 0);
				Result_high 		 : out std_logic_vector(31 downto 0)
			);
	end component;
	
	-- Signals
	
	signal operandA : std_logic_vector(31 downto 0) := (others => '0');
	signal operandB : std_logic_vector(31 downto 0) := (others => '0');
	signal opcode   : std_logic_vector(31 downto 0) := (others => '0');
	signal status   : std_logic_vector(31 downto 0) := (others => '0');
	
	signal result_low  : std_logic_vector(31 downto 0) := (others => '0');
	signal result_high : std_logic_vector(31 downto 0) := (others => '0');
	
	begin
	
		-- Processes
		LEDs(7 downto 5) <= opcode(2 downto 0);
		LEDs(3 downto 0) <= status(3 downto 0);

		process(clk, opcode) is
		begin
			if rising_edge(clk) and avs_s1_read ='1' then
				case avs_s1_address is
					when "000" => if opcode = "110" then
										avs_s1_readdata <= operandB;
									  else
										avs_s1_readdata <= operandA;
									  end if;
					
					when "001" => if opcode = "110" then
										avs_s1_readdata <= operandA;
									  else
										avs_s1_readdata <= operandB;
									  end if;
					
					when "010" => avs_s1_readdata <= result_low;
					when "011" => avs_s1_readdata <= result_high;
					when "100" => avs_s1_readdata <= opcode;
					when "101" => avs_s1_readdata <= status;
					when others => avs_s1_readdata <= (others => '0');
					end case;
			end if;
		end process;
		
		process(clk, opcode) is
		begin
			if rising_edge(clk) and avs_s1_write ='1' then
				case avs_s1_address is
					when "000" => if opcode = "110" then
										operandB    <= avs_s1_writedata;
									  else
										operandA    <= avs_s1_writedata;
									  end if;
					when "001" => if opcode = "110" then
										operandA    <= avs_s1_writedata;
									  else
										operandB    <= avs_s1_writedata;
									  end if;
					when "100" => opcode      <= avs_s1_writedata;
					when others => NULL;
					end case;					
			end if;
		end process;
		
		
		-- Port Mapping
		
		U0 : ALU
			port map(Clock => clk, Reset => reset_n,
						Opcode => opcode(2 downto 0),
						OperandA => operandA, OperandB => operandB,
						Status => status(3 downto 0),
						Result_low => result_low, Result_high => result_high);
		
 
end architecture Qsys_MMR_arch;