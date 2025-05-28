library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity speck64_96 is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        start     : in  std_logic;
        key_in    : in  unsigned(95 downto 0);
        x_in      : in  unsigned(31 downto 0);
        y_in      : in  unsigned(31 downto 0);
        done      : out std_logic;
        x_out     : out unsigned(31 downto 0);
        y_out     : out unsigned(31 downto 0)
	
    );
end speck64_96;

architecture Behavioral of speck64_96 is
	 -- Signals
    type key_array is array (0 to 25) of unsigned(31 downto 0);
    signal round_keys : key_array := (others => (others => '0'));
    type key_array_extended is array (0 to 26) of unsigned(31 downto 0);
    signal L: key_array_extended := (others => (others => '0'));

    signal round_counter : integer range 0 to 26 := 0;
    signal state         : integer range 0 to 5 := 0;
    
    signal x_reg, y_reg : unsigned(31 downto 0) := (others => '0');

   
    -- Rotate left (ROL)
	function my_rol(x : unsigned(31 downto 0); r : integer) return unsigned is
    variable result : unsigned(31 downto 0);
	begin
    result := (x sll r) or (x srl (32 - r));
    return result(31 downto 0); -- Mask back to 32-bit
	end function;

	-- Rotate right (ROR)
	function my_ror(x : unsigned(31 downto 0); r : integer) return unsigned is
    	variable result : unsigned(31 downto 0);
	begin
    result := (x srl r) or (x sll (32 - r));
    return result(31 downto 0); -- Mask back to 32-bit
	end function;
	
	begin


	-- Process 
    process(clk, reset)
	 
	 -- Temporary variables
	 variable temp_x : unsigned(31 downto 0);
    variable temp_y : unsigned(31 downto 0);
	 variable temp_l : unsigned(31 downto 0);
	 variable L_var  : key_array_extended;
    variable rk_var : key_array;
	 
    begin
        if reset = '1' then
            round_counter <= 0;
            done <= '0';
            state <= 0;
            x_reg <= (others => '0');
            y_reg <= (others => '0');

        elsif rising_edge(clk) then
            case state is

                when 0 =>  -- IDLE
                     if start = '1' then
                        round_counter <= 0;
                        done <= '0';

                        round_keys(0) <= key_in(31 downto 0);       -- rk[0] 
								L(0) <= key_in(63 downto 32);      -- L[0] 
								L(1) <= key_in(95 downto 64);      -- L[1] 
                        state <= 1;
                    end if;

                when 1 =>  -- KEY GENERATION
							-- Copy signal arrays to variables for immediate use
						L_var := L;
						rk_var := round_keys;

						 if round_counter < 25 then
							  -- Generate L[round_counter + 2] and round_keys[round_counter + 1]
							  temp_l := (my_ror(L_var(round_counter), 8) + rk_var(round_counter)) xor to_unsigned(round_counter, 32);
							  L_var(round_counter + 2) := temp_l;
							  rk_var(round_counter + 1) := my_rol(rk_var(round_counter), 3) xor temp_l;

							  -- Write updated variables back to signals
							  L <= L_var;
							  round_keys <= rk_var;

							  -- Next round
							  round_counter <= round_counter + 1;

						 elsif round_counter = 25 then
							  -- Final round key generation
							  temp_l := (my_ror(L_var(24), 8) + rk_var(24)) xor to_unsigned(24, 32);
							  L_var(26) := temp_l;
							  rk_var(25) := my_rol(rk_var(24), 3) xor temp_l;

							  -- Write back
							  L <= L_var;
							  round_keys <= rk_var;

							  round_counter <= 26;  -- Delay one cycle to latch

						 elsif round_counter = 26 then
							  -- Proceed to next state
							  round_counter <= 0;
							  state <= 2;
						 end if;
	

                when 2 =>  -- LOAD PLAINTEXT
                    x_reg <= x_in;
                    y_reg <= y_in;
                    state <= 3;

               when 3 =>  -- ENCRYPTION ROUNDS
						if round_counter < 25 then
						-- Normal rounds (0 to 24)
							temp_x := (my_ror(x_reg, 8) + y_reg) xor round_keys(round_counter);
							temp_y := my_rol(y_reg, 3) xor temp_x;

							x_reg <= temp_x;
							y_reg <= temp_y;

							round_counter <= round_counter + 1;

						elsif round_counter = 25 then
						-- Final round (25) - delay transition
							temp_x := (my_ror(x_reg, 8) + y_reg) xor round_keys(round_counter);
							temp_y := my_rol(y_reg, 3) xor temp_x;

							x_reg <= temp_x;
							y_reg <= temp_y;

							round_counter <= 26;

						elsif round_counter = 26 then
						 -- Allow results to latch before moving on
							round_counter <= 0;
							state <= 4;
						end if;


                when 4 =>  -- DONE
                    x_out <= x_reg;
                    y_out <= y_reg;
                    done  <= '1';
                    state <= 5;

                when others =>
                    null;
            end case;
        end if;
    end process;

end Behavioral;


