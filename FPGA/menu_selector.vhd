library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity menu_selector is
    Port (
        clk           : in  std_logic; -- wejœciowy sygna³ zegarowy
        left_button   : in  std_logic; -- lewy przycisk
        right_button  : in  std_logic; -- prawy przycisk
        display_left  : out std_logic_vector(6 downto 0);  -- wyjœcie dla lewego wyœwietlacza
        display_right : out std_logic_vector(6 downto 0)   -- wyjœcie dla prawego wyœwietlacza
    );
end menu_selector;

architecture Behavioral of menu_selector is
    signal left_digit   : integer range 0 to 9 := 0;
    signal right_digit  : integer range 0 to 9 := 0;

    constant DEBOUNCE_COUNT : integer := 10000;
    constant DEBOUNCE_LIMIT : integer := DEBOUNCE_COUNT + 1;
    constant ANIMATION_TIME : integer := 100000;

    signal debounce_counter0 : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal debounce_counter1 : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal animation_counter : integer range 0 to ANIMATION_TIME := 0;
    
    signal stable_left_button      : STD_LOGIC := '1';
    signal stable_right_button     : STD_LOGIC := '1';
    signal prev_stable_left_button : STD_LOGIC := '1';
    signal prev_stable_right_button: STD_LOGIC := '1';
    
    signal animation : STD_LOGIC := '0';
begin

    ButtonProc: process(clk, animation)
    begin
        if rising_edge(clk) then
            if animation = '0' then
                -- debounce left_button
                if left_button = stable_left_button then
                    debounce_counter0 <= 0;
                else
                    debounce_counter0 <= debounce_counter0 + 1;
                    if debounce_counter0 = DEBOUNCE_COUNT then
                        stable_left_button <= left_button;
                        debounce_counter0 <= 0;
                    end if;
                end if;

                -- debounce right_button
                if right_button = stable_right_button then
                    debounce_counter1 <= 0;
                else
                    debounce_counter1 <= debounce_counter1 + 1;
                    if debounce_counter1 = DEBOUNCE_COUNT then
                        stable_right_button <= right_button;
                        debounce_counter1 <= 0;
                    end if;
                end if;

                if stable_left_button = '0' and stable_right_button = '0' then
                    left_digit <= 0;
                    right_digit <= 0;
                    animation_counter <= 0;
                    debounce_counter0 <= 0;
                    debounce_counter1 <= 0;
                    animation <= '1';
                else
                    if prev_stable_left_button = '1' and stable_left_button = '0' then
                        if left_digit = 9 then
                            left_digit <= 0;
                        else
                            left_digit <= left_digit + 1;
                        end if;
                    end if;

                    if prev_stable_right_button = '1' and stable_right_button = '0' then
                        right_digit <= left_digit;
                    end if;
                end if;

                prev_stable_left_button <= stable_left_button;
                prev_stable_right_button <= stable_right_button;
            else
                if animation_counter = ANIMATION_TIME - 1 then
                    if left_digit = 6 then  
                        left_digit <= 0;
                        right_digit <= 0;
                        animation <= '0';
                        stable_left_button <= '1';
                        stable_right_button <= '1';
                        prev_stable_left_button <= '1';
                        prev_stable_right_button <= '1';
                    else
                        left_digit <= left_digit + 1;
                        right_digit <= right_digit + 1;
                    end if;
                    animation_counter <= 0;
                else
                    animation_counter <= animation_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- Display logic
    SegLeft: process(left_digit, animation)
    begin
        if animation = '0' then
            case left_digit is
                when 0 => display_left <= "0000001";
                when 1 => display_left <= "1001111";
                when 2 => display_left <= "0010010";
                when 3 => display_left <= "0000110";
                when 4 => display_left <= "1001100";
                when 5 => display_left <= "0100100";
                when 6 => display_left <= "0100000";
                when 7 => display_left <= "0001111";
                when 8 => display_left <= "0000000";
                when 9 => display_left <= "0000100";
                when others => display_left <= "1111111";
            end case;
        else
            case left_digit is
                when 0 => display_left <= "1111110";
                when 1 => display_left <= "1111101";
                when 2 => display_left <= "1111011";
                when 3 => display_left <= "1110111";
                when 4 => display_left <= "1101111";
                when 5 => display_left <= "1011111";
                when 6 => display_left <= "0111111";
                when others => display_left <= "1111111";
            end case;
        end if;
    end process;

    SegRight: process(right_digit, animation)
    begin
        if animation = '0' then
            case right_digit is
                when 0 => display_right <= "0000001";
                when 1 => display_right <= "1001111";
                when 2 => display_right <= "0010010";
                when 3 => display_right <= "0000110";
                when 4 => display_right <= "1001100";
                when 5 => display_right <= "0100100";
                when 6 => display_right <= "0100000";
                when 7 => display_right <= "0001111";
                when 8 => display_right <= "0000000";
                when 9 => display_right <= "0000100";
                when others => display_right <= "1111111";
            end case;
        else
            case right_digit is
                when 0 => display_right <= "1111110";
                when 1 => display_right <= "1111101";
                when 2 => display_right <= "1111011";
                when 3 => display_right <= "1110111";
                when 4 => display_right <= "1101111";
                when 5 => display_right <= "1011111";
                when 6 => display_right <= "0111111";
                when others => display_right <= "1111111";
            end case;
        end if;
    end process;

end Behavioral;
