--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: Top Level - Banco de Registradores + Acumulador + ULA
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY processador_top IS
    PORT (
        -- Controle
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr_en_banco : IN STD_LOGIC;
        wr_en_acc : IN STD_LOGIC;
        sel_imm : IN STD_LOGIC;  -- MUX: seleciona constante (1) ou banco (0) pra entrada B da ULA
        sel_ld : IN STD_LOGIC;   -- MUX: seleciona constante (1) ou acumulador (0) pra escrita no banco
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

END;

ARCHITECTURE a_processador_top OF processador_top IS

    -- 1. Declaração dos 3 Componentes (ULA, Banco e Reg16bits)
    COMPONENT ula
        PORT (
            in_a : IN unsigned(15 DOWNTO 0);
            in_b : IN unsigned(15 DOWNTO 0);
            in_seletor : IN unsigned(1 DOWNTO 0);

            out_result : OUT unsigned(15 DOWNTO 0);
            flag_z : OUT STD_LOGIC;
            flag_c : OUT STD_LOGIC;
            flag_v : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT banco_regs
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;

            write_sel : IN unsigned(3 DOWNTO 0);
            read_sel : IN unsigned(3 DOWNTO 0);
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT reg16bits
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT; -- Este será o nosso Acumulador

    -- 2. Declaração dos "Fios" (Sinais Internos)
    SIGNAL fio_out_acc : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_banco : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_b_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_data_banco : unsigned(15 DOWNTO 0);

BEGIN

        -- 3. MUXes
    -- MUX 1: entrada B da ULA = constante (ADDI) ou registrador do banco (ADD/SUB/CMPR)
    fio_in_b_ula <= cte_ext WHEN sel_imm = '1' ELSE
        fio_out_banco;

    -- MUX 2: entrada do banco = constante (LD) ou acumulador (MOV Rn,A)
    fio_in_data_banco <= cte_ext WHEN sel_ld = '1' ELSE
        fio_out_acc;

    -- 4. Instanciação da ULA
    inst_ula : ula PORT MAP(
        in_a => fio_out_acc, -- A entrada A da ULA é sempre o Acumulador
        in_b => fio_in_b_ula, -- A entrada B vem do seu MUX
        in_seletor => in_seletor,
        out_result => fio_out_ula,
        flag_z => flag_z,
        flag_c => flag_c,
        flag_v => flag_v
    );

    -- 5. Instanciação do Banco de Registradores
    inst_banco : banco_regs PORT MAP(
        data_in => fio_in_data_banco, -- Vem do seu segundo MUX
        data_out => fio_out_banco,
        clk => clk,
        rst => rst,
        wr_en => wr_en_banco,
        write_sel => write_sel,
        read_sel => read_sel
    );

   -- 6. Instanciação do Acumulador(ACC)
    inst_acc : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => wr_en_acc,
        data_in => fio_out_ula,
        data_out => fio_out_acc
    );

    -- 7. Saídas observáveis
    acc_out <= fio_out_acc;
    banco_out <= fio_out_banco;
END ARCHITECTURE;