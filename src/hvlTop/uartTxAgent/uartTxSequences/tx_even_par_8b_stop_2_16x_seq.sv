`ifndef TXEVENPAR8BSTOP216XSEQ_INCLUDED_
`define TXEVENPAR8BSTOP216XSEQ_INCLUDED_

class TxEvenPar8b2stop16xSeq extends UartTxBaseSequence;
  `uvm_object_utils(TxEvenPar8b2stop16xSeq)

   extern function new(string name = "TxEvenPar8b2stop16xSeq");
  extern virtual task body();

endclass : TxEvenPar8b2stop16xSeq

function  TxEvenPar8b2stop16xSeq :: new(string name= "TxEvenPar8b2stop16xSeq");
  super.new(name);
endfunction : new

task TxEvenPar8b2stop16xSeq :: body();
  super.body();
 
  `uvm_info(get_type_name(),$sformatf("TxEvenPar8b2stop16xSeq"),UVM_LOW);

  req = UartTxTransaction :: type_id :: create("req");

  repeat(1) begin 
  start_item(req);
  if( !(req.randomize()))
   `uvm_fatal(get_type_name(),"Randomization failed")
  req.print(); 
  finish_item(req);
  end 
endtask : body
 
`endif   

