--
-- PACKET_DETECTOR.vhd
-- 
-- Copyright 2019 IMDEA Networks Institute - Spain

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PacketDetector is
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
    PD_threshold : in std_logic_vector(15 downto 0);
    noise_threshold : in std_logic_vector(15 downto 0);
    N_COUNT : in std_logic_vector(15 downto 0); -- Time to detect a valid packet
    PD_HIGH_TIME : in std_logic_vector(15 downto 0); -- High time of the packet detected flag
    NPER : in std_logic_vector(7 downto 0); -- High time of the packet detected flag
    SEL_OUT : in std_logic_vector(1 downto 0));
end entity; 

architecture rtl of PacketDetector is

  constant Gb128_length : integer := 128;
  constant NSPS : integer := 2;
  constant COR_SIZE : integer := Gb128_length*NSPS;
  constant log2_COR_SIZE : integer := 8;

  signal PD_threshold_r : std_logic_vector(15 downto 0);
  signal noise_threshold_r : std_logic_vector(15 downto 0);

  --b0:
  type SR_TYPE is array (0 to COR_SIZE) of std_logic_vector (32-1 downto 0);
  signal b0_INPUT_SR : SR_TYPE := (others => (others => '0'));
  signal b0_data_TVALID, b0_data_TLAST : std_logic;

  --b1:
  signal b1_rD_i, b1_rD_q, b1_r_q, b1_r_i : std_logic_vector(15 downto 0);
  signal b1_oper1, b1_oper2, b1_oper3, b1_oper4 : std_logic_vector(31 downto 0);
  signal b1_r_x_rDc_r_i, b1_r_x_rDc_r_q : std_logic_vector(32 downto 0);
  signal b1_r_x_rDc_rr_i, b1_r_x_rDc_rr_q : std_logic_vector(32 downto 0);
  signal b1_data_TVALID, b1_data_TVALID_r, b1_data_TVALID_rr : std_logic;
  signal b1_data_TLAST_r, b1_data_TLAST, b1_data_TLAST_rr : std_logic;
  signal b1_rD_i_r, b1_rD_q_r : std_logic_vector(15 downto 0);
  signal b1_rD_i_rr, b1_rD_q_rr : std_logic_vector(15 downto 0);
  signal b1_rD_i_rrr, b1_rD_q_rrr : std_logic_vector(15 downto 0);
  
  --b2:
  type ACC_SR_TYPE is array (0 to COR_SIZE) of std_logic_vector (32 downto 0);
  signal b2_acc1_reg_i, b2_acc1_reg_q : ACC_SR_TYPE := (others => (others => '0'));
  signal b2_r_acc_i, b2_r_acc_q : std_logic_vector(40 downto 0);
  signal b2_data_TVALID, b2_data_TVALID_r, b2_data_TLAST, b2_data_TLAST_r : std_logic;
  signal b2_temp_i, b2_temp_q : std_logic_vector(32 downto 0);
  signal b2_rD_i, b2_rD_q : std_logic_vector(15 downto 0);
  
  --b3:
  signal b3_c_n1, b3_c_n2, b3_c_n3 : std_logic_vector(63 downto 0);
  signal b3_data_TVALID, b3_data_TVALID_r : std_logic;
  signal b3_data_TLAST, b3_data_TLAST_r : std_logic;
  signal b3_r_acc_i, b3_r_acc_q : std_logic_vector(15 downto 0);
  signal b3_rD_i, b3_rD_q : std_logic_vector(15 downto 0);
  signal b3_rD_i_r, b3_rD_q_r : std_logic_vector(15 downto 0);
  
  --b4:
  signal b4_oper1, b4_oper2 : std_logic_vector(31 downto 0);
  signal b4_rD_x_rDc, b4_rD_x_rDc_r : std_logic_vector(32 downto 0);

  --b5:
  signal b5_acc1_reg : ACC_SR_TYPE := (others => (others => '0'));
  signal b5_r_acc : std_logic_vector(40 downto 0);
  signal b5_r_acc1 : std_logic_vector(39 downto 0);
  signal b5_temp : std_logic_vector(32 downto 0);
  --b6:
  signal b6_p_n1, b6_p_n2 : std_logic_vector(63 downto 0);

  --b7:
  signal b7_p_n : std_logic_vector(63 downto 0);
  signal b7_c_n : std_logic_vector(63 downto 0);
  signal b7_m_n2 : std_logic_vector(63 downto 0);
  signal b7_data_TVALID, b7_data_TVALID_r : std_logic;
  signal b7_data_TLAST, b7_data_TLAST_r : std_logic;
  signal b7_m_n2_reduced : std_logic_vector(30 downto 0);
  signal b7_r_acc_i, b7_r_acc_q : std_logic_vector(15 downto 0);
  signal b7_r_acc_i_r, b7_r_acc_q_r : std_logic_vector(15 downto 0);
  signal b7_rD_i, b7_rD_q : std_logic_vector(15 downto 0);
  signal b7_rD_i_r, b7_rD_q_r : std_logic_vector(15 downto 0);
  signal p_n_th : std_logic_vector(72 downto 0);

  --b8: STATE MACHINE
  type state_type is (st1_WAIT, st2_PD);
  signal state : state_type; 
  signal b8_detected_flag : std_logic;
  signal b8_counter : integer;
  signal b8_max_temp : std_logic_vector(30 downto 0);
  signal b8_detected_time : integer;

  --b9: STATE MACHINE (OUTPUT SWITCHING)
  type b9_state_type is (st1_WAIT, st2_PD, st3_wait_PD_low);
  signal b9_state : b9_state_type;
  signal b9_counter : integer;
  signal b9_change_out : std_logic;
  signal b9_counter_end : std_logic_vector(8+log2_COR_SIZE+5 downto 0);
