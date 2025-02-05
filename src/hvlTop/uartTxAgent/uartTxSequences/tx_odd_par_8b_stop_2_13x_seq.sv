`ifndef TXODDPAR8BSTOP213XSEQ_INCLUDED_
`define TXODDPAR8BSTOP213XSEQ_INCLUDED_

class TxOddPar8b2Stop13xSeq extends UartTxBaseSequence;
  `uvm_object_utils(TxOddPar8b2Stop13xSeq)

   extern function new(string name = "TxOddPar8b2Stop13xSeq");
  extern virtual task body();

endclass : TxOddPar8b2Stop13xSeq

function  TxOddPar8b2Stop13xSeq :: new(string name= "TxOddPar8b2Stop13xSeq");
  super.new(name);
endfunction : new

task TxOddPar8b2Stop13xSeq :: body();
  super.body();
 
  `uvm_info(get_type_name(),$sformatf("TxOddPar8b2Stop13xSeq"),UVM_LOW);

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

