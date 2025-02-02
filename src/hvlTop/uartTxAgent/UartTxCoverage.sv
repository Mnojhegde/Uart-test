`ifndef UARTTXCOVERAGE_INCLUDED_
`define UARTTXCOVERAGE_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: UartTxCoverage
// Description:
// Class for coverage report for UART
//--------------------------------------------------------------------------------------------
class UartTxCoverage extends uvm_subscriber #(UartTxTransaction);
  `uvm_component_utils(UartTxCoverage)

  //Declaring handle for tx agent configuration class 
  UartTxAgentConfig uartTxAgentConfig;
  
  //-------------------------------------------------------
  // Covergroup: UartTxCovergroup
  //  Covergroup consists of the various coverpoints based on
  //  no. of the variables used to improve the coverage.
  //-------------------------------------------------------
  covergroup UartTxCovergroup with function sample (UartTxAgentConfig uartTxAgentConfig, UartTxTransaction uartTxTransaction);
    TX_CP : coverpoint uartTxTransaction.transmissionData{
     option.comment = "tx";
     bins UART_TX = {[1:$]};}

    // DATA_WIDTH_CP : coverpoint uartTxAgentConfig.data_type{
    //   option.comment = "data_width";
    //   bins TRANSFER_BIT_5 = {5};
    //   bins TRANSFER_BIT_6 = {6};
    //   bins TRANSFER_BIT_7 = {7};
    //   bins TRANSFER_BIT_8 = {8};
    // }

    // PARITY_CP : coverpoint uartTxAgentConfig.parity_type{
    //   option.comment = "parity_type";
    //   bins EVEN_PARITY = {0};
    //   bins ODD_PARITY = {1};
    // }

    // STOP_BIT_CP : coverpoint uartTxAgentConfig.stop_bit{
    //   option.comment = "stop bit width";
    //   bins STOP_BIT_1 = {1};
    //   bins STOP_BIT_2 = {2};
    // }

    // DATA_WIDTH_CP_PARITY_CP : cross DATA_WIDTH_CP,PARITY_CP;
    // DATA_WIDTH_CP_STOP_BIT_CP :cross DATA_WIDTH_CP,STOP_BIT_CP;
    
 endgroup: UartTxCovergroup

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "UartTxCoverage", uvm_component parent = null);
  extern function void write(UartTxTransaction t);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void build_phase(uvm_phase phase);
endclass : UartTxCoverage

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name -UartTxCoverage
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function  UartTxCoverage::new(string name = "UartTxCoverage", uvm_component parent = null);
  super.new(name, parent);
  UartTxCovergroup = new();
endfunction : new

//--------------------------------------------------------------------------------------------
// Build phase
//
//--------------------------------------------------------------------------------------------
function void UartTxCoverage :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!(uvm_config_db #(UartTxAgentConfig) :: get(this,"","uartTxAgentConfig",this.uartTxAgentConfig)))
  `uvm_fatal("FATAL Tx AGENT CONFIG", $sformatf("Failed to get Tx agent config in coverage"))
endfunction : build_phase


//--------------------------------------------------------------------------------------------
// Function: write
// Overriding the write method declared in the parent class
//--------------------------------------------------------------------------------------------
function void UartTxCoverage::write(UartTxTransaction t);
  `uvm_info(get_type_name(),$sformatf("Before calling SAMPLE METHOD"),UVM_HIGH);
  foreach(t.transmissionData[i]) begin
    UartTxCovergroup.sample(uartTxAgentConfig,t);
  end
  `uvm_info(get_type_name(),"After calling SAMPLE METHOD",UVM_HIGH);
endfunction : write

//--------------------------------------------------------------------------------------------
// Function: report_phase
// Used for reporting the coverage instance percentage values
//--------------------------------------------------------------------------------------------
function void  UartTxCoverage::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("UART TX Agent Coverage = %0.2f %%",  UartTxCovergroup.get_coverage()), UVM_NONE);
endfunction: report_phase

`endif
