library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_adder is
    port (
       KEY: in std_logic_vector(1 downto 0);
       SW: in unsigned(9 downto 0);
       LEDR: out unsigned(8 downto 0)
    );
end binary_adder;

architecture main of binary_adder is
begin
    adder_inst: entity work.adder
        port map(
            SW(7 downto 0),
            KEY(1),
            KEY(0),
            SW(9),
            LEDR
        );

end main;

