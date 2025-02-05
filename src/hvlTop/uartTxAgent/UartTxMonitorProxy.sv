`ifndef UARTTXMONITORPROXY_INCLUDED_
`define UARTTXMONITORPROXY_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: device0_monitor_proxy
//--------------------------------------------------------------------------------------------
class UartTxMonitorProxy extends uvm_monitor;
   //register with factory so can use create uvm_method and
   //override in future if necessary
  `uvm_component_utils(UartTxMonitorProxy)
 
  virtual UartTxMonitorBfm uartTxMonitorBfm;
  UartTxPacketStruct uartTxPacketStruct;
  UartTxAgentConfig uartTxAgentConfig;
  UartTxTransaction uartTxTransaction;
  //declaring analysis port for the monitor port

  event monitorSynchronizer;
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
  if(!(uvm_config_db #(UartTxAgentConfig) :: get(this , "" , "uartTxAgentConfig",uartTxAgentConfig)))
   begin 
     `uvm_fatal(get_type_name(),$sformatf("FAILED TO GET AGENT CONFIG"))
   end 

   uartTxTransaction = UartTxTransaction :: type_id :: create("uartTxTransaction");
endfunction : build_phase
    
//--------------------------------------------------------------------------------------------
// Task: run_phase
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task UartTxMonitorProxy :: run_phase(uvm_phase phase);
 UartConfigStruct uartConfigStruct;
 uartTxTransaction = UartTxTransaction::type_id::create("uartTxTransaction");
 UartTxConfigConverter :: from_Class(uartTxAgentConfig,uartConfigStruct);
// phase.raise_objection(this);
 //uartTxMonitorBfm.WaitForReset();
/* fork 
  uartTxMonitorBfm.GenerateBaudClk(uartConfigStruct);
 join_none
 $display("****************emtering forever loop**************");
 forever begin
 uartTxMonitorBfm.StartMonitoring(uartTxPacketStruct , uartConfigStruct);
 $display("**********************I AM HERE****************");


 UartTxSeqItemConverter::toTxClass(uartTxPacketStruct , uartTxAgentConfig , uartTxTransaction);
  foreach(uartTxTransaction.transmissionData[i])
   $display("MONITOR HAS received %b",uartTxPacketStruct.transmissionData[i]);
  $display("********parity result is %b*************",uartTxTransaction.parity);
phase.drop_objection(this);
//  ->monitorSynchronizer;
 end 
 */

 fork 
  begin 
   uartTxMonitorBfm.GenerateBaudClk(uartConfigStruct);
  end 
  begin 
      forever begin
       UartTxTransaction uartTxTransaction_clone;
       uartTxMonitorBfm.WaitForReset();
       uartTxMonitorBfm.StartMonitoring(uartTxPacketStruct , uartConfigStruct);
        $display("**********************I AM HERE****************");


	UartTxSeqItemConverter::toTxClass(uartTxPacketStruct , uartTxAgentConfig , uartTxTransaction);
	$cast(uartTxTransaction_clone, uartTxTransaction.clone());
    	uartTxMonitorAnalysisPort.write(uartTxTransaction_clone);
	$display("MONITOR HAS received %p",uartTxPacketStruct.transmissionData);
	$display("********parity result is %p*************",uartTxTransaction.parity);
	->monitorSynchronizer;
       end 
  end 
 join_any
endtask : run_phase
`endif
 
