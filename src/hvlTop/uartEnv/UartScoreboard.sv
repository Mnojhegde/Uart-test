`ifndef UARTSCOREBOARD_INCLUDED_
`define UARTSCOREBOARD_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: UartScoreboard
// Used to compare the data sent/received by the master with the slave's data sent/received
//--------------------------------------------------------------------------------------------

class UartScoreboard extends uvm_scoreboard;
  `uvm_component_utils(UartScoreboard)

   //Declaring Tx class handle and Rx class hamdle
   UartTxTransaction uartTxTransaction;
   UartRxTransaction uartRxTransaction;

  //Variable: uartScoreboardTxAnalysisExport
  //Declaring analysis export for transmitting  Tx transaction object to scoreboard
  uvm_analysis_export #(UartTxTransaction) uartScoreboardTxAnalysisExport;


  //Variable: uartScoreboardRxAnalysisExport
  //Declaring analysis export for transmitting  Rx transaction object to scoreboard
  uvm_analysis_export #(UartRxTransaction) uartScoreboardRxAnalysisExport;

  //Variable: uartScoreboardTxAnalysisFifo
  //Used to store the uart Tx transaction
  uvm_tlm_analysis_fifo #(UartTxTransaction) uartScoreboardTxAnalysisFifo;

  //Variable: uartScoreboardRxAnalysisFifo
  //Used to store the uart Rx transaction
  uvm_tlm_analysis_fifo #(UartRxTransaction) uartScoreboardRxAnalysisFifo;

  //Variable: uartTxAgentConfig
  //Declaring handle for uart transmitter agent
  UartTxAgentConfig uartTxAgentConfig;

  //Variable: uartRxAgentConfig
  //Declaring handle for uart reciever agent
  UartRxAgentConfig uartRxAgentConfig;


  //Variable TransactionCount
  //to keep track of number of transaction
  int transmissionReciveingSucessfulCount = 0;

  //Variable bitDataCmpVerifiedTxRxCount
  //to keep track number verified comparisions
  int bitDataCmpVerifiedTxRxCount = 0;

  //Variable bitDataCmpFailedTxRxCount
  //to keep track number failed comparisions
  int bitDataCmpFailedTxRxCount = 0;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------

   extern function new( string name = "UartScoreboard" , uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern task compareTxRx(UartTxTransaction uartTxTransaction,UartRxTransaction uartRxTransaction);
 endclass : UartScoreboard

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialization of new memory
//
// Parameters:
//  name - UartScoreboard
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------

function UartScoreboard :: new(string name = "UartScoreboard" , uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------

function void UartScoreboard :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  uartScoreboardTxAnalysisExport = new("uartScoreboardTxAnalysisExport",this);
  uartScoreboardRxAnalysisExport = new("uartScoreboardRxAnalysisExport",this);
  uartScoreboardTxAnalysisFifo = new("uartScoreboardTxAnalysisFifo",this);
  uartScoreboardRxAnalysisFifo = new("uartScoreboardRxAnalysisFifo",this);
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase
// used to connect the analysis ports
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------

function void UartScoreboard :: connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  uartScoreboardTxAnalysisExport.connect(uartScoreboardTxAnalysisFifo.analysis_export);
  uartScoreboardRxAnalysisExport.connect(uartScoreboardRxAnalysisFifo.analysis_export);
endfunction : connect_phase

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Used to give delays and check the transmitted and recieved data are similar or not
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------

task UartScoreboard :: run_phase(uvm_phase phase);

  super.run_phase(phase);

  forever begin
   `uvm_info(get_type_name(),$sformatf("Before calling analysis fifo get method"),UVM_LOW)

      uartScoreboardTxAnalysisFifo.get(uartTxTransaction);
   `uvm_info(get_type_name(),$sformatf("Printing transmissionData= %p", uartTxTransaction.transmissionData),UVM_LOW)

      uartScoreboardRxAnalysisFifo.get(uartRxTransaction);
   `uvm_info(get_type_name(),$sformatf("Printing receivingData= %p", uartRxTransaction.receivingData),UVM_LOW)

    compareTxRx(uartTxTransaction,uartRxTransaction);
  end

endtask : run_phase


 task UartScoreboard :: compareTxRx(UartTxTransaction uartTxTransaction,UartRxTransaction uartRxTransaction);

      foreach(uartTxTransaction.transmissionData[i])
          begin
           if(uartTxTransaction.transmissionData[i] != uartRxTransaction.receivingData[i])
             begin
               bitDataCmpFailedTxRxCount++;
               `uvm_info(get_type_name(),$sformatf("Data Mismatch"),UVM_LOW)
              `uvm_info(get_type_name(),$sformatf("TransmissionData = %p,RecievingData = %p",uartTxTransaction.transmissionData[i],uartRxTransaction.receivingData[i]),UVM_LOW)
             end
           else
             begin
               bitDataCmpVerifiedTxRxCount++;
               `uvm_info(get_type_name(),$sformatf("Data Match"),UVM_LOW)
               `uvm_info(get_type_name(),$sformatf("TransmissionData = %b,RecievingData = %b",uartTxTransaction.transmissionData[i],uartRxTransaction.receivingData[i]),UVM_LOW)
             end/*
           if((uartTxAgentConfig.hasParity && uartRxAgentConfig.hasParity) == 1)
             begin
               if(uartTxTransaction.parity[i] != uartRxTransaction.parity[i])
                 begin
                   `uvm_error(get_type_name(),$sformatf("Parity mismatch"))
                 end
             end
           if(uartTxTransaction.breakingError[i] != uartRxTransaction.breakingError[i])
             begin
               `uvm_error(get_type_name(),$sformatf("Parity mismatch"))
             end
           if(uartTxTransaction.overrunError[i] != uartRxTransaction.overrunError[i])
             begin
               `uvm_error(get_type_name(),$sformatf("Parity mismatch"))
             end*/
            transmissionReciveingSucessfulCount++;
         `uvm_info(get_type_name(),$sformatf("transmissionData = %p,receivingData = %p,parity = %0b",uartTxTransaction.transmissionData,uartRxTransaction.receivingData,uartTxTransaction.parity),UVM_LOW)
         end
 endtask : compareTxRx
`endif
