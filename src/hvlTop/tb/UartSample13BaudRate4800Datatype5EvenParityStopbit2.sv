`ifndef UARTSAMPLE13BAUDRATE4800DATATYPE5EVENPARITYSTOPBIT2_INCLUDED_
`define UARTSAMPLE13BAUDRATE4800DATATYPE5EVENPARITYSTOPBIT2_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class:  UartSample13BaudRate4800Datatype5EvenParityStopbit2
// A test for 13 sampling condition
//--------------------------------------------------------------------------------------------
class  UartSample13BaudRate4800Datatype5EvenParityStopbit2 extends UartBaseTest;
  `uvm_component_utils( UartSample13BaudRate4800Datatype5EvenParityStopbit2)
    UartVirtualBaseSequence uartVirtualBaseSequence;
    //-------------------------------------------------------
    // Externally defined Tasks and Functions
    //-------------------------------------------------------
  extern function new(string name = " UartSample13BaudRate4800Datatype5EvenParityStopbit2" , uvm_component parent = null);
    extern virtual function void  build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
 
endclass :  UartSample13BaudRate4800Datatype5EvenParityStopbit2
//--------------------------------------------------------------------------------------------
// Constructor:new
//
// Paramters:
//
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
      function  UartSample13BaudRate4800Datatype5EvenParityStopbit2:: new(string name = " UartSample13BaudRate4800Datatype5EvenParityStopbit2" , uvm_component parent = null);
  super.new(name,parent);
endfunction  : new
//--------------------------------------------------------------------------------------------
// Function: build_phase
//  Create required ports
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void  UartSample13BaudRate4800Datatype5EvenParityStopbit2 :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  uartEnvConfig.uartTxAgentConfig.uartOverSamplingMethod = 13;
  uartEnvConfig.uartTxAgentConfig.uartBaudRate = 4800;
  uartEnvConfig.uartTxAgentConfig.uartDataType = 5;
  uartEnvConfig.uartTxAgentConfig.uartParityType = EVEN_PARITY;
  uartEnvConfig.uartTxAgentConfig.uartstopbit = 2;
  uartEnvConfig.uartTxAgentConfig.hasParity=1;
 
endfunction  : build_phase

//--------------------------------------------------------------------------------------------
// task:body
// Creates the required ports
//
// Parameters:
// phase - stores the current phase
//------------------------------------------------------------------------------------------
task UartSample13BaudRate4800Datatype5EvenParityStopbit2:: run_phase(uvm_phase phase);
  UartVirtualBaseSequence :: type_id ::set_type_override(UartVirtualTransmissionSequence::get_type());
  uartVirtualBaseSequence = UartVirtualBaseSequence :: type_id :: create("uartVirtualBaseSequence");
  uartVirtualBaseSequence.print();
  phase.raise_objection(this);
  uartVirtualBaseSequence.start(uartEnv.uartVirtualSequencer);
  #100000;
  phase.drop_objection(this);
  endtask : run_phase
`endif 
