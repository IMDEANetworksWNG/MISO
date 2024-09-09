--
-- CFOC.vhd
-- 
-- Copyright 2019 IMDEA Networks Institute - Spain

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CFOC is
port (
    ap_clk : in std_logic;
    ap_rst_n : in std_logic; 
    -- axi4 stream slave (data input)
    i_data_TDATA  : in  std_logic_vector(32-1 downto 0);
    i_data_TVALID : in  std_logic;
    i_data_TREADY : out std_logic;
    i_data_TLAST : in std_logic;
    -- axi4 stream master (data output)
    o_data_TDATA  : out std_logic_vector(32-1 downto 0);
    o_data_TVALID : out std_logic;
    o_data_TREADY : in  std_logic;
    o_data_TLAST : out std_logic;
    -- parameter signals 
    SEL_OUT : in std_logic_vector(1 downto 0);
    NPER : in std_logic_vector(7 downto 0);
    NITER : in std_logic_vector(15 downto 0));
end entity; 

architecture rtl of CFOC is

  --COMPONENTS
  component CFOEcordic is
  port (
      ap_clk : IN STD_LOGIC;
      ap_rst_n : IN STD_LOGIC;
      i_data_V_V_TDATA : IN STD_LOGIC_VECTOR (31 downto 0);
      i_data_V_V_TVALID : IN STD_LOGIC;
      i_data_V_V_TREADY : OUT STD_LOGIC;
      o_data_V_V_TDATA : OUT STD_LOGIC_VECTOR (23 downto 0);
      o_data_V_V_TVALID : OUT STD_LOGIC;
      o_data_V_V_TREADY : IN STD_LOGIC;
      n_iter_V : IN STD_LOGIC_VECTOR (15 downto 0)--;
  );
  end component; 

  component CFOCddfs is
  port (
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    i_data_TDATA : IN STD_LOGIC_VECTOR (31 downto 0);
    i_data_TVALID : IN STD_LOGIC;
    i_data_TREADY : OUT STD_LOGIC;
    i_data_TLAST : IN STD_LOGIC_VECTOR (0 downto 0);
    o_data_TDATA : OUT STD_LOGIC_VECTOR (31 downto 0);
    o_data_TVALID : OUT STD_LOGIC;
    o_data_TREADY : IN STD_LOGIC;
    o_data_TLAST : OUT STD_LOGIC_VECTOR (0 downto 0);
    FCW_V : IN STD_LOGIC_VECTOR (32 downto 0)
  );
  end component;

  constant Gb128_length : integer := 128;
  constant NSPS : integer := 2;
  constant COR_SIZE : integer := Gb128_length*NSPS;
  constant one_over_2pi : signed(11 downto 0) := "010100011000"; -- round(1/(2*pi)*2^13)

  --b0:
  signal b0_datain_i, b0_datain_q : std_logic_vector(14 downto 0); -- 14 bits inputs
  signal b0_PD_FLAG : std_logic; -- 1 bit flag
  signal b0_data_TVALID, b0_data_TLAST : std_logic;

  --b1: INPUT STATE MACHINE
  type state_type is (st1_WAIT, st2_COUNT, st3_ACC, st4_CORDIC, st5_WAIT_PD_LOW);
  signal b1_state : state_type; 
  signal b1_counter_NPER, b1_counter_COR_SIZE : integer := 0;
  signal b1_ACC_i, b1_ACC_q : std_logic_vector(14+4-1 downto 0);
  signal b1_CORDICin_i, b1_CORDICin_q : std_logic_vector(14+4-1 downto 0);
  signal b1_CORDIC_en, b1_CORDIC_en_r : std_logic := '0';

  --b2: cordic
  signal b2_cordic_idata : std_logic_vector(31 downto 0);
  signal b2_angle_est, b2_angle_est_r : std_logic_vector(23 downto 0);
  signal b2_FCW1 : std_logic_vector(24+12-1 downto 0);
  signal b2_FCW2 : std_logic_vector(32 downto 0);
  signal b2_angle_est_valid, b2_angle_est_valid_r : std_logic;
  signal b2_iready : std_logic;

  --b3: DDFS
  signal b3_ddfs_out : std_logic_vector(31 downto 0);
  signal b3_ddfs_out_valid, b3_ddfs_out_last : std_logic;
  signal b3_SIGNAL_IN : std_logic_vector(31 downto 0);

