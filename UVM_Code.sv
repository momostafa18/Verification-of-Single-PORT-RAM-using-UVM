


/****************************** Define Interface   **************************************/
interface intf1;  
  bit [31:0]Data_in;
  bit [3:0]Address;
  bit WrEn;
  bit RdEn;
  bit CLK;
  bit RST ;
  bit [31:0]Data_out;
  bit DataVLD;
  always  #5 CLK = ~CLK;  
endinterface
	
/*************************** Package *****************************************************/
package pack1;

`include "uvm_macros.svh"
 import uvm_pkg ::*;
///////////////////////////////////////////////////////// 


    /******************************************************************
    ***************** Define My_Sequence_item class *******************
    *******************************************************************/
class Mo_sequence_item extends uvm_sequence_item;

     //-------------- registration ------------//
  `uvm_object_utils(Mo_sequence_item)
  
       //-------------- Construction ------------//
  function new(string name = "Mo_sequence_item");
    super.new(name);
  endfunction
  
  
        //----------- Define Variables ----------//
  rand bit [31:0]Data_in;
  randc bit [3:0]Address;
  randc bit [3:0]Address_2;
   bit WrEn;
   bit RdEn;
   bit CLK;
   bit RST;
   bit[31:0]Data_out;
   bit DataVLD ;
   bit RdEN_2;
  
endclass

    /************************************************************
    ******************* Define my_sequnce class *****************
    *************************************************************/
class Mo_sequence extends uvm_sequence #(Mo_sequence_item);
   
   int i;
   bit STATUS;

   
          //----------- Regsiteration ----------- //
  `uvm_object_utils(Mo_sequence)
  
         //------ instant seqence_item --------//
  Mo_sequence_item seq_item_inst;
  
         //-------------- Construction ------------//
  function new(string name = "Mo_sequence");
  super.new(name);
  endfunction
  
          //---------- pre_body task ----------//
  task pre_body ;
    seq_item_inst = Mo_sequence_item :: type_id:: create("seq_item_inst");
  endtask
          //----------- body_task ----------- //
  task body;
	 start_item(seq_item_inst);
	 seq_item_inst.RST = 0;
	 finish_item(seq_item_inst);

	for(i=0;i<16;i++)
	 begin
	 start_item(seq_item_inst);
	 seq_item_inst.WrEn = 1;
	 seq_item_inst.RdEn = 0;
	 seq_item_inst.RST = 1;
    STATUS = seq_item_inst.randomize(Address,Data_in);
    $display("The randomization state is %d",STATUS);
	 finish_item(seq_item_inst);
	 end 	
     seq_item_inst.Address.rand_mode(0); 
	for(i=0;i<16;i++)
	 begin
	 start_item(seq_item_inst);
	 seq_item_inst.Address.rand_mode(1); 
	 seq_item_inst.WrEn = 0;
	 seq_item_inst.RdEn = 1;
	 seq_item_inst.RST = 1;
    STATUS = seq_item_inst.randomize(Address);
    $display("The randomization state is %d",STATUS);
	 finish_item(seq_item_inst);
	 end 
  endtask
  
  
endclass


    /*****************************************************************
    ******************** Define My_Driver class **********************
    ******************************************************************/
class Mo_driver extends uvm_driver #(Mo_sequence_item);
      //-------------- registration ------------//
 `uvm_component_utils(Mo_driver)
 
      //--- istansiation of Virtual interface --//
  virtual intf1 vif1;
  
      //------ instant of sequence_item ------//
  Mo_sequence_item seq_item_inst;
  
      //-------------- Construction ------------//
  function new(string name = "Mo_driver",uvm_component parent = null);
  super.new(name,parent);
  endfunction
  
     //------------- bulid_phase --------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("BUILD_DRIVER");
	
	//Get virtual interface that contain concreat virtual interface from my_monitor scope 
    void'(uvm_config_db#(virtual intf1)::get(this,"","my_vif",vif1));
	
    seq_item_inst = Mo_sequence_item :: type_id:: create("seq_item_inst");
  endfunction
   
           //------------- Connect Phase ---------------//
  function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	$display("driver is connected");
  endfunction
  
          //------------- run_phase ---------------//
  task run_phase(uvm_phase phase);
     super.run_phase(phase);
    $display("Run Phase of Driver");
     forever 
       begin
         seq_item_port.get_next_item(seq_item_inst);
         @ (posedge vif1.CLK);
         begin
		 vif1.RST     <= seq_item_inst.RST;
         vif1.Data_in <= seq_item_inst.Data_in;
         vif1.Address <= seq_item_inst.Address;
         vif1.WrEn    <= seq_item_inst.WrEn;
         vif1.RdEn    <= seq_item_inst.RdEn;
		 vif1.DataVLD <= seq_item_inst.DataVLD;
         end
         #1
         seq_item_port.item_done();      
       end
  endtask
