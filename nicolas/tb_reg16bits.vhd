library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg16bits is
end entity;

architecture sim of tb_reg16bits is

   signal clk      : std_logic := '0';
   signal rst      : std_logic := '0';
   signal wr_en    : std_logic := '0';
   signal data_in  : unsigned(15 downto 0) := (others => '0');
   signal data_out : unsigned(15 downto 0);

begin

   -- DUT
   uut: entity work.reg16bits
      port map (
         clk      => clk,
         rst      => rst,
         wr_en    => wr_en,
         data_in  => data_in,
         data_out => data_out
      );

   -- Clock (seu modelo)
   clk_process: process
   begin
      clk <= '0';
      wait for 50 ns;
      clk <= '1';
      wait for 50 ns;
   end process;

   -- Estímulos (sem while)
   stim_proc: process
   begin
      -- Reset
      rst <= '1';
      wait for 100 ns;
      rst <= '0';

      -- Escrita 1
      wr_en <= '1';
      data_in <= to_unsigned(10, 16);
      wait for 100 ns;

      -- Escrita 2
      data_in <= to_unsigned(25, 16);
      wait for 100 ns;

      -- Desabilita escrita
      wr_en <= '0';
      data_in <= to_unsigned(50, 16);
      wait for 100 ns;

      wait; -- encerra simulação
   end process;

end architecture;