begin

  --b0: process PD_FLAG
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      b0_datain_i <= i_data_TDATA(31 downto 17);
      b0_datain_q <= i_data_TDATA(15 downto 1);
      b0_PD_FLAG <= i_data_TDATA(0);
      b0_data_TVALID <= i_data_TVALID;
      b0_data_TLAST <= i_data_TLAST;
    end if;
  end process;

  --b1: state machine for packet_detected_flag
  b8_sm : process(ap_clk)
  begin
    if(rising_edge(ap_clk)) then
      if ap_rst_n = '0' then
        b1_state <= st1_WAIT;
        b1_counter_NPER <= 0;
        b1_counter_COR_SIZE <= 0;
        b1_ACC_i <= (others => '0');
        b1_ACC_q <= (others => '0');
      elsif b0_data_TVALID = '1' then
        case (b1_state) is
          when st1_WAIT =>
            if b0_PD_FLAG = '1' then
              b1_state <= st3_ACC;
            end if;
            b1_ACC_i <= (others => '0');
            b1_ACC_q <= (others => '0');
            b1_CORDIC_en <= '0';
          when st2_COUNT =>
            if b1_counter_COR_SIZE = COR_SIZE-1 then
              b1_counter_COR_SIZE <= 0;
              b1_state <= st3_ACC;
            else
              b1_counter_COR_SIZE <= b1_counter_COR_SIZE + 1;    
            end if;
            b1_CORDIC_en <= '0';
          when st3_ACC => 
            if b1_counter_NPER < signed(NPER) then
              b1_counter_NPER <= b1_counter_NPER + 1;
              b1_state <= st2_COUNT;
            else
              b1_counter_NPER <= 0;
              b1_state <= st4_CORDIC;
            end if;
            b1_ACC_i <= std_logic_vector(signed(b1_ACC_i) + resize(signed(b0_datain_i),b1_ACC_i'length));
            b1_ACC_q <= std_logic_vector(signed(b1_ACC_q) + resize(signed(b0_datain_q),b1_ACC_q'length));
            b1_CORDIC_en <= '0';
          when st4_CORDIC => 
            b1_state <= st5_WAIT_PD_LOW;
            b1_CORDICin_i <= b1_ACC_i;
            b1_CORDICin_q <= b1_ACC_q;
            b1_CORDIC_en <= '1';
          when st5_WAIT_PD_LOW =>
            if b0_PD_FLAG = '0' then
              b1_state <= st1_WAIT;
            end if;
            b1_CORDIC_en <= '0';
          when others =>
            b1_state <= st1_WAIT;
            b1_CORDIC_en <= '0';
        end case;
      end if;
    end if;
  end process;

  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if b1_CORDIC_en = '1' then
        b2_cordic_idata <= b1_CORDICin_i(17 downto 2) & b1_CORDICin_q(17 downto 2);
        b1_CORDIC_en_r <= '1';
      elsif b2_iready = '1' and b1_CORDIC_en_r = '1' then
        b2_cordic_idata <= (others => '0');
        b1_CORDIC_en_r <= '0';
      end if;
    end if;
  end process;

  b2_CFOEcordic : component CFOEcordic  port map(
    ap_clk => ap_clk,
    ap_rst_n => ap_rst_n,
    i_data_V_V_TDATA => b2_cordic_idata,
    i_data_V_V_TVALID => b1_CORDIC_en_r, --b1_CORDIC_en,
    i_data_V_V_TREADY => b2_iready,
    o_data_V_V_TDATA => b2_angle_est,
    o_data_V_V_TVALID => b2_angle_est_valid,
    o_data_V_V_TREADY => '1',
    n_iter_V => NITER--,
--    n_iter_V_ap_vld => '1'
  );

  process(ap_clk)  
  begin
    if rising_edge(ap_clk) then
      if ap_rst_n = '0' then
        b2_FCW1 <= (others => '0');
        b2_angle_est_r <= (others => '0');
      else
        b2_angle_est_valid_r <= b2_angle_est_valid;
        if b2_angle_est_valid = '1' then
          b2_FCW1 <= std_logic_vector(signed(b2_angle_est) * one_over_2pi);
          b2_angle_est_r <= b2_angle_est;
        end if;
      end if;
    end if;
  end process;
  b2_FCW2 <= b2_FCW1(35 downto 3);

  b3_SIGNAL_IN <= "011111111111111" & "0" & "011111111111111"  & b0_PD_FLAG  when SEL_OUT = "01" else b0_datain_i & '0' & b0_datain_q & b0_PD_FLAG;
  b3_CFOC_ddfs : component CFOCddfs port map(
    ap_clk => ap_clk,
    ap_rst_n => ap_rst_n,
    i_data_TDATA => b3_SIGNAL_IN,
    i_data_TVALID => b0_data_TVALID,
    i_data_TREADY => open,
    i_data_TLAST(0) => b0_data_TLAST,
    o_data_TDATA => b3_ddfs_out,
    o_data_TVALID => b3_ddfs_out_valid,
    o_data_TREADY => '1',
    o_data_TLAST(0) => b3_ddfs_out_last,
    FCW_V => b2_FCW2--,
  );
  
  output_process : process(ap_clk)  
  begin
    if rising_edge(ap_clk) then
      if SEL_OUT = "00" or SEL_OUT = "01" then
        o_data_TDATA <= b3_ddfs_out;
      elsif SEL_OUT = "10" then
        o_data_TDATA <= std_logic_vector(resize(signed(b2_angle_est_r),o_data_TDATA'length));
      end if;
    end if;
      o_data_TVALID <= b3_ddfs_out_valid;
      o_data_TLAST <= b3_ddfs_out_last and b3_ddfs_out_valid;
  end process;

  i_data_TREADY <= '1';

end architecture;