endclass

    /************************************************************
    ******************* Define My_Monitor class *****************
    *************************************************************/
class Mo_monitor extends uvm_monitor;
      //-------------- registration ------------//
      `uvm_component_utils(Mo_monitor)
	  
  //--- instansiation of uni-directional class ---// 
  uvm_analysis_port#(Mo_sequence_item) m_write_port;
          
		  //------ istansiation of Virtual interface ------//
   virtual intf1 vif1;
   
          //------ instansiation of my_sequence_item ------//
  Mo_sequence_item seq_item_inst;
      
	      //-------------- Construction ------------//
function new(string name = "Mo_monitor",uvm_component parent = null);
  super.new(name,parent);
  endfunction
  
          //------------------ bulid_phase ---------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("BUILD_Monitor");
	//Get virtual interface that contain concreat virtual interface from my_monitor scope 
    void'(uvm_config_db#(virtual intf1)::get(this,"","my_vif",vif1));
	
	//Handle seq_item_inst , uni-dierctional class
    seq_item_inst = Mo_sequence_item :: type_id:: create("seq_item_inst");
    m_write_port = new("m_write_port",this);
  endfunction
  
          //------------------ connect_phase ---------------//
  function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	$display("monitor is connected");
endfunction
  
          //------------------ run_phase ---------------//
  task run_phase(uvm_phase phase);
        super.run_phase(phase);
    $display("Run Phase of Monitor");
    forever
      begin
        @ (posedge vif1.CLK);
         begin
         seq_item_inst.Data_out <= vif1.Data_out;
		 seq_item_inst.Data_in <= vif1.Data_in;
         seq_item_inst.RdEn <= vif1.RdEn;
         seq_item_inst.WrEn <= vif1.WrEn;
         seq_item_inst.DataVLD <= vif1.DataVLD;
		 seq_item_inst.Address <= vif1.Address;
		 seq_item_inst.Address_2 <= seq_item_inst.Address;
		 seq_item_inst.RdEN_2 <= seq_item_inst.RdEn;
         $display("From monitor %d",vif1.Data_out); 
         m_write_port.write(seq_item_inst);  
         end
      end
  endtask 
endclass

    /**********************************************************
    ****************** Define My_Seqencer Class ***************
    ***********************************************************/
class Mo_sequencer extends uvm_sequencer#(Mo_sequence_item);

          //------------- registration -----------//
`uvm_component_utils(Mo_sequencer)
  
  	      //-------------- Construction ------------//
function new(string name = "Mo_sequencer",uvm_component parent = null);
  super.new(name,parent);
endfunction
  
  
        //------------ bulid_phase -------------//
    function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    $display("build_phase of my_sequencer is on the wheel!!");
  endfunction
 
 
        //------------ connect_phase -------------//
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    $display("connect_phase of my_sequencer is on the wheel!!");
  endfunction
  
        //------------ run_phase -------------//
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    $display("run_phase of my_sequencer");
  endtask
  
endclass

    /************************************************************
    ********************** Define my agent **********************
    *************************************************************/
