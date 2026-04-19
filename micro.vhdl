--------------------------------------------------------------------------------
-- Projeto: [Microprocessador]
-- Descrição: Modelo de um Microprocessador (ULA)
-- Autor: 
-- Isabela Bella Bortoleto
-- Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity ULA is
    Port (
        -- Duas entradas de dados de 16 bits
        A       : in  std_logic_vector(15 downto 0);
        B       : in  std_logic_vector(15 downto 0);
        
        -- Entradas para seleção da operação (Ex: 3 bits permitem até 8 operações)
        Seletor : in  std_logic_vector(2 downto 0);
        
        -- Uma saída de resultado de 16 bits
        Result  : out std_logic_vector(15 downto 0);
        
        -- Duas ou mais saídas de sinalização de 1 bit (Flags)
        -- (Substitua pelos nomes das flags do seu sorteio, ex: Zero, Carry, Overflow)
        Flag_1  : out std_logic;
        Flag_2  : out std_logic
    );
end ULA;

architecture Combinacional of ULA is
    -- Sinal interno para guardar o resultado temporariamente (útil para calcular as flags)
    signal res_interno : std_logic_vector(15 downto 0);
    
begin
    -- Processo combinacional: a lista de sensibilidade tem as entradas
    process(A, B, Seletor)
    begin
        -- Valores padrão para evitar a criação de "Latches" indesejados
        res_interno <= (others => '0');
        Flag_1 <= '0';
        Flag_2 <= '0';
        
        -- Estrutura de decisão para a operação baseada no Seletor
        case Seletor is
            when "000" =>
                -- Exemplo: Implemente a Operação 1 aqui
                -- res_interno <= std_logic_vector(signed(A) + signed(B));
                
            when "001" =>
                -- Exemplo: Implemente a Operação 2 aqui
                
            when others =>
                -- Comportamento padrão caso o seletor não seja reconhecido
                res_interno <= (others => '0');
        end case;
        
        -- Exemplo de como você calcularia uma flag (ex: Flag Zero)
        -- if res_interno = x"0000" then
        --     Flag_1 <= '1';
        -- end if;
        
    end process;

    -- Passa o valor do sinal interno para a saída real do componente
    Result <= res_interno;

end Combinacional;