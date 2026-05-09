--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: Unidade de controle com NOP e Jump Relativo
--'Saltos': 'Incondicional é relativo e condicional é absoluto
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY un_control IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pc_out : OUT unsigned(6 DOWNTO 0);
        rom_out : OUT unsigned(15 DOWNTO 0);
        estado_out : OUT STD_LOGIC;
        ir_out : OUT unsigned(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_un_control OF un_control IS

    -- Componentes
    COMPONENT pc
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(6 DOWNTO 0);
            data_out : OUT unsigned(6 DOWNTO 0)
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

    COMPONENT rom
        PORT (
            clk : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            dado : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT maquina_estados
        PORT (
            clk_i : IN STD_LOGIC;
            rst_i : IN STD_LOGIC;
            estado_o : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Sinais internos
    SIGNAL estado_s : STD_LOGIC;
    SIGNAL fio_pc_out : unsigned(6 DOWNTO 0);
    SIGNAL fio_pc_in : unsigned(6 DOWNTO 0);
    SIGNAL fio_rom_dado : unsigned(15 DOWNTO 0);
    SIGNAL opcode : unsigned(3 DOWNTO 0);
    SIGNAL jump_en : STD_LOGIC;
    SIGNAL pc_wr_en : STD_LOGIC;
    SIGNAL fio_ir_out : unsigned(15 DOWNTO 0);
    SIGNAL ir_wr_en : STD_LOGIC;
BEGIN

    -- Instanciações
    inst_pc : pc PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => pc_wr_en,
        data_in => fio_pc_in,
        data_out => fio_pc_out
    );

    inst_rom : rom PORT MAP(
        clk => clk,
        endereco => fio_pc_out,
        dado => fio_rom_dado
    );

    inst_maq : maquina_estados PORT MAP(
        clk_i => clk,
        rst_i => rst,
        estado_o => estado_s
    );
    inst_ir : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => ir_wr_en,
        data_in => fio_rom_dado,
        data_out => fio_ir_out
    );

    ir_wr_en <= '1' WHEN estado_s = '0' ELSE
    '0';
    -- Decodificação: opcode nos 4 bits MSB
    opcode <= fio_ir_out(15 DOWNTO 12);

    -- Detecta jump: opcode 1111
    jump_en <= '1' WHEN opcode = "1111" ELSE
    '0';

    -- PC só atualiza no estado 1 (Execute)
    pc_wr_en <= '1' WHEN estado_s = '1' ELSE
    '0';

    -- MUX do PC: jump relativo (PC + delta) ou incremento (PC + 1)
    fio_pc_in <= fio_pc_out + fio_ir_out(6 DOWNTO 0) WHEN jump_en = '1' ELSE
    fio_pc_out + 1;

    -- Saídas observáveis
    pc_out <= fio_pc_out;
    rom_out <= fio_rom_dado;
    estado_out <= estado_s;
    ir_out <= fio_ir_out;

END ARCHITECTURE;