begin


  --b0: INPUT SHIFT REGISTER
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      PD_threshold_r <= PD_threshold;
      noise_threshold_r <= noise_threshold;
      b0_data_TVALID <= i_data_TVALID;
      b0_data_TLAST <= i_data_TLAST;
      if i_data_TVALID='1' then
        for ii in 1 to COR_SIZE loop
          b0_INPUT_SR(ii) <= b0_INPUT_SR(ii-1);
        end loop;
        b0_INPUT_SR(0) <= i_data_TDATA;
      end if;
    end if;
  end process;

    --b1: r_n * r_nD_c
    b1_rD_i <= b0_INPUT_SR(COR_SIZE)(31 downto 16);
    b1_rD_q <= b0_INPUT_SR(COR_SIZE)(15 downto 0);
    b1_r_i <= b0_INPUT_SR(0)(31 downto 16);
    b1_r_q <= b0_INPUT_SR(0)(15 downto 0);
    
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            b1_oper1 <= std_logic_vector(signed(b1_rD_q)*signed(b1_r_q)); --1 cycle
            b1_oper2 <= std_logic_vector(signed(b1_rD_i)*signed(b1_r_i)); --1 cycle
            b1_r_x_rDc_r_i <= std_logic_vector(resize(signed(b1_oper1),b1_r_x_rDc_r_i'length) 
                                             + resize(signed(b1_oper2),b1_r_x_rDc_r_i'length));  --2 cycle

            b1_oper3 <= std_logic_vector(signed(b1_rD_i)*signed(b1_r_q));
            b1_oper4 <= std_logic_vector(signed(b1_rD_q)*signed(b1_r_i)); --1 cycle
            b1_r_x_rDc_r_q <= std_logic_vector(resize(signed(b1_oper3),b1_r_x_rDc_r_i'length) 
                                             - resize(signed(b1_oper4),b1_r_x_rDc_r_i'length)); --2 cycle

            b1_data_TVALID <= b0_data_TVALID;
            b1_data_TVALID_r <= b1_data_TVALID;
            b1_data_TLAST <= b0_data_TLAST;
            b1_data_TLAST_r <= b1_data_TLAST;

            b1_rD_i_r <= b1_rD_i;
            b1_rD_i_rr <= b1_rD_i_r;
            b1_rD_q_r <= b1_rD_q;
            b1_rD_q_rr <= b1_rD_q_r;
        end if;
    end process;

    --PIPELING REGISTERS
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        b1_r_x_rDc_rr_i <= b1_r_x_rDc_r_i;
        b1_r_x_rDc_rr_q <= b1_r_x_rDc_r_q;
        b1_data_TVALID_rr <= b1_data_TVALID_r;
        b1_data_TLAST_rr <= b1_data_TLAST_r;
        b1_rD_i_rrr <= b1_rD_i_rr;
        b1_rD_q_rrr <= b1_rD_q_rr;
      end if;
    end process;

    -- b2: ACC_SUM
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
          if ap_rst_n = '0' then
              for ii in 0 to COR_SIZE loop
                  b2_acc1_reg_i(ii) <= (others => '0');
                  b2_acc1_reg_q(ii) <= (others => '0');
              end loop;                
              b2_r_acc_i <= (others => '0');
              b2_r_acc_q <= (others => '0');
          elsif b1_data_TVALID_rr = '1' then
              for ii in 1 to COR_SIZE loop
                  b2_acc1_reg_i(ii) <= b2_acc1_reg_i(ii - 1);
                  b2_acc1_reg_q(ii) <= b2_acc1_reg_q(ii - 1);
              end loop;
              b2_acc1_reg_i(0) <= b1_r_x_rDc_rr_i;
              b2_acc1_reg_q(0) <= b1_r_x_rDc_rr_q;

              b2_r_acc_i <= std_logic_vector(signed(b2_r_acc_i) + 
                resize(signed(b1_r_x_rDc_rr_i),b2_r_acc_i'length)- 
                resize(signed(b2_acc1_reg_i(COR_SIZE-1)),b2_r_acc_i'length)); --3 cycle
              b2_r_acc_q <= std_logic_vector(signed(b2_r_acc_q) + 
                resize(signed(b1_r_x_rDc_rr_q),b2_r_acc_q'length)- 
                resize(signed(b2_acc1_reg_q(COR_SIZE-1)),b2_r_acc_q'length)); --3 cycle
          end if;
          
          b2_data_TVALID <= b1_data_TVALID_rr;
          b2_data_TLAST <= b1_data_TLAST_rr;
          b2_rD_i <= b1_rD_i_rrr;
          b2_rD_q <= b1_rD_q_rrr;
      end if;
    end process;

    -- b3: c_n
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            b3_c_n1 <= std_logic_vector(signed(b2_r_acc_i(40 downto 40-32+1))*signed(b2_r_acc_i(40 downto 40-32+1)));
            b3_c_n2 <= std_logic_vector(signed(b2_r_acc_q(40 downto 40-32+1))*signed(b2_r_acc_q(40 downto 40-32+1)));
            b3_c_n3 <= std_logic_vector(signed(b3_c_n1)+signed(b3_c_n2));
            b3_data_TVALID <= b2_data_TVALID;
            b3_data_TVALID_r <= b3_data_TVALID;
            b3_data_TLAST <= b2_data_TLAST;
            b3_data_TLAST_r <= b3_data_TLAST;

            b3_r_acc_i <= b2_r_acc_i(40 downto 40-16+1);
            b3_r_acc_q <= b2_r_acc_q(40 downto 40-16+1);
            --b3_r_acc_i <= b2_r_acc_i(40-5 downto 40-5-16+1);
            --b3_r_acc_q <= b2_r_acc_q(40-5 downto 40-5-16+1);
            b3_rD_i <= b2_rD_i;
            b3_rD_q <= b2_rD_q;
            b3_rD_i_r <= b3_rD_i;
            b3_rD_q_r <= b3_rD_q;
        end if;
    end process;

    -- b4: rD * rDc
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then   
            b4_oper1 <= std_logic_vector(signed(b1_rD_q)*signed(b1_rD_q)); --1 cycle
            b4_oper2 <= std_logic_vector(signed(b1_rD_i)*signed(b1_rD_i)); --1 cycle
            b4_rD_x_rDc <= std_logic_vector(resize(signed(b4_oper1),b4_rD_x_rDc'length) 
                                          + resize(signed(b4_oper2),b4_rD_x_rDc'length));  --2 cycle
        end if;
    end process;

    --PIPELING REGISTERS
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        b4_rD_x_rDc_r <= b4_rD_x_rDc;
      end if;
    end process;

    -- b5: ACC_SUM_2
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            if ap_rst_n = '0' then
                for ii in 0 to COR_SIZE loop
                    b5_acc1_reg(ii) <= (others => '0');
                end loop;                
                b5_r_acc <= (others => '0');
            elsif b1_data_TVALID_rr = '1' then
                for ii in 1 to COR_SIZE loop
                    b5_acc1_reg(ii) <= b5_acc1_reg(ii - 1);
                end loop;
                b5_acc1_reg(0) <= b4_rD_x_rDc_r;

                b5_r_acc <= std_logic_vector(signed(b5_r_acc) + 
                  resize(signed(b4_rD_x_rDc_r),b5_r_acc'length)- 
                  resize(signed(b5_acc1_reg(COR_SIZE-1)),b5_r_acc'length));
            end if;
        end if;
    end process;

    -- b6: p_n
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            b6_p_n1 <= std_logic_vector(signed(b5_r_acc(40 downto 40-32+1))*signed(b5_r_acc(40 downto 40-32+1)));
            b6_p_n2 <= b6_p_n1;
        end if;
    end process;

    -- b7: m_n
    process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            p_n_th <= std_logic_vector(signed(b6_p_n2)*signed('0' & PD_threshold_r(7 downto 0))); --5 cycle
            b7_c_n <= b3_c_n3;
            b7_m_n2 <= std_logic_vector(signed(b7_c_n) - signed(b7_p_n));
            b7_data_TVALID <= b3_data_TVALID_r;
            b7_data_TVALID_r <= b7_data_TVALID;
            b7_data_TLAST <= b3_data_TLAST_r;
            b7_data_TLAST_r <= b7_data_TLAST;

            b7_r_acc_i <= b3_r_acc_i;
            b7_r_acc_q <= b3_r_acc_q;
            b7_r_acc_i_r <= b7_r_acc_i;
            b7_r_acc_q_r <= b7_r_acc_q;
            b7_rD_i <= b3_rD_i_r;
            b7_rD_q <= b3_rD_q_r;
            b7_rD_i_r <= b7_rD_i;
            b7_rD_q_r <= b7_rD_q;
        end if;
    end process;
    b7_m_n2_reduced <= b7_m_n2(63-0 downto 63-31+1-0);
    b7_p_n <= p_n_th(71 downto 71-64+1);
            
    --b8: state machine for packet_detected_flag
    b8_sm : process(ap_clk)
    begin
      if(rising_edge(ap_clk)) then
        if ap_rst_n = '0' then
          state <= st1_WAIT;
          b8_detected_time <= 0;
          b8_counter <= 0;
          b8_max_temp <= (b8_max_temp'length-1 => '1', others => '0');
        elsif b7_data_TVALID_r = '1' then
          case (state) is
            when st1_WAIT =>
              if (signed(b7_m_n2_reduced)>resize(signed(noise_threshold),b7_m_n2_reduced'length)) then
                if ( signed(b7_m_n2_reduced) > resize( signed(b8_max_temp(b8_max_temp'length-1 downto 1)),b7_m_n2_reduced'length) + 
                                       resize( signed(b8_max_temp(b8_max_temp'length-1 downto 2)),b7_m_n2_reduced'length) ) then
                  if (b8_counter>to_integer(unsigned(N_COUNT))) then 
                    b8_counter <= 0;
                    state <= st2_PD;
                  else
                    b8_counter <= b8_counter+1;
                  end if;

                  if (signed(b7_m_n2_reduced)>signed(b8_max_temp)) then
                    b8_max_temp <= b7_m_n2_reduced;
                  end if;
                end if;  
              else
                b8_max_temp <= (b8_max_temp'length-1 => '1', others => '0');
                b8_counter <= 0;
              end if;
            when st2_PD =>
              b8_detected_time <= b8_detected_time + 1;    
              if b8_detected_time = to_integer(unsigned(PD_HIGH_TIME)) then
                b8_detected_time <= 0;
                state <= st1_WAIT;
              end if;
            when others =>
              state <= st1_WAIT;
          end case;
        end if;
      end if;
    end process;

    --MOORE State-Machine - Outputs based on state only
    b8_detected_flag <= '1' WHEN state = st2_PD ELSE '0';

    --b9: state machine for output switching (CFOE)
    b9_sm : process(ap_clk)
    begin
      if(rising_edge(ap_clk)) then
        b9_counter_end <= (others => '0');
        b9_counter_end(log2_COR_SIZE+NPER'length-1 downto log2_COR_SIZE) <= NPER;
        b9_counter_end(4 downto 0) <= "11100";
        if ap_rst_n = '0' then
          b9_state <= st1_WAIT;
          b9_counter <= 0;
        elsif b7_data_TVALID_r = '1' then
          case (b9_state) is
            when st1_WAIT =>
              if (b8_detected_flag = '1') then
                b9_state <= st2_PD;
              end if;
            when st2_PD =>
              if b9_counter = to_integer(unsigned(b9_counter_end)) then
                b9_counter <= 0;
                b9_state <= st3_wait_PD_low;
              else
                b9_counter <= b9_counter+1;
              end if;
            when st3_wait_PD_low =>
              if (b8_detected_flag = '0') then
                b9_state <= st1_WAIT;
              end if;
            when others =>
              b9_state <= st1_WAIT;
          end case;
        end if;
      end if;
    end process;

    b9_change_out <= '1' when b9_state = st2_PD else '0';

  output_process : process(ap_clk)  
  begin
    if rising_edge(ap_clk) then
      if SEL_OUT="01" then -- debug output (NAC output and PD_FLAG)
        o_data_TDATA <= b7_m_n2_reduced & b8_detected_flag;  
        --o_data_TDATA <= b7_m_n2(63-0 downto 63-32+1-0);  
        o_data_TVALID <= b7_data_TVALID_r;
        o_data_TLAST <= b7_data_TLAST_r and b7_data_TVALID_r;
      elsif SEL_OUT="00" then -- output delayed IQ samples and PD_FLAG
        o_data_TDATA <= b1_rD_i(15 downto 1) & '0' & b1_rD_q(15 downto 1) & b8_detected_flag;
        o_data_TVALID <= b0_data_TVALID;
        o_data_TLAST <= b0_data_TLAST and b0_data_TVALID;
      elsif SEL_OUT="10" then -- output r_acc and PD_FLAG for CFOE testing
        --o_data_TDATA <= b2_r_acc_i(40 downto 40-15+1) & '0' & b2_r_acc_q(40 downto 40-15+1) & b8_detected_flag;
--        o_data_TDATA <= b2_r_acc_i(40-5 downto 40-5-15+1) & '0' & b2_r_acc_q(40-5 downto 40-5-15+1) & b8_detected_flag;
--        o_data_TVALID <= b2_data_TVALID;
--        o_data_TLAST <= b2_data_TLAST and b2_data_TVALID;
        o_data_TDATA <= b7_r_acc_i_r(15 downto 1) & '0' & b7_r_acc_q_r(15 downto 1) & b8_detected_flag;
        o_data_TVALID <= b7_data_TVALID_r;
        o_data_TLAST <= b7_data_TLAST_r and b7_data_TVALID_r;
      elsif SEL_OUT="11" then -- switch output between IQ samples and r_acc along with PD_FLAG for regular operation
        if b9_change_out = '0' then 
          o_data_TDATA <= b7_rD_i_r(15 downto 1) & '0' & b7_rD_q_r(15 downto 1) & b8_detected_flag;
        else
          o_data_TDATA <= b7_r_acc_i_r(15 downto 1) & '0' & b7_r_acc_q_r(15 downto 1) & b8_detected_flag;
        end if;
        o_data_TVALID <= b7_data_TVALID_r;
        o_data_TLAST <= b7_data_TLAST_r and b7_data_TVALID_r;
      end if;
    end if;
  end process;

  i_data_TREADY <= '1';

end architecture;
