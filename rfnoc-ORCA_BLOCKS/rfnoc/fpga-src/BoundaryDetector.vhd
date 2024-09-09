--
-- BoundaryDetector.vhd
-- 
-- Copyright 2019 IMDEA Networks Institute - Spain

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BoundaryDetector is
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
    DELAY : in std_logic_vector(31 downto 0)
);
end entity; 

architecture rtl of BoundaryDetector is

  constant Gb128_length : integer := 128;
  constant NSPS : integer := 1;
  constant COR_SIZE : integer := Gb128_length*NSPS;
  constant log2_COR_SIZE : integer := 7;

  --b0:
  type SR_TYPE is array (0 to COR_SIZE) of std_logic_vector (30-1 downto 0);
  signal b0_INPUT_SR : SR_TYPE := (others => (others => '0'));
  signal b0_data_TVALID, b0_data_TLAST : std_logic;
  signal b0_PD_FLAG : std_logic;
  --b1:
  signal b1_rD128_i, b1_rD128_q, b1_r_q, b1_r_i : std_logic_vector(14 downto 0);
  signal b1_rr_q, b1_rr_i : std_logic_vector(14 downto 0);
  signal b1_rD64_i, b1_rD64_q : std_logic_vector(14 downto 0);
  signal b1_add_i, b1_add_q : std_logic_vector(15 downto 0);

  signal b1_oper1, b1_oper2 : std_logic_vector(30 downto 0);
  signal b1_mult_i : std_logic_vector(31 downto 0);
  signal b1_data_TVALID, b1_data_TVALID_r, b1_data_TVALID_rr : std_logic;
  signal b1_data_TLAST_r, b1_data_TLAST, b1_data_TLAST_rr : std_logic;
  
  --b2:
  type ACC_SR_TYPE is array (0 to 31) of std_logic_vector (31 downto 0);
  signal b2_acc1_reg_i : ACC_SR_TYPE := (others => (others => '0'));
  signal b2_r_acc_i : std_logic_vector(37 downto 0);
  signal b2_data_TVALID, b2_data_TLAST : std_logic;

  --b3:
  type SR96_TYPE is array (0 to 95) of std_logic_vector (37 downto 0);
  type type_a48x38std is array (0 to 48-1) of std_logic_vector (38-1 downto 0);
  signal b3_SR_i : SR96_TYPE := (others => (others => '0'));
  signal b3_data_TVALID, b3_data_TVALID_r : std_logic;
  signal b3_data_TLAST, b3_data_TLAST_r : std_logic;
  signal b3_AND_result : std_logic;
  signal b3_MAX_FIND_INPUT : type_a48x38std;
  
  --b4: 
  type type_a24x38std is array (0 to 24-1) of std_logic_vector (38-1 downto 0);
  signal b4_MAX_FIND_L1 : type_a24x38std;
  type type_a24x1std is array (0 to 24-1) of std_logic_vector (0 downto 0);
  signal b4_MAX_FIND_L1_INDEX  : type_a24x1std;
  signal b4_AND_result : std_logic;
  signal b4_data_TVALID : std_logic;
  signal b4_data_TLAST : std_logic;
  type type_a12x38std is array (0 to 12-1) of std_logic_vector (38-1 downto 0);
  signal b4_MAX_FIND_L2 : type_a12x38std;
  type type_a12x2std is array (0 to 12-1) of std_logic_vector (1 downto 0);
  signal b4_MAX_FIND_L2_INDEX  : type_a12x2std;
  signal b4_AND_result_r : std_logic;
  signal b4_data_TVALID_r : std_logic;
  signal b4_data_TLAST_r : std_logic;
  type type_a6x38std is array (0 to 6-1) of std_logic_vector (38-1 downto 0);
  signal b4_MAX_FIND_L3 : type_a6x38std;
  type type_a6x3std is array (0 to 6-1) of std_logic_vector (2 downto 0);
  signal b4_MAX_FIND_L3_INDEX  : type_a6x3std;
  signal b4_AND_result_rr : std_logic;
  signal b4_data_TVALID_rr : std_logic;
  signal b4_data_TLAST_rr : std_logic;
  type type_a3x38std is array (0 to 3-1) of std_logic_vector (38-1 downto 0);
  signal b4_MAX_FIND_L4 : type_a3x38std;
  type type_a3x4std is array (0 to 3-1) of std_logic_vector (3 downto 0);
  signal b4_MAX_FIND_L4_INDEX  : type_a3x4std;
  signal b4_AND_result_rrr : std_logic;
  signal b4_data_TVALID_rrr : std_logic;
  signal b4_data_TLAST_rrr : std_logic;
  type type_a2x38std is array (0 to 1) of std_logic_vector (38-1 downto 0);
  signal b4_MAX_FIND_L5 : type_a2x38std;
  type type_a2x5std is array (0 to 1) of std_logic_vector (4 downto 0);
  signal b4_MAX_FIND_L5_INDEX  : type_a2x5std;
  signal b4_AND_result_rrrr : std_logic;
  signal b4_data_TVALID_rrrr : std_logic;
  signal b4_data_TLAST_rrrr : std_logic;

  signal b4_MAX : std_logic_vector (38-1 downto 0);
  signal b4_MAX_INDEX : std_logic_vector (6-1 downto 0);
  signal b4_AND_result_rrrrr : std_logic;
  signal b4_data_TVALID_rrrrr : std_logic;
  signal b4_data_TLAST_rrrrr : std_logic;  

  --b5: STATE MACHINE
  type b5_state_type is (st1_WAIT, st2_PD, st3_WAIT_PHASE_CHANGE, st4_LOCK_OUT, st5_wait_PD_low);
  signal b5_state : b5_state_type;
  signal b5_counterPD, b5_counterLOCK : integer;
  signal b5_CE_FLAG : std_logic;

