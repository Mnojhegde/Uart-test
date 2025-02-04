`ifndef UARTTXMONITORPROXY_INCLUDED_
`define UARTTXMONITORPROXY_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: device0_monitor_proxy
//--------------------------------------------------------------------------------------------
class UartTxMonitorProxy extends uvm_component;
   //register with factory so can use create uvm_method and
   //override in future if necessary
  `uvm_component_utils(UartTxMonitorProxy)
 
  virtual UartTxMonitorBfm uartTxMonitorBfm;
  UartTxPacketStruct uartTxPacketStruct;
  UartTxAgentConfig uartTxAgentConfig;
   
  //declaring analysis port for the monitor port
  uvm_analysis_port#(UartTxTransaction) uartTxMonitorAnalysisPort;
  
//-------------------------------------------------------
// Externally defined Tasks and Functions
//-------------------------------------------------------
  
  extern function  new( string name = "UartTxMonitorProxy" , uvm_component parent = null);
  extern virtual function void build_phase( uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
endclass : UartTxMonitorProxy
//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
// name - UartTxMonitorProxy
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function  UartTxMonitorProxy :: new( string name = "UartTxMonitorProxy" , uvm_component parent = null);
  super.new(name,parent);
  uartTxMonitorAnalysisPort = new("uartTxMonitorAnalysisPort",this);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void UartTxMonitorProxy :: build_phase( uvm_phase phase);
  super.build_phase(phase);

  if(!(uvm_config_db #(virtual UartTxMonitorBfm) :: get(this, "" , "uartTxMonitorBfm",uartTxMonitorBfm)))
   begin 
    `uvm_fatal(get_type_name(),$sformatf("FAILED TO GET VIRTUAL BFM HANDLE "))
   end 
  if(!(uvm_config_db #(UartTxAgentConfig) :: get(this, "" ,"uartTxAgentConfig",uartTxAgentConfig)))
    begin 
      `uvm_fatal(get_type_name(),$sformatf("FAILED TO GET AGENT CONFIG"))
    end  
endfunction : build_phase
    
//--------------------------------------------------------------------------------------------
// Task: run_phase
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task UartTxMonitorProxy :: run_phase(uvm_phase phase);
  
   UartTxTransaction uartTxTransaction;
   UartConfigStruct uartConfigStruct;
  
   uartTxTransaction = UartTxTransaction::type_id::create("uartTxTransaction");
   
   UartTxConfigConverter::from_Class(uartTxAgentConfig , uartConfigStruct);
   uartTxMonitorBfm.WaitForReset();
   fork 
      uartTxMonitorBfm.GenerateBaudClk(uartConfigStruct);
   join_none

   forever begin
      UartTxSeqItemConverter :: fromTxClass(uartTxTransaction,uartTxAgentConfig,uartTxPacketStruct);
       UartTxConfigConverter::from_Class(uartTxAgentConfig , uartConfigStruct);
       uartTxMonitorBfm.Deserializer(uartTxPacketStruct, uartConfigStruct);

       UartTxSeqItemConverter::toTxClass(uartTxPacketStruct,uartTxAgentConfig,uartTxTransaction);

      `uvm_info("Tx_Monitor_BFM",$sformatf("data in Tx monitor proxy is %p",uartTxTransaction.transmissionData),UVM_LOW)
      `uvm_info("Tx_Monitor_BFM",$sformatf("parity in Tx monitor proxy is %p",uartTxTransaction.parity),UVM_LOW)
      
      uartTxMonitorAnalysisPort.write(uartTxTransaction);
   
   end

endtask : run_phase
`endif
 
