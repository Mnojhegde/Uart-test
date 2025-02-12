`ifndef UARTEVENPARITYWITHERRORTEST_INCLUDED_
`define UARTEVENPARITYWITHERRORTEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class:  UartBaseTest
// Base test has the test scenarios for testbench which has the env, config, etc.
// Sequences are created and started in the test
//--------------------------------------------------------------------------------------------
class UartEvenParityWithErrorTest extends UartBaseTest;
 
   `uvm_component_utils(UartEvenParityWithErrorTest)
    
    UartVirtualBaseSequence uartVirtualBaseSequence;
    //-------------------------------------------------------
    // Externally defined Tasks and Functions
    //-------------------------------------------------------
    extern function new(string name = "UartEvenParityWithErrorTest" , uvm_component parent = null);
    extern virtual function void  build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : UartEvenParityWithErrorTest
		     
//--------------------------------------------------------------------------------------------
// Constructor:new
//
// Paramters:
//
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function UartEvenParityWithErrorTest :: new(string name = "UartEvenParityWithErrorTest" , uvm_component parent = null);
  super.new(name,parent);
endfunction  : new
		          
//--------------------------------------------------------------------------------------------
// Function: build_phase
//  Create required ports
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void UartEvenParityWithErrorTest :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  uartEnvConfig.uartTxAgentConfig.hasParity=1;
  uartEnvConfig.uartTxAgentConfig.uartParityType = EVEN_PARITY;
  uartEnvConfig.uartTxAgentConfig.parityErrorInjection =1;
endfunction  : build_phase
			         
				    
//--------------------------------------------------------------------------------------------
// task:body
// Creates the required ports
//
// Parameters:
// phase - stores the current phase
//------------------------------------------------------------------------------------------
task UartEvenParityWithErrorTest:: run_phase(uvm_phase phase);
  UartVirtualBaseSequence :: type_id ::set_type_override(UartVirtualTransmissionSequence::get_type());
  uartVirtualBaseSequence = UartVirtualBaseSequence :: type_id :: create("uartVirtualBaseSequence");
  uartVirtualBaseSequence.print();
  phase.raise_objection(this);
  uartVirtualBaseSequence.start(uartEnv.uartVirtualSequencer);
  #100000;
  phase.drop_objection(this);
  endtask : run_phase
`endif  
