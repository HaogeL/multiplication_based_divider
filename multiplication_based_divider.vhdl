-->>>>>>>>>>>>>package unit>>>>>>>>>>>>>>>>>>>>>>>>>>
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg is
  constant dividend_width_c : positive := 32; --dividend width
  --the maximun value the divisor can be 
  constant max_divisor_value_c : positive := 15; 
end pkg;
--<<<<<<<<<<<<<package unit<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>entity unit>>>>>>>>>>>>>>>>>>>>>>>>>>
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

library work;
use work.pkg.all;

entity multiplication_based_divider is
  port(
    dividend : in  unsigned(dividend_width_c-1 downto 0);
    divisor  : in  unsigned(integer(ceil(log2(real(max_divisor_value_c))))-1 downto 0);
    quotient : out unsigned(dividend_width_c-1 downto 0);
    remainder: out unsigned(integer(ceil(log2(real(max_divisor_value_c-1))))-1 downto 0);
    notdefined: out std_logic
  );
end multiplication_based_divider;
--<<<<<<<<<<<<<entity unit<<<<<<<<<<<<<<<<<<<<<<<<<<

architecture rtl of multiplication_based_divider is
--magic number declaration>>>>>>>>>>>>>>>>>>>>>>>>>>>
  --(2³³ + 1) / 3 = 32'hAAAA_AAAB
  constant M_3_c  : unsigned(31 downto 0) := to_unsigned(16#AAAA_AAAB#,32); --slr 33 bits
  constant M_3_k_c: positive := 33;
  --(2³⁴ + 1) / 5 = 32'hCCCC_CCCD
  constant M_5_c  : unsigned(31 downto 0) := to_unsigned(16#CCCC_CCCD#,32); --slr 34 bits
  constant M_5_k_c: positive := 34;

  -- no need to pre-compute M_6_c
  ----(2³⁴ + 1) / 6 = 32'hAAAA_AAAB
  --constant M_6_c  : unsigned(31 downto 0) := x"AAAA_AAAB"; --slr 34 bits

  --(2³⁵ + 6) / 7 = 33'h1_2492_4925
  constant M_7_c  : unsigned(32 downto 0) := to_unsigned(16#1_2492_4925#,33); --slr 35 bits
  constant M_7_k_c: positive := 35;

  --no need to pre-compute M_9_c
  ----(2³³ + 1) / 9 = 30'h38E3_8E39
  --constant M_9_c  : unsigned(29 downto 0) := x"38E3_8E39"; --slr 33 bits

  ----no need to pre-compute M_10_c
  ----(2³⁵ + 2) / 10 = 32'hCCCC_CCCD
  --constant M_10_c : unsigned(31 downto 0) := x"CCCC_CCCD"; --slr 35 bits
  
  --k == 35
  constant M_11_c : unsigned(31 downto 0) := to_unsigned(16#ba2e_8ba3#,32); --slr 35 bits
  constant M_11_k_c: positive := 35;

  --k == 34
  constant M_13_c : unsigned(30 downto 0) := to_unsigned(16#4ec4_ec4f#,31); --slr 34 bits
  constant M_13_k_c: positive := 34;
--magic number declaration<<<<<<<<<<<<<<<<<<<<<<<<<<<

begin  -- rtl  
  div_comb: process (divisor, dividend) 
    variable quotient_tmp: unsigned(quotient'left downto 0);
    variable quotient_tmp_3: unsigned(quotient'length+M_3_c'length-1 downto 0);
    variable quotient_tmp_5: unsigned(quotient'length+M_5_c'length-1 downto 0);
    variable quotient_tmp_7: unsigned(quotient'length+M_7_c'length-1 downto 0);
    variable quotient_tmp_11: unsigned(quotient'length+M_11_c'length-1 downto 0);
    variable quotient_tmp_13: unsigned(quotient'length+M_13_c'length-1 downto 0);
    variable divisor_int: positive;
  begin
    notdefined <= '0';
    divisor_int := to_integer(divisor);
    case divisor_int is
      when 1 =>
        quotient <= dividend;
        remainder<= to_unsigned(0, remainder'length);
      when 2 =>
        quotient <= dividend srl 1;
        remainder<= resize(dividend(0 downto 0), remainder'length);
      when 3 =>
        quotient_tmp_3 := (dividend*M_3_c) srl M_3_k_c;
        quotient_tmp := quotient_tmp_3(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*3, 4);
        quotient<=quotient_tmp;
      when 4 =>
        quotient <= dividend srl 2;
        remainder<= resize(dividend(1 downto 0), remainder'length);
      when 5 =>
        quotient_tmp_5 := (dividend*M_5_c) srl M_5_k_c;
        quotient_tmp := quotient_tmp_5(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*5, remainder'length);
        quotient<=quotient_tmp;
      when 6 =>
        quotient_tmp_3 := (((dividend srl 1)*M_3_c) srl M_3_k_c);
        quotient_tmp := quotient_tmp_3(quotient'length-1 downto 0);
        quotient_tmp := quotient_tmp srl 1;
        remainder<= resize(dividend - quotient_tmp*6, remainder'length);
        quotient<=quotient_tmp;
      when 7 =>
        quotient_tmp_7 := ((dividend*M_7_c) srl M_7_k_c);
        quotient_tmp:=quotient_tmp_7(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*7, remainder'length);
        quotient<=quotient_tmp;
      when 8 =>
        quotient <= dividend srl 3;
        remainder<= resize(dividend(2 downto 0), remainder'length);
      when 9 =>
        quotient_tmp_3 := (dividend*M_3_c) srl M_3_k_c;
        quotient_tmp := quotient_tmp_3(quotient'length-1 downto 0);
        quotient_tmp_3 := ((quotient_tmp*M_3_c) srl M_3_k_c);
        quotient_tmp := quotient_tmp_3(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*9, remainder'length);
        quotient<=quotient_tmp;
      when 10 =>
        quotient_tmp_5 := ((dividend srl 1)*M_5_c) srl M_5_k_c;
        quotient_tmp := quotient_tmp_5(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*10, remainder'length);
        quotient<=quotient_tmp;
      when 11 =>
        quotient_tmp_11 := (dividend*M_11_c) srl M_11_k_c;
        quotient_tmp:=quotient_tmp_11(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*11, remainder'length);
        quotient<=quotient_tmp;
      when 12 =>
        quotient_tmp_3 := ((dividend srl 2)*M_3_c) srl M_3_k_c;
        quotient_tmp:=quotient_tmp_3(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*12, remainder'length);
        quotient<=quotient_tmp;
      when 13 =>
        quotient_tmp_13 := (dividend*M_13_c) srl M_13_k_c;
        quotient_tmp := quotient_tmp_13(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*13, remainder'length);
        quotient<=quotient_tmp;
      when 14 =>
        quotient_tmp_7 := ((dividend srl 1)*M_7_c) srl M_7_k_c;
        quotient_tmp:=quotient_tmp_7(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*14, remainder'length);
        quotient<=quotient_tmp;
      when 15 =>
        quotient_tmp_3 := (dividend*M_3_c) srl M_3_k_c;
        quotient_tmp:=quotient_tmp_3(quotient'length-1 downto 0);
        quotient_tmp_5 := (quotient_tmp*M_5_c) srl M_5_k_c;
        quotient_tmp := quotient_tmp_5(quotient'length-1 downto 0);
        remainder<= resize(dividend - quotient_tmp*15, remainder'length);
        quotient<=quotient_tmp;
      when others =>
        quotient <= (others=>'0');
        remainder <= (others=>'0');
        notdefined <= '1';
    end case;
  end process div_comb;
end rtl;
