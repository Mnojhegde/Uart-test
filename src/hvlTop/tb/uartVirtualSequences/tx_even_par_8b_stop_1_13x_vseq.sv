`ifndef UARTVIRTRANSMISSIONSEQ1_INCLUDED_
`define UARTVIRTRANSMISSIONSEQ1_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: uart_virtual_seqs
//--------------------------------------------------------------------------------------------
class tx_even_par_8b_stop_1_13x_vseq extends UartVirtualBaseSequence;
  `uvm_object_utils(tx_even_par_8b_stop_1_13x_vseq)
  `uvm_declare_p_sequencer(UartVirtualSequencer)
  
//  UartTxBaseSequence uartTxBaseSequence;
//  UartRxBaseSequence uartRxBaseSequence;
//
   tx_odd_par_8b_stop_1_16x_seq tx_even_par_8b_stop_1_13x_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "tx_even_par_8b_stop_1_13x_vseq");
  extern virtual task body();

endclass : tx_even_par_8b_stop_1_13x_vseq
    
//--------------------------------------------------------------------------------------------
// Constructor:new
//
// Paramters:
// name - Instance name of the virtual_sequence
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function tx_even_par_8b_stop_1_13x_vseq :: new(string name = "tx_even_par_8b_stop_1_13x_vseq" );
  super.new(name);
endfunction : new
    
//--------------------------------------------------------------------------------------------
// task:body
// Creates the required ports
//
// Parameters:
// phase - stores the current phase
//--------------------------------------------------------------------------------------------

task tx_even_par_8b_stop_1_13x_vseq :: body();
  super.body();
  tx_even_par_8b_stop_1_13x_seq_h = tx_odd_par_8b_stop_1_16x_seq :: type_id :: create("tx_even_par_8b_stop_1_13x_seq_h");
 // uartRxBaseSequence = UartRxBaseSequence :: type_id :: create("uartRxBaseSequence");
  
  begin 
    tx_even_par_8b_stop_1_13x_seq_h.start(p_sequencer.uartTxSequencer);
  //  uartRxBaseSequence.start(p_sequencer.uartRxSequencer);
  end 


endtask : body

`endif

