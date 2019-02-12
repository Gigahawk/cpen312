library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bcd_adder is
    port (
       KEY: in std_logic_vector(1 downto 0);
       SW: in unsigned(9 downto 0);
       LEDR: out unsigned(9 downto 0);
       HEX0: out unsigned(6 downto 0);
       HEX1: out unsigned(6 downto 0);
       HEX2: out unsigned(6 downto 0);
       HEX3: out unsigned(6 downto 0);
       HEX4: out unsigned(6 downto 0);
       HEX5: out unsigned(6 downto 0)
    );
end bcd_adder;

architecture main of bcd_adder is
begin
    adder_inst: entity work.adder
        port map(
            SW(7 downto 4),
            SW(3 downto 0),
            KEY(1),
            KEY(0),
            SW(9),
            LEDR(9),
            HEX0,
            HEX1,
            HEX2,
            HEX3,
            HEX4,
            HEX5
        );

end main;

