`ifndef UARTRXMONITORPROXY_INCLUDED_
`define UARTRXMONITORPROXY_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: UartRxMonitorProxy
// This is the Receiver proxy monitor on the HVL side
//--------------------------------------------------------------------------------------------

class UartRxMonitorProxy extends uvm_monitor;
  `uvm_component_utils(UartRxMonitorProxy)

  // Variable:  uartRxMonitorBfm
  // Handle for receiver monitor bfm
  virtual UartRxMonitorBfm uartRxMonitorBfm;

  UartRxAgentConfig uartRxAgentConfig;
  UartRxPacketStruct uartRxPacketStruct;

  UartRxTransaction uartRxTransaction;

  //Declaring Monitor Analysis Import
  uvm_analysis_port#(UartRxTransaction) uartRxMonitorAnalysisPort;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function  new( string name = "UartRxMonitorProxy" , uvm_component parent = null);
  extern virtual function void build_phase( uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
endclass : UartRxMonitorProxy

  
//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
// name - UartRxMonitorProxy
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function  UartRxMonitorProxy :: new( string name = "UartRxMonitorProxy" , uvm_component parent = null);
  super.new(name,parent);
  uartRxMonitorAnalysisPort = new("uartRxMonitorAnalysisPort",this);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// uartRxMonitorBfm configuration is obtained in build_phase
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void UartRxMonitorProxy :: build_phase( uvm_phase phase);
  super.build_phase(phase);
  if(!(uvm_config_db #(virtual UartRxMonitorBfm) :: get(this, "" , "uartRxMonitorBfm",uartRxMonitorBfm))) begin 
    `uvm_fatal(get_type_name(),$sformatf("FAILED TO GET VIRTUAL BFM HANDLE "))
  end
  if(!(uvm_config_db #(UartRxAgentConfig) :: get(this, "" ,"uartRxAgentConfig",uartRxAgentConfig)))
    begin 
      `uvm_fatal(get_type_name(),$sformatf("FAILED TO GET AGENT CONFIG"))
    end  
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Task: run_phase
// <Description_here>
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
    
task UartRxMonitorProxy :: run_phase(uvm_phase phase);
  UartConfigStruct uartConfigStruct;

  uartRxTransaction = UartRxTransaction::type_id::create("uartRxTransaction");
  
   UartRxConfigConverter::from_Class(uartRxAgentConfig , uartConfigStruct);
   
  
  fork 
       uartRxMonitorBfm.GenerateBaudClk(uartConfigStruct);
   join_none
   uartRxMonitorBfm.WaitForReset();
   forever begin
     UartRxTransaction uartRxTransaction_clone;
     UartRxSeqItemConverter :: fromRxClass(uartRxTransaction,uartRxAgentConfig,uartRxPacketStruct);
     UartRxConfigConverter::from_Class(uartRxAgentConfig , uartConfigStruct);
     uartRxMonitorBfm.StartMonitoring(uartRxPacketStruct, uartConfigStruct);

     UartRxSeqItemConverter::toRxClass(uartRxPacketStruct,uartRxAgentConfig,uartRxTransaction);

     `uvm_info("Rx_Monitor_BFM",$sformatf("data in Rx monitor proxy is %p",uartRxTransaction.receivingData),UVM_LOW)
     `uvm_info("Rx_Monitor_BFM",$sformatf("parity in Rx monitor proxy is %p",uartRxTransaction.parity),UVM_LOW)
      
     $cast(uartRxTransaction_clone, uartRxTransaction.clone());  
     uartRxMonitorAnalysisPort.write(uartRxTransaction_clone);
   
   end

endtask : run_phase
`endif
