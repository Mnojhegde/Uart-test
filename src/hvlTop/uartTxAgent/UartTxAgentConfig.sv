`ifndef UARTTXAGENTCONFIG_INCLUDED_
`define UARTTXAGENTCONFIG_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: UartTxAgentConfig 
// Used as the configuration class for device0 agent and it's components
//--------------------------------------------------------------------------------------------
class UartTxAgentConfig extends uvm_object;
  `uvm_object_utils(UartTxAgentConfig)

  // Variable: is_active
  // Used for creating the agent in either passive or active mode
  uvm_active_passive_enum is_active;

  // config variables required for transmitting data
  bit hasCoverage;
  bit hasParity;
  overSamplingEnum uartOverSamplingMethod;
  baudRateEnum uartBaudRate;
  dataTypeEnum uartDataType;
  parityTypeEnum uartParityType;
  stopBitEnum uartStopBit;
  rand int packetsNeeded;
  bit parityErrorInjection;
  bit framingErrorInjection;
  bit OverSampledBaudFrequencyClk;  
  bit uartStartBitDetectionStart=1;
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "UartTxAgentConfig");

endclass : UartTxAgentConfig

//--------------------------------------------------------------------------------------------
// Construct: new
// name - UartTxAgentConfig 
//--------------------------------------------------------------------------------------------
function UartTxAgentConfig :: new(string name = "UartTxAgentConfig");
  super.new(name);
endfunction : new

`endif