class Mo_agent extends uvm_agent;

          //------------- registration --------------//
 `uvm_component_utils(Mo_agent)
 
  //instansiation of my sequencer , my monitor , my driver , virtual interface
 Mo_driver dr1; 
 Mo_monitor mon1; 
 Mo_sequencer seq1; 
 virtual intf1 vif1;
 
 //----- instansiation of analysis_port -----// 
 uvm_analysis_port#(Mo_sequence_item) m_write_port;
 
    	      //-------------- Construction ------------//
function new(string name = "Mo_agent",uvm_component parent = null);
  super.new(name,parent);
  endfunction
  
          //-------------- Build phase --------------//
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("Build_agent");
	//handle of my sequencer , my monitor , my driver
    dr1  = Mo_driver::type_id::create("dr1",this);
    mon1 = Mo_monitor::type_id::create("mon1",this);
    seq1 = Mo_sequencer :: type_id::create("seq1",this);
	  //Get virtual interface that contain concreate virtual interface from my_agent scope 
    void'(uvm_config_db#(virtual intf1)::get(this,"","my_vif",vif1));
     //Set content of  in1_vir in "DB" with {scope : D1 , name: my_vif , type : virtual mem_inter , full_path_istant}
    uvm_config_db#(virtual intf1)::set(this,"dr1","my_vif",vif1);
	//Set content of  in1_vir in "DB" with {scope : M1 , name: my_vif , type : virtual mem_inter , full_path_istant}
    uvm_config_db#(virtual intf1)::set(this,"mon1","my_vif",vif1);
    m_write_port = new("m_write_port",this);
  endfunction
          //---------------- connect_phase --------------//
    function void connect_phase(uvm_phase phase); 
      super.connect_phase(phase);
      $display("Connect_Agent");
      dr1.seq_item_port.connect(seq1.seq_item_export);
      mon1.m_write_port.connect(m_write_port);
  endfunction
          //---------------- run_phase --------------//
    task run_phase (uvm_phase phase);
    super.run_phase(phase);
    $display("run_phase of my_agent");
  endtask
  
endclass

    /**********************************************************
    **************** Define my scoreboard class ***************
    **********************************************************/

class Mo_scoreboard extends uvm_scoreboard;

          //------------- registration --------------//
  `uvm_component_utils(Mo_scoreboard)
  
        //------- instansiation of analysis export --------//
  uvm_analysis_export #(Mo_sequence_item) m_write_exp;
          //-------- instansiation of analysis_FIFO ---------//
  uvm_tlm_analysis_fifo#(Mo_sequence_item) m_tlm_fifo;
            //------ instansiation of my_sequence_item ------//
  Mo_sequence_item seq_item_inst;
           //--------- Temp dynamic array to hold values for the checking mechanism--///
  bit [31:0] mem_model[15:0];
  
          //------------- Construction --------------//
  function new(string name = "Mo_scoreboard",uvm_component parent = null);
    super.new(name,parent);
  endfunction
           //------------------- bulid_phase --------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("Build_score");
    //Handle seq_item_inst , uni-dierctional classes
    m_write_exp = new ("m_write_exp",this);
    m_tlm_fifo  = new ("m_tlm_fifo",this);
    seq_item_inst = Mo_sequence_item :: type_id:: create("seq_item_inst");
  endfunction
  
       //-------------- connect_phase -----------------//
      function void connect_phase(uvm_phase phase); 
      super.connect_phase(phase);
        $display("Connect_scor");
        m_write_exp.connect(m_tlm_fifo.analysis_export); 
     endfunction
	 
	   //-------------- run_phase -----------------//
  task run_phase(uvm_phase phase);
        super.run_phase(phase);
    $display("Run Phase of Scoreboard");
    forever 
        begin
		//------ Checking mechanism to check if the data is written to the memory and read rightly from the memory -------//
	  m_tlm_fifo.get_peek_export.get(seq_item_inst); 	  
      if(seq_item_inst.WrEn  && !seq_item_inst.RdEn)
      begin
         mem_model[seq_item_inst.Address] = seq_item_inst.Data_in;
        $display("mem_model[%p] = %p", seq_item_inst.Address,mem_model[seq_item_inst.Address]);
      end
      else if(!seq_item_inst.WrEn  && seq_item_inst.RdEn)
      begin
          if(seq_item_inst.Data_out == mem_model[seq_item_inst.Address_2] && seq_item_inst.RdEN_2)
            $display("Data is read correctly @ address = %p , WrData = %p , RdData = %p "  , seq_item_inst.Address_2,mem_model[seq_item_inst.Address_2] ,seq_item_inst.Data_out);          
          
          else
            $display("Data is NOT read correctly @ address = %p , WrData = %p , RdData = %p " , seq_item_inst.Address_2 ,mem_model[seq_item_inst.Address_2] ,seq_item_inst.Data_out);    
      end
	end
  endtask
  
endclass

    /*********************************************************
    ******************* Define my subscriber *****************
    **********************************************************/
class Mo_subscriber extends uvm_subscriber#(Mo_sequence_item);
  
