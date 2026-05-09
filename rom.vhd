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
        -- Programa de teste: NOP e Jump Relativo
        -- Opcode: 0000 = NOP, 1111 = JR (delta nos bits 6 downto 0)
        -- verificar os números em complemento de 2 para saltos positivos e negativos

        0 => "0000000000000000", -- NOP
        1 => "0000000000000000", -- NOP
        2 => "1111000000000011", -- JR +3 (pula pra endereço 5)
        3 => "0000000000000000", -- NOP (nunca executa)
        4 => "0000000000000000", -- NOP (nunca executa)
        5 => "0000000000000000", -- NOP
        6 => "1111000001111100", -- JR -4 (volta pra endereço 2, loop!)

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