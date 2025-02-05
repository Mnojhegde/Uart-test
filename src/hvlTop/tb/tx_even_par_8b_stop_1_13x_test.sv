`ifndef TXEVENPAR8BSTOP113XTEST_INCLUDED_
`define TXEVENPAR8BSTOP113XTEST_INCLUDED_

class TxEvenPar8b1Stop13xTest extends UartBaseTest ;
  `uvm_component_utils(TxEvenPar8b1Stop13xTest)
  
  tx_even_par_8b_stop_1_13x_vseq tx_even_par_8b_stop_1_13x_vseq_h;

  UartEnvConfig           uartEnvConfig;
  UartEnv                 uartEnv;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "TxEvenPar8b1Stop13xTest", uvm_component parent = null);
  extern task run_phase(uvm_phase phase);
  extern  function void  build_phase(uvm_phase phase);
  extern  function void  setupUartEnvConfig();
  extern  function void  setupUartTxAgentConfig();
  extern  function void  setupUartRxAgentConfig();

endclass : TxEvenPar8b1Stop13xTest

function TxEvenPar8b1Stop13xTest::new(string name = "tx_odd_par_8b_stop_1_16x_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void TxEvenPar8b1Stop13xTest :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  setupUartEnvConfig();
  uartEnv = UartEnv :: type_id :: create("uartEnv" , this);
endfunction  : build_phase

 function void TxEvenPar8b1Stop13xTest :: setupUartEnvConfig();
   super.setupUartEnvConfig();
endfunction : setupUartEnvConfig 

 function void TxEvenPar8b1Stop13xTest :: setupUartTxAgentConfig();
  
  uartEnvConfig.uartTxAgentConfig = UartTxAgentConfig :: type_id :: create("uartTxAgentConfig");
  uartEnvConfig.uartTxAgentConfig.is_active = UVM_ACTIVE;
  uartEnvConfig.uartTxAgentConfig.hasCoverage = 1;
  uartEnvConfig.uartTxAgentConfig.hasParity = PARITY_ENABLED;
  uartEnvConfig.uartTxAgentConfig.uartOverSamplingMethod = OVERSAMPLING_13;
  uartEnvConfig.uartTxAgentConfig.uartBaudRate = BAUD_9600;
  uartEnvConfig.uartTxAgentConfig.uartDataType = FIVE_BIT;
  uartEnvConfig.uartTxAgentConfig.uartParityType = EVEN_PARITY;
  uvm_config_db #(UartTxAgentConfig) :: set(this,"*", "uartTxAgentConfig",uartEnvConfig.uartTxAgentConfig);

endfunction : setupUartTxAgentConfig

function void TxEvenPar8b1Stop13xTest :: setupUartRxAgentConfig();
super.setupUartRxAgentConfig();

endfunction : setupUartRxAgentConfig

task TxEvenPar8b1Stop13xTest::run_phase(uvm_phase phase);
  
 tx_even_par_8b_stop_1_13x_vseq_h = tx_even_par_8b_stop_1_13x_vseq::type_id::create("tx_even_par_8b_stop_1_13x_vseq_h");
  `uvm_info(get_type_name(),$sformatf("TxEvenPar8b1Stop13xTest"),UVM_LOW);
  phase.raise_objection(this);
    tx_even_par_8b_stop_1_13x_vseq_h.start(uartEnv.uartVirtualSequencer);
  phase.drop_objection(this);

endtask : run_phase

`endif

