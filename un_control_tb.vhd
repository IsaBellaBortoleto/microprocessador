--------------------------------------------------------------------------------
-- Arquivo de Teste (testbench da unidade de controle): un_control_tb.vhd
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY un_control_tb IS
END;

ARCHITECTURE a_un_control_tb OF un_control_tb IS
    COMPONENT un_control
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc_out : OUT unsigned(6 DOWNTO 0);
            rom_out : OUT unsigned(15 DOWNTO 0);
            estado_out : OUT STD_LOGIC
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL clk, rst,estado_out : STD_LOGIC;
    SIGNAL pc_out : unsigned(6 DOWNTO 0);
    SIGNAL rom_out : unsigned(15 DOWNTO 0);

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : un_control PORT MAP(
        clk => clk,
        rst => rst,
        pc_out => pc_out,
        rom_out => rom_out,
        estado_out => estado_out
    );
    reset_global : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR period_time * 2;
        rst <= '0';
        WAIT;
    END PROCESS;

    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us;
        finished <= '1';
        WAIT;
    END PROCESS sim_time_proc;
    clk_proc : PROCESS
    BEGIN
        WHILE finished /= '1' LOOP
            clk <= '0';
            WAIT FOR period_time/2;
            clk <= '1';
            WAIT FOR period_time/2;
        END LOOP;
        WAIT;
    END PROCESS clk_proc;

    -- No gtkwave, verificar:
    -- Cada instrução leva 2 clocks: estado 0 (Fetch) + estado 1 (Execute)
    -- O PC só muda no estado 1
    --
    -- Clock 1: estado=0 (Fetch),   PC = x"00" (bin: 0000000), ROM lê endereço 0 (NOP)
    -- Clock 2: estado=1 (Execute), PC → x"01", NOP: só incrementa
    -- Clock 3: estado=0 (Fetch),   PC = x"01", ROM lê endereço 1 (NOP)
    -- Clock 4: estado=1 (Execute), PC → x"02", NOP: só incrementa
    -- Clock 5: estado=0 (Fetch),   PC = x"02", ROM lê endereço 2 (JR +3)
    -- Clock 6: estado=1 (Execute), PC → x"05", JR: PC = 2 + 3 = 5
    -- Clock 7: estado=0 (Fetch),   PC = x"05", ROM lê endereço 5 (NOP)
    -- Clock 8: estado=1 (Execute), PC → x"06", NOP: só incrementa
    -- Clock 9: estado=0 (Fetch),   PC = x"06", ROM lê endereço 6 (JR -4)
    -- Clock 10: estado=1 (Execute), PC → x"02", JR: PC = 6 + (-4) = 2
    -- ... loop: endereços 2 → 5 → 6 → 2 → 5 → 6 → ...
END ARCHITECTURE;