`ifndef UARTVIRTRANSMISSIONSEQ4_INCLUDED_
`define UARTVIRTRANSMISSIONSEQ4_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: uart_virtual_seqs
//--------------------------------------------------------------------------------------------
class tx_even_par_8b_stop_2_16x_vseq extends UartVirtualBaseSequence;
  `uvm_object_utils(tx_even_par_8b_stop_2_16x_vseq)
  `uvm_declare_p_sequencer(UartVirtualSequencer)
  
//  UartTxBaseSequence uartTxBaseSequence;
//  UartRxBaseSequence uartRxBaseSequence;
//
   tx_even_par_8b_stop_2_16x_seq tx_even_par_8b_stop_2_16x_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "tx_even_par_8b_stop_2_16x_vseq");
  extern virtual task body();

endclass : tx_even_par_8b_stop_2_16x_vseq
    
//--------------------------------------------------------------------------------------------
// Constructor:new
//
// Paramters:
// name - Instance name of the virtual_sequence
// parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function tx_even_par_8b_stop_2_16x_vseq :: new(string name = "tx_odd_par_8b_stop_1_16x_vseq" );
  super.new(name);
endfunction : new
