--------------------------------------------------------------------------------
-- Projeto: [Microprocessador]
-- Descrição: Modelo de um Microprocessador (ULA)
-- Autores: 
-- Isabela Bella Bortoleto
-- Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity ula is
    Port (
        -- Duas entradas de dados de 16 bits
        in_a       : in unsigned(15 downto 0);
        in_b       : in unsigned(15 downto 0);
        
        -- Entradas para seleção da operação (Ex: 3 bits permitem até 8 operações)
        in_seletor : in  unsigned(2 downto 0);
        
        -- Uma saída de resultado de 16 bits
        out_result  : out unsigned(15 downto 0);
        
        -- flags do sorteio (BHI e BVS)

        -- BHI (Branch if Higher, unsigned): só salta caso C=1 e Z=0,
        -- ou seja, não houve borrow e o resultado não é zero (a > b)
        
        flag_z : out std_logic; -- Flag Zero
        flag_c : out std_logic; -- Flag Carry
        flag_v : out std_logic  -- Flag Overflow
    );
end entity;

architecture a_ula of ula is
    -- Sinais internos para calcular TODAS as operações simultaneamente
    signal res_soma  : unsigned(16 downto 0);
    signal res_subt  : unsigned(16 downto 0);
    signal res_and   : unsigned(15 downto 0);
    signal res_or    : unsigned(15 downto 0);

    signal not_b    : unsigned(15 downto 0);
    
    -- Sinal para guardar qual foi a operação escolhida pelo seletor
    signal resultado_final : unsigned(15 downto 0);
    
begin
    not_b <= not in_b;
    -- 1. Operacoes de soma, subtracao, AND e ...
    res_soma <= ('0' & in_a) + ('0' & in_b);
    res_subt <= ('0' & in_a) + ('0' & not_b) + 1;
    res_and  <= in_a and in_b; 
    
    -- 2. O MUX escolhe qual resultado vai para a saída final
    resultado_final <= 
        res_soma(15 downto 0)  when in_seletor = "000" else
           res_subt(15 downto 0)   when in_seletor = "001" else
           res_and        when in_seletor = "010" else
           --(in_a xor in_b)        when in_seletor = "011" else
           "0000000000000000"; -- Valor padrão se der pau
        

    --flag carry
    flag_c <= res_soma(16) when in_seletor = "000" else
              res_subt(16) when in_seletor = "001" else
              '0'; -- Para outras operações, o Carry não é relevante

    -- 3. Joga o resultado escolhido no pino de saída
    out_result <= resultado_final;

    -- 4. Cálculo das Flags combinacionais (Sem IF!)
    flag_z <= '1' when resultado_final = "0000000000000000" else 
                '0';
    

    --Flag de overflow (BVS)




end architecture;