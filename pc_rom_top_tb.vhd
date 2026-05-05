LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_rom_top_tb IS
END;

ARCHITECTURE a_pc_rom_top_tb OF pc_rom_top_tb IS
    COMPONENT pc_rom_top
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc_out : OUT unsigned(6 DOWNTO 0);
            rom_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL clk, rst : STD_LOGIC;
    SIGNAL pc_out : unsigned(6 DOWNTO 0);
    SIGNAL rom_out : unsigned(15 DOWNTO 0);

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : pc_rom_top PORT MAP(
        clk => clk,
        rst => rst,
        pc_out => pc_out,
        rom_out => rom_out
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
    -- Após reset: pc_out = x"00" (bin: 0000000), rom_out = x"0002" (bin: 0000000000000010)
    -- Clock 1:   pc_out = x"01" (bin: 0000001), rom_out = x"0800" (bin: 0000100000000000)
    -- Clock 2:   pc_out = x"02" (bin: 0000010), rom_out = x"0000" (bin: 0000000000000000)
    -- Clock 3:   pc_out = x"03" (bin: 0000011), rom_out = x"0000" (bin: 0000000000000000)
    -- Clock 4:   pc_out = x"04" (bin: 0000100), rom_out = x"0800" (bin: 0000100000000000)
    -- Clock 5:   pc_out = x"05" (bin: 0000101), rom_out = x"0002" (bin: 0000000000000010)
    -- A partir do endereço 11: rom_out = x"0000" (endereços vazios)
END ARCHITECTURE;