`ifndef UARTRXAGENTCONFIG_INCLUDED_
`define UARTRXAGENTCONFIG_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: UartRxAgentConfig
//  Used as the configuration class for slave agent and it's components
//--------------------------------------------------------------------------------------------
class UartRxAgentConfig extends uvm_object;
  `uvm_object_utils(UartRxAgentConfig)
  
  //Variable: is_active
  //Used to declare whether the agent is active or passive
  uvm_active_passive_enum is_active;

  bit hasCoverage;
  bit hasParity;
  OVER_SAMPLING_E uartOverSamplingMethod;
  BAUD_RATE_E uartBaudRate;
  DATA_TYPE_E uartDataType;/* these enum can be randomized and can apply inline constraint in test file*/
  PARITY_TYPE_E uartParityType;
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "UartRxAgentConfig");

endclass : UartRxAgentConfig

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name -  UartRxAgentConfig
//--------------------------------------------------------------------------------------------
function UartRxAgentConfig :: new(string name = "UartRxAgentConfig");
  super.new(name);
endfunction : new

`endif    
