`ifndef UARTTXBASESEQUENCE_INCLUDED_
`define UARTTXBASESEQUENCE_INCLUDED_

class UartTxBaseSequence extends uvm_sequence#(UartTxTransaction);
  `uvm_object_utils(UartTxBaseSequence)
  
  extern function new(string name = "UartTxBaseSequence");
  extern virtual task body();
  rand int array_size;
endclass : UartTxBaseSequence

function  UartTxBaseSequence :: new(string name= "UartTxBaseSequence");
  super.new(name);
 
endfunction : new

task UartTxBaseSequence :: body();
  super.body();

  req = UartTxTransaction :: type_id :: create("req");
  start_item(req);
  if(!(req.randomize() with{transmissionData.size()==array_size;}))
   `uvm_fatal("[tx sequence]","randomization failed")

  req.print();
  finish_item(req);
endtask : body
 
`endif   




