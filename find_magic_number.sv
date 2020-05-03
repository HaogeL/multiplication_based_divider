//find magic number given 
module find_magic_number 

import uvm_pkg::*;
`include "uvm_macros.svh"
#(
  localparam shortint unsigned dividend_width = 32,
  //try k == [dividend_width,k_upbound]
  localparam shortint unsigned k_upbound = 40,
  localparam shortint unsigned divisor = 13 //change
);
virtual class function_class 
#(
  parameter shortint unsigned k_upbound = 40,
  parameter shortint unsigned dividend_width = 32,
  parameter shortint unsigned divisor = 3 
);

  static function bit check_convergence(
                           //max leagl k is k_upbound, to avoid overflow
                           input  shortint unsigned k,
                           output longint  unsigned magic_number, 
                           output shortint unsigned magic_number_width);
    shortint unsigned e; //e < divisor
    logic[k_upbound:0] power_2k;
    logic[dividend_width+$bits(e)-1:0] max_dividend_x_e;
    logic[$bits(magic_number)-1:0] magic_number1;

    if (k > k_upbound)
      $error("max legal k is k_upbound");
    else begin
      power_2k=2**k; //k+1 bits length
      e = (divisor - power_2k % divisor)%divisor;
      max_dividend_x_e=e*(2**dividend_width-1);
  
      if (power_2k > max_dividend_x_e) begin
        //magic_number is longint, should be enough
        magic_number  = (2**k) / divisor + 1; 
        magic_number1 = (2**k+e)/divisor    ; 
        if (magic_number != magic_number1)
          $error("internal check error");
        magic_number_width = $clog2(magic_number);
        return 1'b1;
      end else begin
        return 1'b0;
      end
    end
  endfunction: check_convergence
  /*
  static function loop_find(
                           output longint  unsigned magic_number  , 
                           output shortint unsigned magic_number_width);
                           
  endfunction: loop_find
  */
endclass: function_class


initial begin
  
  static longint  unsigned magic_number;
  static shortint unsigned magic_number_width;
  for (int k = dividend_width; k <= k_upbound; k++) begin 
    if(function_class#(k_upbound, dividend_width, divisor)::check_convergence(k, magic_number,
      magic_number_width)) begin
      `uvm_info("final results", $sformatf("k is %0d for \
      dividend_width == %0d and divisor == %0d", k, dividend_width, divisor), UVM_LOW)
      `uvm_info("final results", $sformatf("magic_number_width is %0d", magic_number_width), UVM_LOW)
      `uvm_info("final results", $sformatf("magic_number is %0h\n", magic_number), UVM_LOW)
      break;
    end else
      `uvm_info("final results", $sformatf("k==%0d doesn't converge for \
      dividend_width == %0d and divisor == %0d\n", k, dividend_width, divisor), UVM_LOW)
  end
end

endmodule: find_magic_number
