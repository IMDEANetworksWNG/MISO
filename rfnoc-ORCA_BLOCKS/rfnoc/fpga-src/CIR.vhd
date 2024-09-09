--
-- CIR.vhd
-- 
-- Copyright 2019 IMDEA Networks Institute - Spain

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.GOLAY_SEQ_pkg.all;

entity CIR is
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
    SEL_OUT : in std_logic
);
end entity; 

architecture rtl of CIR is

  constant Gb128_length : integer := 128;
  constant NSPS : integer := 1;
  constant COR_SIZE : integer := Gb128_length*NSPS;
  constant log2_COR_SIZE : integer := 7;

  --b0:
  type SR_TYPE128 is array (0 to COR_SIZE-1) of std_logic_vector (30-1 downto 0);
  type SR_TYPE192 is array (0 to COR_SIZE+64-1) of std_logic_vector (30-1 downto 0);
  signal b0_BUFFER_A : SR_TYPE128 := (others => (others => '0'));
  signal b0_data_TVALID, b0_data_TLAST : std_logic;
  signal b0_CEF_FLAG : std_logic;
  
  --b1:
  type b1_state_type is (st1_WAIT, st2_count128, st3_count9, st4_genOUT);
  type a128x15std is array (0 to COR_SIZE-1) of std_logic_vector (15-1 downto 0);
  signal b1_state : b1_state_type;
  signal b1_count128, b1_count128_r, b1_count128_rr : integer := 0;
  signal b1_count9, b1_count9_r, b1_count9_rr : integer := 0;
  signal b1_BUFFER_B : SR_TYPE192 := (others => (others => '0'));
  signal b1_BUFFER_B_SHORT_i : a128x15std := (others => (others => '0'));
  signal b1_BUFFER_B_SHORT_q : a128x15std := (others => (others => '0'));
  signal b1_data_TVALID, b1_data_TVALID_r : std_logic;
  signal b1_data_TLAST, b1_data_TLAST_r : std_logic;
  signal b1_LOAD_BUFFER_B, b1_ENABLE_ACC, b1_ENABLE_ACC_r, b1_ENABLE_ACC_rr : std_logic;

  --b2: 
  signal b2_mult_i, b2_mult_q : a128x15std;
  signal b2_GOLAY : std_logic_vector(0 to 127);
  signal b2_count128, b2_count9 : integer := 0;
  signal b2_data_TVALID : std_logic;
  signal b2_data_TLAST : std_logic;
  signal b2_ENABLE_ACC : std_logic;

  --b3: 
  type a64x16std is array (0 to 64-1) of std_logic_vector(16-1 downto 0);
  type a32x17std is array (0 to 32-1) of std_logic_vector(17-1 downto 0);
  type a16x18std is array (0 to 16-1) of std_logic_vector(18-1 downto 0);
  type a8x19std is array (0 to 8-1) of std_logic_vector(19-1 downto 0);
  type a4x20std is array (0 to 4-1) of std_logic_vector(20-1 downto 0);
  type a2x21std is array (0 to 2-1) of std_logic_vector(21-1 downto 0);
  signal b3_add_i_L1, b3_add_q_L1 : a64x16std;
  signal b3_count128_L1, b3_count9_L1 : integer := 0;
  signal b3_data_TVALID_L1 : std_logic;
  signal b3_data_TLAST_L1, b3_ENABLE_ACC_L1 : std_logic;
  signal b3_add_i_L2, b3_add_q_L2 : a32x17std;
  signal b3_count128_L2, b3_count9_L2 : integer := 0;
  signal b3_data_TVALID_L2 : std_logic;
  signal b3_data_TLAST_L2, b3_ENABLE_ACC_L2 : std_logic;
  signal b3_add_i_L3, b3_add_q_L3 : a16x18std;
  signal b3_count128_L3, b3_count9_L3 : integer := 0;
  signal b3_data_TVALID_L3 : std_logic;
  signal b3_data_TLAST_L3, b3_ENABLE_ACC_L3 : std_logic;
  signal b3_add_i_L4, b3_add_q_L4 : a8x19std;
  signal b3_count128_L4, b3_count9_L4 : integer := 0;
  signal b3_data_TVALID_L4 : std_logic;
  signal b3_data_TLAST_L4, b3_ENABLE_ACC_L4 : std_logic;
  signal b3_add_i_L5, b3_add_q_L5 : a4x20std;
  signal b3_count128_L5, b3_count9_L5 : integer := 0;
  signal b3_data_TVALID_L5 : std_logic;
  signal b3_data_TLAST_L5, b3_ENABLE_ACC_L5 : std_logic;
  signal b3_add_i_L6, b3_add_q_L6 : a2x21std;
  signal b3_count128_L6, b3_count9_L6 : integer := 0;
  signal b3_data_TVALID_L6 : std_logic;
  signal b3_data_TLAST_L6, b3_ENABLE_ACC_L6 : std_logic;
  signal b3_add_i_L7, b3_add_q_L7 : std_logic_vector(22-1 downto 0); 
  signal b3_count128_L7 : integer range 0 to 127 := 0;
  signal b3_count9_L7 : integer := 0;
  signal b3_data_TVALID_L7 : std_logic;
  signal b3_data_TLAST_L7, b3_ENABLE_ACC_L7 : std_logic;

  --b4
  type a128x24std is array (0 to 128-1) of std_logic_vector(24-1 downto 0);
  signal b4_CORR_ACC_i, b4_CORR_ACC_q : a128x24std;
  signal b4_data_TVALID : std_logic;
  signal b4_data_TLAST : std_logic;

  --b5
  signal b5_ENABLE_ACC_L7, b5_output_EN : std_logic;

  --b6:
  type b6_state_type is (IDLE, SEND_STREAM);
  signal b6_state : b6_state_type;
  signal b6_counter : integer range 0 to 127 := 0;
  signal b6_CIR_i, b6_CIR_q : std_logic_vector(24-1 downto 0);
  signal b6_data_TVALID, b6_data_TLAST : std_logic;
  type a128x16std is array (0 to 128-1) of std_logic_vector(16-1 downto 0);
  signal b6_temp_i, b6_temp_q : a128x16std;

  --b7:
  signal b7_mult_i, b7_mult_q : std_logic_vector(48-1 downto 0);
  signal b7_CIR_abs : std_logic_vector(49-1 downto 0);
  signal b7_data_TVALID, b7_data_TVALID_r : std_logic;
  signal b7_data_TLAST, b7_data_TLAST_r : std_logic;

