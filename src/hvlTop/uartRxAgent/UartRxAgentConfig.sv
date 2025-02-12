`ifndef UARTRXAGENTCONFIG_INCLUDED_
`define UARTRXAGENTCONFIG_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: UartRxAgentConfig
//  Used as the configuration class for slave agent and it's components
//--------------------------------------------------------------------------------------------
class UartRxAgentConfig extends uvm_object;
  `uvm_object_utils(UartRxAgentConfig)
  
  uvm_active_passive_enum is_active;

  // config variables for rx agent
  bit hasCoverage;
  bit hasParity;
  overSamplingEnum uartOverSamplingMethod;
  baudRateEnum uartBaudRate;
  dataTypeEnum uartDataType;
  parityTypeEnum uartParityType;
  stopBitEnum  uartStopbit;
  rand int packetsNeeded;
  bit parityErrorInjection;
  bit OverSampledBaudFrequencyClk;
  bit uartStartBitDetectionStart=1;
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "UartRxAgentConfig");

endclass : UartRxAgentConfig

//--------------------------------------------------------------------------------------------
// Construct: new
//  name -  UartRxAgentConfig
//--------------------------------------------------------------------------------------------
function UartRxAgentConfig :: new(string name = "UartRxAgentConfig");
  super.new(name);
endfunction : new

`endif    
