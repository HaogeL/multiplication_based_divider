module multiplication_based_divider
#(localparam shortint unsigned dividend_width_p    = 32, //dividend width
  //the maximun value the divisor can be 
  localparam shortint unsigned max_divisor_value_p = 15)  
(
  input  logic[dividend_width_p-1:0]              dividend ,
  input  logic[$clog2(max_divisor_value_p)-1:0]   divisor  ,
  output logic[dividend_width_p-1:0]              quotient ,
  output logic[$clog2(max_divisor_value_p-1)-1:0] remainder,
  output logic                                    err
);
//magic number declaration>>>>>>>>>>>>>>>>>>>>>>>>>>>
  //(2³³ + 1) / 3 = 32'hAAAA_AAAB
  const logic unsigned[31:0] M_3_c = 32'hAAAA_AAAB; //slr 33 bits
  const shortint M_3_k_c = 33; //shortint to store k value, should be enough

  //(2³⁴ + 1) / 5 = 32'hCCCC_CCCD
  const logic unsigned[31:0] M_5_c= 32'hCCCC_CCCD; //slr 34 bits
  const shortint M_5_k_c = 34;//shortint to store k value, should be enough

  // no need to pre-compute M_6_c
  //(2³⁴ + 1) / 6 = 32'hAAAA_AAAB
  //const unsigned[31:0] M_6_c = 32'hAAAA_AAAB;//slr 34 bits

  //(2³⁵ + 6) / 7 = 33'h1_2492_4925
  const logic unsigned[32:0] M_7_c = 33'h1_2492_4925; //slr 35 bits
  const shortint M_7_k_c = 35;

  //no need to pre-compute M_9_c

  //no need to pre-compute M_10_c
  
  const logic unsigned[31:0] M_11_c = 32'hba2e_8ba3; //slr 35 bits
  const shortint M_11_k_c = 35;

  const logic unsigned[30:0] M_13_c = 31'h4ec4_ec4f; //slr 34 bits
  const shortint M_13_k_c = 34;
//magic number declaration<<<<<<<<<<<<<<<<<<<<<<<<<<<
always_comb begin
  err = 0;
  remainder='0;
  case(divisor)
    'h1:begin
      quotient = dividend;
      remainder= '0;
    end
    'h2:begin
      quotient = dividend>>1;
      remainder[$left(remainder):1]='0;
      remainder[0]=dividend[0];
    end
    'h3:begin
      quotient=((($bits(M_3_c)+$bits(quotient))'(dividend*M_3_c))>>M_3_k_c);
      //unmatching bit length assignment, aligned to LSB
      //[$bits(quotient)-1:0];
      remainder=dividend-quotient*divisor;
    end
    'h4:begin
      quotient = dividend>>2;
      remainder[1:0]=dividend[1:0];
    end
    'h5:begin
      quotient=((($bits(M_5_c)+$bits(quotient))'(dividend*M_5_c))>>M_5_k_c);
      remainder=dividend-quotient*divisor;
    end
    'h6:begin
      quotient = dividend>>1;
      quotient=((($bits(M_3_c)+$bits(quotient))'(quotient*M_3_c))>>M_3_k_c);
      remainder=dividend-quotient*divisor;
    end
    'h7:begin
      quotient=((($bits(M_7_c)+$bits(quotient))'(dividend*M_7_c))>>M_7_k_c);
      remainder=dividend-quotient*divisor;
    end
    'h8:begin
      quotient = dividend>>3;
      remainder[2:0]=dividend[2:0];
    end
    'h9:begin
      quotient=((($bits(M_3_c)+$bits(quotient))'(dividend*M_3_c))>>M_3_k_c);
      quotient=((($bits(M_3_c)+$bits(quotient))'(quotient*M_3_c))>>M_3_k_c);
      remainder=dividend-quotient*divisor;
    end
    'ha:begin
      quotient = dividend>>1;
      quotient=((($bits(M_5_c)+$bits(quotient))'(quotient*M_5_c))>>M_5_k_c);
      remainder=dividend-quotient*divisor;
    end
    'hb:begin
      quotient=((($bits(M_11_c)+$bits(quotient))'(dividend*M_11_c))>>M_11_k_c);
      remainder=dividend-quotient*divisor;
    end
    'hc:begin
      quotient = dividend>>2;
      quotient=((($bits(M_3_c)+$bits(quotient))'(quotient*M_3_c))>>M_3_k_c);
      remainder=dividend-quotient*divisor;
    end
    'hd:begin
      quotient=((($bits(M_13_c)+$bits(quotient))'(dividend*M_13_c))>>M_13_k_c);
      remainder=dividend-quotient*divisor;
    end
    'he:begin
      quotient = dividend>>1;
      quotient=((($bits(M_7_c)+$bits(quotient))'(quotient*M_7_c))>>M_7_k_c);
      remainder=dividend-quotient*divisor;
    end
    'hf:begin
      quotient=((($bits(M_3_c)+$bits(quotient))'(dividend*M_3_c))>>M_3_k_c);
      quotient=((($bits(M_5_c)+$bits(quotient))'(quotient*M_5_c))>>M_5_k_c);
      remainder=dividend-quotient*divisor;
    end
    default: begin
      quotient = '0;
      remainder='0;
      err = '1;
    end
  endcase
end

endmodule: multiplication_based_divider
