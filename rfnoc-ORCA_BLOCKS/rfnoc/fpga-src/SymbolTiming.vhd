library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SymbolTiming is
port (
    clk : in std_logic;
    rst : in std_logic; 
    -- axi4 stream slave (data input)
    i_data_TDATA  : in  std_logic_vector(32-1 downto 0);
    i_data_TVALID : in  std_logic;
    i_data_TREADY : out std_logic;
    i_data_TLAST : in std_logic;
    -- axi4 stream master (data output)
    o_data_TDATA  : out std_logic_vector(32-1 downto 0);
    o_data_TVALID : out std_logic;
    o_data_TREADY : in  std_logic;
    o_data_TLAST : out std_logic
);
end entity; 

architecture rtl of SymbolTiming is

  constant n : integer := 2;
  signal sample_cnt, pkt_cnt : std_logic;
  signal i_data_TREADY_s : std_logic;

begin

  process(clk)
  begin 
    if rising_edge(clk) then
      if rst = '1' then
        sample_cnt <= '1';
       	pkt_cnt    <= '1';
      else
      	if (i_data_TVALID='1' and i_data_TREADY_s='1') then
        	sample_cnt <= not(sample_cnt);
      	end if;
	      if (i_data_TVALID='1' and i_data_TREADY_s='1' and i_data_TLAST='1') then
          pkt_cnt <= not(pkt_cnt);
        end if;
      end if;
    end if;
  end process;

  i_data_TREADY_s <= o_data_TREADY or sample_cnt;
  i_data_TREADY <= i_data_TREADY_s;
  o_data_TVALID <= i_data_TVALID and not(sample_cnt);
  o_data_TDATA  <= i_data_TDATA;
  o_data_TLAST  <= i_data_TLAST  and not(pkt_cnt);

end architecture;
