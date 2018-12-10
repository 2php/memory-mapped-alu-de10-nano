library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity ALU is
	port (Clock, Reset	    : in std_logic; -- system reset
			Opcode 				 : in std_logic_vector(2 downto 0);
			OperandA, OperandB : in std_logic_vector(31 downto 0);
			Status				 : out std_logic_vector(3 downto 0);
			Result_low		 	 : out std_logic_vector(31 downto 0);
			Result_high 		 : out std_logic_vector(31 downto 0)
			);
end entity;
			
architecture ALU_arch of ALU is

	-- Signals

	type State_Type is (nop, add, sub, mul, inca, mova, swap, twos_comp_add);
	signal current_state, next_state, wait_state : State_Type;

	signal op_changed : std_logic := '0';
	signal capture : std_logic_vector(2 downto 0);
	
	signal alu_uns : signed(64 downto 0) := (others => '0');

	signal padding : std_logic_vector(32 downto 0) := (others => '0');
	
	signal NZVC : std_logic_vector(3 downto 0) := (others => '0');
	
	begin
	
		Status      <= NZVC;
		Result_high <= std_logic_vector(alu_uns(63 downto 32));
		Result_low  <= std_logic_vector(alu_uns(31 downto 0));
		
		FLAGS : process(Clock)
		begin
			if (rising_edge(Clock)) then
					
					--- Zero Flag (Z) ---------------------------
					if (to_integer(alu_uns(63 downto 0)) = 0) then
						NZVC(0) <= '1';
					else
						NZVC(0) <= '0';
					end if;
					
					--- Negative (N) --------------------------
					NZVC(1) <= alu_uns(63);
					
					-- Carry Flag (C) -------------------------------
					NZVC(2) <= alu_uns(64);
					
					--- Overflow Flag (V) -------------------------
					if ((OperandA(31) = '0' and OperandB(31) = '0' and alu_uns(63) = '1') or
						(OperandA(31)= '1' and OperandB(31)='1' and alu_uns(63)='0')) then
						NZVC(3) <= '1';
					else
						NZVC(3) <= '0';
					end if;

				end if;
		end process;
	
		op_changed <= or_reduce(Opcode xor capture);
	
		DETECT_CHANGE : process(Clock, Opcode)
		begin
			if (rising_edge(Clock)) then
				capture <= Opcode;
			end if;
		end process;

		STATE_MEMORY : process(Clock)
			begin
				if (rising_edge(Clock)) then
					--if (op_changed = '1') then
						current_state <= next_state;
					--else
					--	current_state <= wait_state;
					--end if;
				end if;
		end process;
		
		NEXT_STATE_LOGIC : process (Clock,opcode)
			begin
				if (rising_edge(Clock)) then
					case Opcode is
						when "000" => next_state <= nop;
						when "001" => next_state <= add;			
						when "010" => next_state <= sub;			
						when "011" => next_state <= mul;
						when "100" => next_state <= inca;
						when "101" => next_state <= mova;
						when "110" => next_state <= swap;
						when "111" => next_state <= twos_comp_add;
					end case;
				end if;	
		end process;
			
		OUTPUT_LOGIC : process (Clock, current_state)
			begin
					if (rising_edge(Clock)) then
						case (current_state) is
							when add => alu_uns <= signed(padding & OperandA) + signed(padding & OperandB);
							when sub => alu_uns <= signed(padding & OperandA) - signed(padding & OperandB);
							when mul => alu_uns <= signed('0' & OperandA)     * signed(OperandB);
							when inca => alu_uns <= signed((padding & OperandA) + 1);
							when mova => alu_uns <= signed(padding & OperandA);

							--when twos_comp_add =>;
							when others => NULL;
						end case;
					end if;
		end process;
	
end architecture ALU_arch;