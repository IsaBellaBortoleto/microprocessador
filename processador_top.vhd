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
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr_en_banco : IN STD_LOGIC;
        wr_en_acc : IN STD_LOGIC;
        sel_imm : IN STD_LOGIC;
        sel_ld : IN STD_LOGIC;
        in_seletor : IN unsigned(1 DOWNTO 0);

        cte_ext : IN unsigned(15 DOWNTO 0);
        write_sel : IN unsigned(3 DOWNTO 0);
        read_sel : IN unsigned(3 DOWNTO 0);

        flag_z : OUT STD_LOGIC;
        flag_c : OUT STD_LOGIC;
        flag_v : OUT STD_LOGIC;

        acc_out : OUT unsigned(15 DOWNTO 0);
        banco_out : OUT unsigned(15 DOWNTO 0)
    );
END;

ARCHITECTURE a_processador_top OF processador_top IS

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
    END COMPONENT;

    SIGNAL fio_out_acc : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_banco : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_b_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_data_banco : unsigned(15 DOWNTO 0);

    SIGNAL is_add : std_logic;
    SIGNAL is_sub : std_logic;

BEGIN
    -- aqui é pra evitar o ADDI permitido
    is_add <= '1' when in_seletor = "00" else '0';
    -- SUBI bloqueado
    is_sub <= '1' when in_seletor = "01" else '0';

    fio_in_b_ula <= 
        cte_ext WHEN (sel_imm = '1' AND is_add = '1') ELSE
        fio_out_banco;

    fio_in_data_banco <= cte_ext WHEN sel_ld = '1' ELSE
        fio_out_acc;

    inst_ula : ula PORT MAP(
        in_a => fio_out_acc,
        in_b => fio_in_b_ula,
        in_seletor => in_seletor,
        out_result => fio_out_ula,
        flag_z => flag_z,
        flag_c => flag_c,
        flag_v => flag_v
    );

    inst_banco : banco_regs PORT MAP(
        data_in => fio_in_data_banco,
        data_out => fio_out_banco,
        clk => clk,
        rst => rst,
        wr_en => wr_en_banco,
        write_sel => write_sel,
        read_sel => read_sel
    );

    inst_acc : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => (wr_en_acc AND (is_add OR is_sub)),
        data_in => fio_out_ula,
        data_out => fio_out_acc
    );

    acc_out <= fio_out_acc;
    banco_out <= fio_out_banco;

END ARCHITECTURE;