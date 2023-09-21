

module TestBench();
 import uvm_pkg ::*;
 import pack1 ::*;
 `include "uvm_macros.svh"

  intf1 in1();

reg_file DUT(in1.RdEn,in1.WrEn,in1.Data_in,in1.Address,in1.CLK,in1.RST,in1.DataVLD,in1.Data_out);
  initial 
   begin
     uvm_config_db#(virtual intf1)::set(null,"uvm_test_top","my_vif",in1);
     run_test("Mo_test");
    end
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1);
    end

endmodule