--------------------------------------------------------------------------------
-- Arquivo de Teste (testbench): processador_top_tb.vhd
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY processador_top_tb IS
END ENTITY;

ARCHITECTURE a_processador_top_tb OF processador_top_tb IS

    -- 1. Declaração do Componente exato que vamos testar
    COMPONENT processador_top
        PORT (
            -- Controle
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en_banco : IN STD_LOGIC;
            wr_en_acc : IN STD_LOGIC;
            sel_imm : IN STD_LOGIC; -- MUX: seleciona constante (1) ou banco (0) pra entrada B da ULA
            sel_ld : IN STD_LOGIC; -- MUX: seleciona constante (1) ou acumulador (0) pra escrita no banco
            in_seletor : IN unsigned(1 DOWNTO 0);

            -- Dados
            cte_ext : IN unsigned(15 DOWNTO 0);
            write_sel : IN unsigned(3 DOWNTO 0);
            read_sel : IN unsigned(3 DOWNTO 0);

            -- Flags
            flag_z : OUT STD_LOGIC;
            flag_c : OUT STD_LOGIC;
            flag_v : OUT STD_LOGIC;

            -- Saídas observáveis (para verificação no testbench)
            acc_out : OUT unsigned(15 DOWNTO 0);
            banco_out : OUT unsigned(15 DOWNTO 0)

        );

    END COMPONENT;

    
    -- 2. Sinais para ligar nos pinos do componente
    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';
    
    SIGNAL clk, rst : STD_LOGIC;
    SIGNAL wr_en_banco, wr_en_acc : STD_LOGIC;
    SIGNAL sel_imm, sel_ld : STD_LOGIC;
    SIGNAL in_seletor : unsigned(1 DOWNTO 0);
    SIGNAL cte_ext : unsigned(15 DOWNTO 0);
    SIGNAL write_sel, read_sel : unsigned(3 DOWNTO 0);
    SIGNAL flag_z, flag_c, flag_v : STD_LOGIC;
    SIGNAL acc_out, banco_out : unsigned(15 DOWNTO 0);

BEGIN

    -- 3. Instanciação da Unidade Sob Teste (UUT)
    uut : processador_top PORT MAP(
        clk => clk,
        rst => rst,
        wr_en_banco => wr_en_banco,
        wr_en_acc => wr_en_acc,
        sel_imm => sel_imm,
        sel_ld => sel_ld,
        in_seletor => in_seletor,
        cte_ext => cte_ext,
        write_sel => write_sel,
        read_sel => read_sel,
        flag_z => flag_z,
        flag_c => flag_c,
        flag_v => flag_v,
        acc_out => acc_out,
        banco_out => banco_out
    );
    -- 4. Processo de Reset
    reset_global : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR period_time * 2;
        rst <= '0';
        WAIT;
    END PROCESS;

    -- 5. Processo de Tempo Total de Simulação
    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us;
        finished <= '1';
        WAIT;
    END PROCESS;

    -- 6. Processo de Clock
    clk_proc : PROCESS
    BEGIN
        WHILE finished /= '1' LOOP
            clk <= '0';
            WAIT FOR period_time / 2;
            clk <= '1';
            WAIT FOR period_time / 2;
        END LOOP;
        WAIT;
    END PROCESS;

    -- 7. Processo de Testes
    PROCESS
    BEGIN
        -- Espera o reset terminar (2 ciclos de clock = 200 ns)
        WAIT FOR 200 ns;

        -- Inicializa sinais em valores seguros
        wr_en_banco <= '0';
        wr_en_acc <= '0';
        sel_imm <= '0';
        sel_ld <= '0';
        in_seletor <= "00";
        cte_ext <= x"0000";
        write_sel <= "0000";
        read_sel <= "0000";
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 1: LD R3, 42
        -- Carrega a constante 42 direto no registrador R3
        -- Esperado: banco_out(R3) = 42
        ------------------------------------------------------------------
        cte_ext <= x"002A";      -- 42 em hexadecimal
        sel_ld <= '1';           -- MUX banco: seleciona constante
        write_sel <= "0011";     -- Escreve no R3
        wr_en_banco <= '1';     -- Habilita escrita no banco
        wr_en_acc <= '0';       -- Acumulador não muda
        sel_imm <= '0';         -- Não importa (ULA não é usada)
        in_seletor <= "00";     -- Não importa
        WAIT FOR period_time;
 

        ------------------------------------------------------------------
        -- TESTE 2: ADD A, R3
        -- Acumulador = A + R3 = 0 + 42 = 42
        -- Esperado: acc_out = 42, Z=0, C=0, V=0
        ------------------------------------------------------------------
        wr_en_banco <= '0';     -- Não escreve no banco
        sel_ld <= '0';          -- Não importa
        sel_imm <= '0';         -- MUX ULA: seleciona banco (R3)
        in_seletor <= "00";     -- ADD
        read_sel <= "0011";     -- Lê R3
        wr_en_acc <= '1';       -- Grava resultado no acumulador
        cte_ext <= x"0000";     -- Não importa
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 3:  ADDI A, 8
        -- Acumulador = A + 8 = 42 + 8 = 50
        -- Esperado: acc_out = 50, Z=0, C=0, V=0
        ----------------------------------------------------------------
        cte_ext <= x"0008";     -- Constante 8
        sel_imm <= '1';         -- MUX ULA: seleciona constante
        in_seletor <= "00";     -- ADD
        wr_en_acc <= '1';       -- Grava no acumulador
        wr_en_banco <= '0';     -- Não escreve no banco
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 4: SUB A, R3
        -- Acumulador = A - R3 = 50 - 42 = 8
        -- Esperado: acc_out = 8, Z=0, C=1 (sem borrow, 50>=42), V=0
        ------------------------------------------------------------------
        sel_imm <= '0';         -- MUX ULA: seleciona banco (R3)
        in_seletor <= "01";     -- SUB
        read_sel <= "0011";     -- Lê R3
        wr_en_acc <= '1';       -- Grava no acumulador
        wr_en_banco <= '0';     -- Não escreve no banco
        cte_ext <= x"0000";     -- Não importa
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 5: CMPR A, R3
        -- Compara A com R3: 8 - 42 (não grava resultado)
        -- Esperado: acc_out = 8 (não muda!), Z=0, C=0 (8<42), V=0
        -- BHI não saltaria (C=0)
        ------------------------------------------------------------------
        sel_imm <= '0';         -- MUX ULA: seleciona banco (R3)
        in_seletor <= "01";     -- SUB (CMPR = SUB sem gravar)
        read_sel <= "0011";     -- Lê R3
        wr_en_acc <= '0';       -- NÃO grava no acumulador
        wr_en_banco <= '0';     -- Não escreve no banco
        cte_ext <= x"0000";     -- Não importa
        WAIT FOR period_time;

        -- Fim da simulação
        WAIT;
    END PROCESS;

END ARCHITECTURE;