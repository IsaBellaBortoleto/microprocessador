--------------------------------------------------------------------------------
-- Arquivo de Teste (testbench): ula_tb.vhd
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- numeric_std não é estritamente obrigatória no TB se não fizermos contas, 
-- mas é boa prática manter.
use IEEE.NUMERIC_STD.ALL; 

-- A entidade do testbench é sempre vazia
entity ula_tb is
end entity;

architecture a_ula_tb of ula_tb is

    -- 1. Declaração do Componente exato que vamos testar
    component ula
        Port (
            in_a       : in  unsigned(15 downto 0);
            in_b       : in  unsigned(15 downto 0);
            in_seletor : in  unsigned(2 downto 0);
            
            out_result : out unsigned(15 downto 0);
            flag_z     : out std_logic;
            flag_c     : out std_logic;
            flag_v     : out std_logic
        );
    end component;

    -- 2. Criação dos sinais para ligar nos pinos do componente
    -- Inicializamos com zeros para não dar aquele aviso de "Metavalue" (sinal 'U') no instante zero
    signal in_a       : unsigned(15 downto 0) := "0000000000000000";
    signal in_b       : unsigned(15 downto 0) := "0000000000000000";
    signal in_seletor : unsigned(2 downto 0)  := "000";
    
    signal out_result : unsigned(15 downto 0);
    signal flag_z     : std_logic;
    signal flag_c     : std_logic;
    signal flag_v     : std_logic;

begin

    -- 3. Instanciação da Unidade Sob Teste (UUT)
    uut: ula port map (
        in_a       => in_a,
        in_b       => in_b,
        in_seletor => in_seletor,
        out_result => out_result,
        flag_z     => flag_z,
        flag_c     => flag_c,
        flag_v     => flag_v
    );

    -- 4. Processo que gera os estímulos (Simulação)
    process
    begin
        ------------------------------------------------------------------
        -- TESTE 1: Soma Normal ("000")
        -- Esperado: out_result = 8, Z=0, C=0, V=0
        ------------------------------------------------------------------
        in_seletor <= "000"; 
        in_a <= x"0005"; -- 5 em Hexadecimal
        in_b <= x"0003"; -- 3 em Hexadecimal
        wait for 50 ns;

        ------------------------------------------------------------------
        -- TESTE 2: Testando o BHI (Subtração onde A > B)
        -- Esperado: out_result = 2, Z=0, C=1 (Sem empréstimo, logo BHI pularia)
        ------------------------------------------------------------------
        in_seletor <= "001"; -- Operação de Subtração
        in_a <= x"0005"; 
        in_b <= x"0003"; 
        wait for 50 ns;

        ------------------------------------------------------------------
        -- TESTE 3: Testando a Flag Carry/Borrow (Subtração onde A < B)
        -- Esperado: Flag C = '0' (Houve empréstimo, BHI NÃO pularia)
        ------------------------------------------------------------------
        in_seletor <= "001"; 
        in_a <= x"0003"; 
        in_b <= x"0005"; 
        wait for 50 ns;

        ------------------------------------------------------------------
        -- TESTE 4: Testando a Flag Zero (Z)
        -- Esperado: Flag Z = '1' e Flag C = '1'
        ------------------------------------------------------------------
        in_seletor <= "001"; 
        in_a <= x"000A"; -- 10
        in_b <= x"000A"; -- 10
        wait for 50 ns;

        
        ------------------------------------------------------------------
        -- TESTE 5: Testando a Flag Overflow (BVS)
        -- Somando dois números positivos grandes que estouram o limite (x7FFF)
        -- x7FFF é o maior número positivo de 16 bits (0111_1111_1111_1111).
        -- Esperado: Flag V = '1'
        ------------------------------------------------------------------
        in_seletor <= "000"; -- Soma
        in_a <= x"7FFF"; 
        in_b <= x"0001"; 
        wait for 50 ns;

        -- Fim da simulação
        wait;
    end process;

end architecture;