//no need  for uvm_analysis_imp cuz uvm_subscriber contain already an instance of it 
// this instance name is analysis_export
// uvm_analysis_imp#(packet , my_subscriber) uSub_analysis_imp;
  
  //------------- registration --------------//
  `uvm_component_utils(Mo_subscriber)
  
              //------ instansiation of my_sequence_item ------//
   Mo_sequence_item seq_item_inst;
   
   // covergroup for the covrage of the output variables //
      covergroup cov_inst();
      coverpoint seq_item_inst.RST {
        bins bin_1 []={0,1};
        bins bin_2 =(0=>1); 
        bins bin_3 =(1=>0); 
      }
      coverpoint seq_item_inst.Address;
      cross1 :cross seq_item_inst.WrEn,seq_item_inst.RdEn,seq_item_inst.RST;
	  endgroup
	  
	  //------------- Construction --------------//
  function new(string name = "Mo_subscriber",uvm_component parent = null);
  super.new(name,parent);
  endfunction
  
          //------------------- bulid_phase --------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("BUILD_subscriber");
    seq_item_inst = Mo_sequence_item :: type_id:: create("seq_item_inst");
  endfunction
  
            //------------------- connect_phase --------------//
  function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	$display("subscriber is connected");
  endfunction
  
          //------------------- run_phase --------------//
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
    $display("Run Phase of subscriber");
  endtask
          //------ Implementation of write function and MUST be implemented as we are dealing with the imp class instantiated in the parent class-----//
  function void write(Mo_sequence_item t);
   seq_item_inst = t;                           //dah msh fahem by3ml eh !! estfdt eh mn elsatr dh ?
   $display("My Data in Subscriber is %d is",seq_item_inst);
  endfunction
  
endclass


    /*******************************************************
    ******************* Define my env **********************
    ********************************************************/
class Mo_env extends uvm_env;

  //------------- registration --------------//
  `uvm_component_utils(Mo_env)
  
  //instansiation of my sequencer , my monitor , my driver
  Mo_agent ag1;
  Mo_scoreboard scor1;
  Mo_subscriber sub1;

  //istansiation of Virtual interface 
  virtual intf1 vif1;
  
  //------------- Construction --------------//
  function new(string name = "Mo_env",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  //------------------- bulid_phase --------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("BUILD_env");
	
	//Handle my_agent , my_scorboard , my_subscriber
    ag1 = Mo_agent::type_id::create("ag1",this);
    scor1 = Mo_scoreboard::type_id::create("scor1",this);
    sub1 = Mo_subscriber::type_id::create("sub1",this);
	//Get virtual interface that contain concreat virtual interface from my_env scop
    void'(uvm_config_db#(virtual intf1)::get(this,"","my_vif",vif1));
	//Set content of  in1_vir in "DB" with {scope : A1 , name: my_vif , type : virtual mem_inter , full_path_istant}
    uvm_config_db#(virtual intf1)::set(this,"ag1","my_vif",vif1);
    $display(vif1);
  endfunction
  
    //------------------- connect_phase --------------//
    function void connect_phase(uvm_phase phase); 
      super.connect_phase(phase);
      $display("Connect_Env");
      ag1.m_write_port.connect(scor1.m_write_exp);
      ag1.m_write_port.connect(sub1.analysis_export);
  endfunction
  
    //------------------- run_phase --------------//
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
    $display("Run Phase of ENV");
endtask
  

endclass

    /*************************************************
    ***************** Define my_test *****************
    *************************************************/
class Mo_test extends uvm_test;

        //---------------- registration -----------------//
  `uvm_component_utils(Mo_test)
  
          //---- instansiation of my_env and sequence ----//
  Mo_env env1;
  Mo_sequence seq_inst;
          //---- instansiation of my_env and sequence ----//
  virtual intf1 vif1;
          //---------------- construction -----------------//
function new(string name = "Mo_test",uvm_component parent = null);
  super.new(name,parent);
  endfunction
          //---------------- Build phase ----------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("BUILD_test");
	 //Handle my_env class 
    env1 = Mo_env::type_id::create("env1",this);
	//Get virtual interface that contain concreat interface from UVM_test_top 
    void'(uvm_config_db#(virtual intf1)::get(this,"","my_vif",vif1));
	//Set content of  in1_vir in "DB" with {scope : E1 , name: my_vif , type : virtual mem_inter , full_path_istant}
    uvm_config_db#(virtual intf1)::set(this,"env1","my_vif",vif1);
    //Handle my_seq class 
    seq_inst = Mo_sequence::type_id::create("seq_inst",this);
  endfunction
  
          //---------------- connect_phase ----------------//
  function void connect_phase(uvm_phase phase); 
      super.connect_phase(phase);
      $display("Connect_Test");
  endfunction
  
          //---------------- run_phase ----------------//
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    $display("run_phase of my_test");
    phase.raise_objection(this,"Starting Sequence");
    seq_inst.start(env1.ag1.seq1);
    phase.drop_objection(this,"Finished Sequence");
  endtask
endclass


endpackage
///////////////////////////////////////////////////