begin

  --b0: INPUT 128 Samples shift register
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      b0_data_TVALID <= i_data_TVALID;
      b0_data_TLAST <= i_data_TLAST;
      if i_data_TVALID='1' then
        for ii in 0 to COR_SIZE-2 loop
          b0_BUFFER_A(ii) <= b0_BUFFER_A(ii+1);
        end loop;
        b0_BUFFER_A(COR_SIZE-1) <= i_data_TDATA(31 downto 17) & i_data_TDATA(15 downto 1);
        b0_CEF_FLAG <= i_data_TDATA(0);
      end if;
    end if;
  end process;

  --b1 Input state machine
  b1_sm : process(ap_clk)
  begin
    if(rising_edge(ap_clk)) then
      b1_LOAD_BUFFER_B <= '0';
      if ap_rst_n = '0' then
        b1_state <= st1_WAIT;
        b1_count9 <= 0;
        b1_count128 <= 0;
        b1_LOAD_BUFFER_B <= '0';
        b1_ENABLE_ACC <= '0';
      elsif b0_data_TVALID = '1' then
        case (b1_state) is
          when st1_WAIT =>
            if (b0_CEF_FLAG = '1') then
              b1_state <= st2_count128;
              b1_count128 <= 2;
              b1_count9 <= 0;
            end if;
            b1_LOAD_BUFFER_B <= '0';
            b1_ENABLE_ACC <= '0';
          when st2_count128 =>
            b1_LOAD_BUFFER_B <= '0'; --
            if b1_count128 = 127 then
              b1_count128 <= 0;
              b1_state <= st3_count9;
              if b1_count9 < 8 then
                b1_LOAD_BUFFER_B <= '1'; --
              end if;
            else
              b1_count128 <= b1_count128 + 1;
            end if;
            if b1_count9 /= 0 then 
              b1_ENABLE_ACC <= '1';
            end if;
          when st3_count9 => 
            if b1_count9 = 8 then
              b1_state <= st4_genOUT;
              b1_ENABLE_ACC <= '0';
            else
              b1_count9 <= b1_count9 + 1;
              b1_state <= st2_count128;
              b1_count128 <= b1_count128 + 1;
              b1_ENABLE_ACC <= '1';
            end if;
          when st4_genOUT =>
            b1_state <= st1_WAIT;
            b1_LOAD_BUFFER_B <= '0';
            b1_ENABLE_ACC <= '0';
          when others =>
            b1_state <= st1_WAIT;
            b1_LOAD_BUFFER_B <= '0';
            b1_ENABLE_ACC <= '0';
        end case;
      end if;
      b1_data_TVALID <= b0_data_TVALID;
      b1_data_TLAST <= b0_data_TLAST;
    end if;
  end process;  
  b1_count128_r <= b1_count128;
  b1_count9_r <= b1_count9;
  b1_ENABLE_ACC_r <= b1_ENABLE_ACC; 

  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if b1_data_TVALID = '1' then
        if b1_LOAD_BUFFER_B = '1' then
          for ii in 0 to 64-1 loop
            b1_BUFFER_B(ii) <= (others => '0');
          end loop;
          for ii in 0 to 128-1 loop
            b1_BUFFER_B(ii+64) <= b0_BUFFER_A(ii);
          end loop;
        else
          for ii in 0 to 128+64-2 loop
            b1_BUFFER_B(ii) <= b1_BUFFER_B(ii+1);
          end loop;
          b1_BUFFER_B(128+64-1) <= b1_BUFFER_B(0);
        end if;
      end if;
      b1_data_TVALID_r <= b1_data_TVALID;
      b1_data_TLAST_r <= b1_data_TLAST;
      b1_count128_rr <= b1_count128_r;
    end if;
  end process;
  b1_count9_rr <= b1_count9_r;      
  b1_ENABLE_ACC_rr <= b1_ENABLE_ACC_r;

  b1_GEN: for ii in 0 to 127 generate
  begin
    b1_BUFFER_B_SHORT_i(ii) <= b1_BUFFER_B(ii)(29 downto 15);
    b1_BUFFER_B_SHORT_q(ii) <= b1_BUFFER_B(ii)(14 downto 0);
  end generate;

  --b2: GOLAY SEQUENCE MULTIPLICATION
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if (b1_count9 mod 2)  = 0 then
        b2_GOLAY <= GOLAY_A;
      else
        b2_GOLAY <= GOLAY_B;
      end if;

      for ii in 0 to 63 loop
        if b2_GOLAY(2*ii) = '0' then
          b2_mult_i(2*ii) <= b1_BUFFER_B_SHORT_i(2*ii);  
          b2_mult_q(2*ii) <= b1_BUFFER_B_SHORT_q(2*ii);  
        else
          b2_mult_i(2*ii) <= std_logic_vector(-signed(b1_BUFFER_B_SHORT_i(2*ii)));  
          b2_mult_q(2*ii) <= std_logic_vector(-signed(b1_BUFFER_B_SHORT_q(2*ii)));  
        end if;

        if b2_GOLAY(2*ii+1) = '0' then
          b2_mult_i(2*ii+1) <= std_logic_vector(-signed(b1_BUFFER_B_SHORT_q(2*ii+1)));  
          b2_mult_q(2*ii+1) <= b1_BUFFER_B_SHORT_i(2*ii+1);  
        else
          b2_mult_i(2*ii+1) <= b1_BUFFER_B_SHORT_q(2*ii+1);  
          b2_mult_q(2*ii+1) <= std_logic_vector(-signed(b1_BUFFER_B_SHORT_i(2*ii+1)));  
        end if;
      end loop;
      b2_data_TVALID <= b1_data_TVALID_r;
      b2_data_TLAST <= b1_data_TLAST_r;
      b2_count128 <= b1_count128_rr;
      b2_count9 <= b1_count9_rr;
      b2_ENABLE_ACC <= b1_ENABLE_ACC_rr;
    end if;
  end process;

  --b3 128-elements tree adder
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      for ii in 0 to 63 loop
        b3_add_i_L1(ii) <= std_logic_vector(resize(signed(b2_mult_i(2*ii)),b3_add_i_L1(ii)'length) 
          + resize(signed(b2_mult_i(2*ii+1)),b3_add_i_L1(ii)'length)); 
        b3_add_q_L1(ii) <= std_logic_vector(resize(signed(b2_mult_q(2*ii)),b3_add_q_L1(ii)'length) 
          + resize(signed(b2_mult_q(2*ii+1)),b3_add_q_L1(ii)'length)); 
      end loop;          
      b3_data_TVALID_L1 <= b2_data_TVALID;
      b3_data_TLAST_L1 <= b2_data_TLAST;
      b3_count128_L1 <= b2_count128;
      b3_count9_L1 <= b2_count9;
      b3_ENABLE_ACC_L1 <= b2_ENABLE_ACC;
      
      for ii in 0 to 31 loop
        b3_add_i_L2(ii) <= std_logic_vector(resize(signed(b3_add_i_L1(2*ii)),b3_add_i_L2(ii)'length) 
          + resize(signed(b3_add_i_L1(2*ii+1)),b3_add_i_L2(ii)'length)); 
        b3_add_q_L2(ii) <= std_logic_vector(resize(signed(b3_add_q_L1(2*ii)),b3_add_q_L2(ii)'length) 
          + resize(signed(b3_add_q_L1(2*ii+1)),b3_add_q_L2(ii)'length)); 
      end loop;               
      b3_data_TVALID_L2 <= b3_data_TVALID_L1;
      b3_data_TLAST_L2 <= b3_data_TLAST_L1;
      b3_count128_L2 <= b3_count128_L1;
      b3_count9_L2 <= b3_count9_L1;
      b3_ENABLE_ACC_L2 <= b3_ENABLE_ACC_L1;

      for ii in 0 to 15 loop
        b3_add_i_L3(ii) <= std_logic_vector(resize(signed(b3_add_i_L2(2*ii)),b3_add_i_L3(ii)'length) 
          + resize(signed(b3_add_i_L2(2*ii+1)),b3_add_i_L3(ii)'length)); 
        b3_add_q_L3(ii) <= std_logic_vector(resize(signed(b3_add_q_L2(2*ii)),b3_add_q_L3(ii)'length) 
          + resize(signed(b3_add_q_L2(2*ii+1)),b3_add_q_L3(ii)'length)); 
      end loop;               
      b3_data_TVALID_L3 <= b3_data_TVALID_L2;
      b3_data_TLAST_L3 <= b3_data_TLAST_L2;
      b3_count128_L3 <= b3_count128_L2;
      b3_count9_L3 <= b3_count9_L2;
      b3_ENABLE_ACC_L3 <= b3_ENABLE_ACC_L2;

      for ii in 0 to 7 loop
        b3_add_i_L4(ii) <= std_logic_vector(resize(signed(b3_add_i_L3(2*ii)),b3_add_i_L4(ii)'length) 
          + resize(signed(b3_add_i_L3(2*ii+1)),b3_add_i_L4(ii)'length)); 
        b3_add_q_L4(ii) <= std_logic_vector(resize(signed(b3_add_q_L3(2*ii)),b3_add_q_L4(ii)'length) 
          + resize(signed(b3_add_q_L3(2*ii+1)),b3_add_q_L4(ii)'length)); 
      end loop;  
      b3_data_TVALID_L4 <= b3_data_TVALID_L3;
      b3_data_TLAST_L4 <= b3_data_TLAST_L3;
      b3_count128_L4 <= b3_count128_L3;
      b3_count9_L4 <= b3_count9_L3;
      b3_ENABLE_ACC_L4 <= b3_ENABLE_ACC_L3;

      for ii in 0 to 3 loop
        b3_add_i_L5(ii) <= std_logic_vector(resize(signed(b3_add_i_L4(2*ii)),b3_add_i_L5(ii)'length) 
          + resize(signed(b3_add_i_L4(2*ii+1)),b3_add_i_L5(ii)'length)); 
        b3_add_q_L5(ii) <= std_logic_vector(resize(signed(b3_add_q_L4(2*ii)),b3_add_q_L5(ii)'length) 
          + resize(signed(b3_add_q_L4(2*ii+1)),b3_add_q_L5(ii)'length)); 
      end loop;
      b3_data_TVALID_L5 <= b3_data_TVALID_L4;
      b3_data_TLAST_L5 <= b3_data_TLAST_L4;
      b3_count128_L5 <= b3_count128_L4;
      b3_count9_L5 <= b3_count9_L4;
      b3_ENABLE_ACC_L5 <= b3_ENABLE_ACC_L4;

      for ii in 0 to 1 loop
        b3_add_i_L6(ii) <= std_logic_vector(resize(signed(b3_add_i_L5(2*ii)),b3_add_i_L6(ii)'length) 
          + resize(signed(b3_add_i_L5(2*ii+1)),b3_add_i_L6(ii)'length)); 
        b3_add_q_L6(ii) <= std_logic_vector(resize(signed(b3_add_q_L5(2*ii)),b3_add_q_L6(ii)'length) 
          + resize(signed(b3_add_q_L5(2*ii+1)),b3_add_q_L6(ii)'length)); 
      end loop;
      b3_data_TVALID_L6 <= b3_data_TVALID_L5;
      b3_data_TLAST_L6 <= b3_data_TLAST_L5;
      b3_count128_L6 <= b3_count128_L5;
      b3_count9_L6 <= b3_count9_L5;
      b3_ENABLE_ACC_L6 <= b3_ENABLE_ACC_L5;

      b3_add_i_L7 <= std_logic_vector(resize(signed(b3_add_i_L6(0)),b3_add_i_L7'length) 
        + resize(signed(b3_add_i_L6(1)),b3_add_i_L7'length)); 
      b3_add_q_L7 <= std_logic_vector(resize(signed(b3_add_q_L6(0)),b3_add_q_L7'length) 
        + resize(signed(b3_add_q_L6(1)),b3_add_q_L7'length)); 

      b3_data_TVALID_L7 <= b3_data_TVALID_L6;
      b3_data_TLAST_L7 <= b3_data_TLAST_L6;
      b3_count128_L7 <= b3_count128_L6;
      b3_count9_L7 <= b3_count9_L6;
      b3_ENABLE_ACC_L7 <= b3_ENABLE_ACC_L6;
    end if;
  end process;

  --b4: Correlation ACC
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if (b0_CEF_FLAG = '1') then
        for ii in 0 to 127 loop
          b4_CORR_ACC_i(ii) <= (others => '0');
          b4_CORR_ACC_q(ii) <= (others => '0');
        end loop;
      elsif b3_data_TVALID_L7 = '1' and b3_ENABLE_ACC_L7 = '1' then
        if b3_count9_L7 = 3 or b3_count9_L7 = 6 then
          b4_CORR_ACC_i(b3_count128_L7) <= std_logic_vector(signed(b4_CORR_ACC_i(b3_count128_L7))
            + resize(signed(b3_add_i_L7),b4_CORR_ACC_i(b3_count128_L7)'length));
          b4_CORR_ACC_q(b3_count128_L7) <= std_logic_vector(signed(b4_CORR_ACC_q(b3_count128_L7))
            + resize(signed(b3_add_q_L7),b4_CORR_ACC_q(b3_count128_L7)'length));
        else
          b4_CORR_ACC_i(b3_count128_L7) <= std_logic_vector(signed(b4_CORR_ACC_i(b3_count128_L7))
            - resize(signed(b3_add_i_L7),b4_CORR_ACC_i(b3_count128_L7)'length));
          b4_CORR_ACC_q(b3_count128_L7) <= std_logic_vector(signed(b4_CORR_ACC_q(b3_count128_L7))
            - resize(signed(b3_add_q_L7),b4_CORR_ACC_q(b3_count128_L7)'length));
        end if;
      end if;
      b4_data_TVALID <= b3_data_TVALID_L7;
      b4_data_TLAST <= b3_data_TLAST_L7;      
    end if;
  end process;

  --b5 Output state machine implementation                                               
  process(ap_clk)                                                                        
  begin                                                                                       
    if (rising_edge (ap_clk)) then 
      b5_ENABLE_ACC_L7 <=  b3_ENABLE_ACC_L7;
      if b5_ENABLE_ACC_L7 = '1' and b3_ENABLE_ACC_L7 = '0' then
        b5_output_EN <= '1';
      else
        b5_output_EN <= '0';
      end if;                                             

      --b6: Stream computed CIR       
      if ap_rst_n = '0' then          
        b6_state <= IDLE;
        b6_counter <= 0;
      else
        case (b6_state) is                                                              
          when IDLE =>
            b6_data_TVALID <= '0';
            b6_data_TLAST <= '0';
            b6_counter <= 0;      
            -- start sending 
            if (b5_output_EN = '1') then
              b6_state <= SEND_STREAM;  
            end if;                                                                                                      
          when SEND_STREAM  =>   
            b6_data_TVALID <= '1';   
            b6_CIR_i <= b4_CORR_ACC_i(b6_counter);
            b6_CIR_q <= b4_CORR_ACC_q(b6_counter);
            b6_counter <= b6_counter + 1;
            if (b6_counter = 128-1) then
              b6_data_TLAST <= '1';
              b6_state <= IDLE;
            end if;                                                                                                        
          when others =>                                                                   
            b6_state <= IDLE;                                                                                                                                                       
        end case;                                                                             
      end if;
    end if;                                                                                 
  end process;   

  --b7: abs(CIR) computation
  process(ap_clk)                                                                        
  begin                                                                                       
    if (rising_edge (ap_clk)) then 
      b7_mult_i <= std_logic_vector(signed(b6_CIR_i) * signed(b6_CIR_i));
      b7_mult_q <= std_logic_vector(signed(b6_CIR_q) * signed(b6_CIR_q));
      b7_data_TVALID <= b6_data_TVALID;
      b7_data_TLAST <= b6_data_TLAST;

      b7_CIR_abs <= std_logic_vector(resize(signed(b7_mult_i),b7_CIR_abs'length)+
        resize(signed(b7_mult_q),b7_CIR_abs'length));
      b7_data_TVALID_r <= b6_data_TVALID;
      b7_data_TLAST_r <= b6_data_TLAST;

      if SEL_OUT = '0' then
        o_data_TDATA <= b6_CIR_i(23 downto 8) & b6_CIR_q(23 downto 8);
        o_data_TVALID <= b6_data_TVALID;
        o_data_TLAST <= b6_data_TLAST;
      elsif SEL_OUT = '1' then
        o_data_TDATA <= b7_CIR_abs(48 downto 17);
        o_data_TVALID <= b6_data_TVALID;
        o_data_TLAST <= b6_data_TLAST;
      end if;
    end if;
  end process;

  i_data_TREADY <= '1';

end architecture;
