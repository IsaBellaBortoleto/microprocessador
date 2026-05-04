--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: ROM de 128 palavras de 16 bits,  'Leitura da ROM': ['síncrona']
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY rom IS
    PORT (
        clk : IN STD_LOGIC;
        endereco : IN unsigned(6 DOWNTO 0);
        dado : OUT unsigned(15 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE a_rom OF rom IS
    TYPE mem IS ARRAY (0 TO 127) OF unsigned(15 DOWNTO 0);
    CONSTANT conteudo_rom : mem := (
        -- caso endereco => conteudo
        0 => "0000000000000010",
        1 => "0000100000000000",
        2 => "0000000000000000",
        3 => "0000000000000000",
        4 => "0000100000000000",
        5 => "0000000000000010",
        6 => "0000111100000011",
        7 => "0000000000000010",
        8 => "0000000000000010",
        9 => "0000000000000000",
        10 => "0000000000000000",
        -- abaixo: casos omissos => (zero em todos os bits)
        OTHERS => (OTHERS => '0')
    );
BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            dado <= conteudo_rom(to_integer(endereco));
        END IF;
    END PROCESS;
END ARCHITECTURE;