begin

  --b0: INPUT 128 Samples shift register
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      b0_data_TVALID <= i_data_TVALID;
      b0_data_TLAST <= i_data_TLAST;
      if i_data_TVALID='1' then
        for ii in 1 to COR_SIZE loop
          b0_INPUT_SR(ii) <= b0_INPUT_SR(ii-1);
        end loop;
        b0_INPUT_SR(0) <= i_data_TDATA(31 downto 17) & i_data_TDATA(15 downto 1);
        b0_PD_FLAG <= i_data_TDATA(0);
      end if;
    end if;
  end process;

  --b1: OUT = r_n * (r_n_D128' + r_n_D64')
  b1_rD128_i <= b0_INPUT_SR(COR_SIZE)(29 downto 15);
  b1_rD128_q <= b0_INPUT_SR(COR_SIZE)(14 downto 0);
  b1_rD64_i <= b0_INPUT_SR(COR_SIZE/2)(29 downto 15);
  b1_rD64_q <= b0_INPUT_SR(COR_SIZE/2)(14 downto 0);
  b1_r_i <= b0_INPUT_SR(0)(29 downto 15);
  b1_r_q <= b0_INPUT_SR(0)(14 downto 0);
  
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      --1 cycle
      b1_add_i <= std_logic_vector(resize(signed(b1_rD64_i),b1_add_i'length)
                                 + resize(signed(b1_rD128_i),b1_add_i'length));
      b1_add_q <= std_logic_vector(resize(signed(b1_rD64_q),b1_add_i'length)
                                 + resize(signed(b1_rD128_q),b1_add_i'length));
      b1_rr_i <= b1_r_i;
      b1_rr_q <= b1_r_q;
      
      --2 cycle
      b1_oper1 <= std_logic_vector(signed(b1_rr_i)*signed(b1_add_i)); 
      b1_oper2 <= std_logic_vector(signed(b1_rr_q)*signed(b1_add_q)); 
      
      --3 cycle
      b1_mult_i <= std_logic_vector(  resize(signed(b1_oper1),b1_mult_i'length) 
                                    + resize(signed(b1_oper2),b1_mult_i'length)); 

      b1_data_TVALID <= b0_data_TVALID;
      b1_data_TVALID_r <= b1_data_TVALID;
      b1_data_TVALID_rr <= b1_data_TVALID_r;
      b1_data_TLAST <= b0_data_TLAST;
      b1_data_TLAST_r <= b1_data_TLAST;
      b1_data_TLAST_rr <= b1_data_TLAST_r;

    end if;
  end process;

  -- b2: 32 samples ACC
  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if ap_rst_n = '0' then
        for ii in 0 to 31 loop
            b2_acc1_reg_i(ii) <= (others => '0');
--            b2_acc1_reg_q(ii) <= (others => '0');
        end loop;                
        b2_r_acc_i <= (others => '0');
--        b2_r_acc_q <= (others => '0');
      elsif b1_data_TVALID_rr = '1' then
        for ii in 1 to 31 loop
            b2_acc1_reg_i(ii) <= b2_acc1_reg_i(ii - 1);
--            b2_acc1_reg_q(ii) <= b2_acc1_reg_q(ii - 1);
        end loop;
        b2_acc1_reg_i(0) <= b1_mult_i;
--        b2_acc1_reg_q(0) <= b1_mult_q;

        b2_r_acc_i <= std_logic_vector(signed(b2_r_acc_i) + 
          resize(signed(b1_mult_i),b2_r_acc_i'length)- 
          resize(signed(b2_acc1_reg_i(31)),b2_r_acc_i'length));
--        b2_r_acc_q <= std_logic_vector(signed(b2_r_acc_q) + 
--          resize(signed(b1_mult_q),b2_r_acc_q'length)- 
--          resize(signed(b2_acc1_reg_q(31)),b2_r_acc_q'length));
      end if;
        
        b2_data_TVALID <= b1_data_TVALID_rr;
        b2_data_TLAST <= b1_data_TLAST_rr;
    end if;
  end process;

  --b3: 96 samples shift register
  process(ap_clk)
    variable AND_result : std_logic := '1';
  begin
    if rising_edge(ap_clk) then
      if ap_rst_n = '0' then
        for ii in 0 to 95 loop
            b3_SR_i(ii) <= (others => '0');
        end loop;                
      elsif b2_data_TVALID = '1' then
        for ii in 1 to 95 loop
            b3_SR_i(ii) <= b3_SR_i(ii - 1);
        end loop;
        b3_SR_i(0) <= b2_r_acc_i;
      end if;
      
      AND_result := '1';
      for i in 0 to 47 loop
        AND_result := AND_result and b3_SR_i(i)(37);
        b3_MAX_FIND_INPUT(i) <= b3_SR_i(i+48);
      end loop;
      b3_AND_result <= AND_result;
  
      b3_data_TVALID <= b2_data_TVALID;
      b3_data_TLAST <= b2_data_TLAST;
      b3_data_TVALID_r <= b3_data_TVALID;
      b3_data_TLAST_r <= b3_data_TLAST;
    end if;
  end process;  

  --b4: MAX finder tree

    --Level 1
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        for ii in 0 to 23 loop
          if b3_MAX_FIND_INPUT(2*ii) > b3_MAX_FIND_INPUT(2*ii+1) then
            b4_MAX_FIND_L1(ii) <= b3_MAX_FIND_INPUT(2*ii);
            b4_MAX_FIND_L1_INDEX(ii) <= "0";
          else
            b4_MAX_FIND_L1(ii) <= b3_MAX_FIND_INPUT(2*ii+1);
            b4_MAX_FIND_L1_INDEX(ii) <= "1";
          end if;
        end loop;
        b4_data_TVALID <= b3_data_TVALID_r;
        b4_data_TLAST <= b3_data_TLAST_r;
        b4_AND_result <= b3_AND_result;
      end if;
    end process;

    --Level 2
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        for ii in 0 to 12-1 loop
          if b4_MAX_FIND_L1(2*ii) > b4_MAX_FIND_L1(2*ii+1) then
            b4_MAX_FIND_L2(ii) <= b4_MAX_FIND_L1(2*ii);
            b4_MAX_FIND_L2_INDEX(ii) <= "0" & b4_MAX_FIND_L1_INDEX(2*ii);
          else
            b4_MAX_FIND_L2(ii) <= b4_MAX_FIND_L1(2*ii+1);
            b4_MAX_FIND_L2_INDEX(ii) <= "1" & b4_MAX_FIND_L1_INDEX(2*ii+1);
          end if;
        end loop;
        b4_data_TVALID_r <= b4_data_TVALID;
        b4_data_TLAST_r <= b4_data_TLAST;
        b4_AND_result_r <= b4_AND_result;
      end if;
    end process;

    --Level 3
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        for ii in 0 to 6-1 loop
          if b4_MAX_FIND_L2(2*ii) > b4_MAX_FIND_L2(2*ii+1) then
            b4_MAX_FIND_L3(ii) <= b4_MAX_FIND_L2(2*ii);
            b4_MAX_FIND_L3_INDEX(ii) <= "0" & b4_MAX_FIND_L2_INDEX(2*ii);
          else
            b4_MAX_FIND_L3(ii) <= b4_MAX_FIND_L2(2*ii+1);
            b4_MAX_FIND_L3_INDEX(ii) <= "1" & b4_MAX_FIND_L2_INDEX(2*ii+1);
          end if;
        end loop;
        b4_data_TVALID_rr <= b4_data_TVALID_r;
        b4_data_TLAST_rr <= b4_data_TLAST_r;
        b4_AND_result_rr <= b4_AND_result_r;
      end if;
    end process;

    --Level 4
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        for ii in 0 to 3-1 loop
          if b4_MAX_FIND_L3(2*ii) > b4_MAX_FIND_L3(2*ii+1) then
            b4_MAX_FIND_L4(ii) <= b4_MAX_FIND_L3(2*ii);
            b4_MAX_FIND_L4_INDEX(ii) <= "0" & b4_MAX_FIND_L3_INDEX(2*ii);
          else
            b4_MAX_FIND_L4(ii) <= b4_MAX_FIND_L3(2*ii+1);
            b4_MAX_FIND_L4_INDEX(ii) <= "1" & b4_MAX_FIND_L3_INDEX(2*ii+1);
          end if;
        end loop;
        b4_data_TVALID_rrr <= b4_data_TVALID_rr;
        b4_data_TLAST_rrr <= b4_data_TLAST_rr;
        b4_AND_result_rrr <= b4_AND_result_rr;
      end if;
    end process;

    --Level 5 and 6
    process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        if b4_MAX_FIND_L4(0) > b4_MAX_FIND_L4(1) then
          b4_MAX_FIND_L5(0) <= b4_MAX_FIND_L4(0);
          b4_MAX_FIND_L5_INDEX(0) <= "0" & b4_MAX_FIND_L4_INDEX(0);
        else
          b4_MAX_FIND_L5(0) <= b4_MAX_FIND_L4(1);
          b4_MAX_FIND_L5_INDEX(0) <= "1" & b4_MAX_FIND_L4_INDEX(1);
        end if;
        b4_MAX_FIND_L5(1) <= b4_MAX_FIND_L4(2);
        b4_MAX_FIND_L5_INDEX(1) <= "0" & b4_MAX_FIND_L4_INDEX(2);
        
        if b4_MAX_FIND_L5(0) > b4_MAX_FIND_L5(1) then
          b4_MAX <= b4_MAX_FIND_L5(0);
          b4_MAX_INDEX <= "0" & b4_MAX_FIND_L5_INDEX(0);
        else
          b4_MAX <= b4_MAX_FIND_L5(1);
          b4_MAX_INDEX <= "1" & b4_MAX_FIND_L5_INDEX(1);
        end if;
        
        b4_data_TVALID_rrrr <= b4_data_TVALID_rrr;
        b4_data_TLAST_rrrr <= b4_data_TLAST_rrr;
        b4_AND_result_rrrr <= b4_AND_result_rrr;
        b4_data_TVALID_rrrrr <= b4_data_TVALID_rrrr;
        b4_data_TLAST_rrrrr <= b4_data_TLAST_rrrr;
        b4_AND_result_rrrrr <= b4_AND_result_rrrr;
      end if;
    end process;

  --b5: state machine
  b5_sm : process(ap_clk)
    variable b5_timeout_counter_v : integer := 0;
  begin
    if(rising_edge(ap_clk)) then
      if ap_rst_n = '0' then
        b5_state <= st1_WAIT;
        b5_counterPD <= 0;
        b5_counterLOCK <= 0;
        b5_CE_FLAG <= '0';
      elsif b0_data_TVALID = '1' then
        b5_CE_FLAG <= '0';
        case (b5_state) is
          when st1_WAIT =>
            if (b0_PD_FLAG = '1') then
              b5_state <= st2_PD;
            end if;
          when st2_PD =>
            if b5_counterPD = to_integer(unsigned(DELAY)) then
              b5_counterPD <= 0;
              b5_state <= st3_WAIT_PHASE_CHANGE;
            else
              b5_counterPD <= b5_counterPD + 1;
            end if;
          when st3_WAIT_PHASE_CHANGE => -- need to include a timeout if a phase change does not ocur
            if b4_AND_result_rrrrr = '1' then
              b5_state <= st4_LOCK_OUT;
              b5_timeout_counter_v := 0;
            elsif b5_timeout_counter_v = 8096 then
              b5_state <= st5_wait_PD_low;
              b5_timeout_counter_v := 0;
            else
              b5_timeout_counter_v := b5_timeout_counter_v + 1;
            end if;
          when st4_LOCK_OUT =>
            if b5_counterLOCK = 66 then
              b5_counterLOCK <= 0;
              b5_CE_FLAG <= '1';
              b5_state <= st5_wait_PD_low;
            else
              b5_counterLOCK <= b5_counterLOCK + 1;
            end if;
          when st5_wait_PD_low =>
            if (b0_PD_FLAG = '0') then
              b5_state <= st1_WAIT;
            end if;
          when others =>
            b5_state <= st1_WAIT;
        end case;
      end if;
    end if;
  end process;

  --b6: 
  output_process : process(ap_clk)  
  begin
    if rising_edge(ap_clk) then
      if SEL_OUT="00" then -- normal output (I(n) & '0' & Q(n) & CEF_FLAG)
        o_data_TDATA <= b1_r_i & '0' & b1_r_q & b5_CE_FLAG;  
        o_data_TVALID <= b0_data_TVALID;
        o_data_TLAST <= b0_data_TLAST and b0_data_TVALID;
      elsif SEL_OUT="01" then -- debug output (ACC Output and CEF_FLAG)
        o_data_TDATA <= b2_r_acc_i(37 downto 37-32+1);  
        o_data_TVALID <= b2_data_TVALID;
        o_data_TLAST <= b2_data_TLAST and b2_data_TVALID;
      else
        o_data_TDATA <= b2_r_acc_i(37 downto 37-31+1) & b5_CE_FLAG;  
        o_data_TVALID <= b2_data_TVALID;
        o_data_TLAST <= b2_data_TLAST and b2_data_TVALID;
      end if;
    end if;
  end process;

  i_data_TREADY <= '1';

end architecture;
