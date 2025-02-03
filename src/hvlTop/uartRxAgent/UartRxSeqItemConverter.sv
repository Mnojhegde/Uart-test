`ifndef UARTRXSEQITEMCONVERTER_INCLUDED_
`define UARTRXSEQITEMCONVERTER_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: UartRxSeqItemConverter
// Description:
// class for converting the transaction items to struct and vice versa
//--------------------------------------------------------------------------------------------
class UartRxSeqItemConverter extends uvm_object;
  `uvm_object_utils(UartRxSeqItemConverter)
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  
  extern function new( string name = "UartRxSeqItemConverter");
  extern static function void fromRxClass(input UartRxTransaction uartRxTransaction, output UartRxPacketStruct uartRxPacketStruct);
  extern static function void toRxClass(input UartRxPacketStruct uartRxPacketStruct, output UartRxTransaction uartRxTransaction);
endclass :UartRxSeqItemConverter
    
//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
// name - UartRxSeqItemConverter
//--------------------------------------------------------------------------------------------
function UartRxSeqItemConverter :: new(string name = "UartRxSeqItemConverter");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: from_class
// Converting seq_item transactions into struct data items
//
// Parameters:
// name -UartRxTransaction, UartRxPacketStruct 
//--------------------------------------------------------------------------------------------

function void UartRxSeqItemConverter :: fromRxClass(input UartRxTransaction uartRxTransaction,input UartRxAgentConfig uartRxAgentConfig, output UartRxPacketStruct uartRxPacketStruct);
  int total_transmission = uartRxTransaction.receivingData.size();

  for(int receiving_number=0 ; receiving_number < total_transmission; receiving_number++)begin 
    for( int i=0 ; i< uartRxAgentConfig.uartDataType ; i++) begin  
      uartRxPacketStruct.receivingData[receiving_number][i] = uartRxTransaction.receivingData[receiving_number][i];
    end
    uartRxPacketStruct.parity[receiving_number] = uartRxTransaction.parity[receiving_number];
  end 
endfunction : fromRxClass
    
//--------------------------------------------------------------------------------------------
// Function: to_class
//  Converting struct data items into seq_item transactions
//
// Parameters:
//  name - UartRxPacketStruct,UartRxTransaction 
//--------------------------------------------------------------------------------------------

  function void UartRxSeqItemConverter :: toRxClass(input UartRxPacketStruct uartRxPacketStruct,input UartRxAgentConfig uartRxAgentConfig,inout UartRxTransaction uartRxTransaction);
  int total_receiving = $size(uartRxPacketStruct.receivingData);
      uartRxTransaction.receivingData = new[total_receiving];
  for(int receiving_number=0 ; receiving_number < total_receiving; receiving_number++)begin 
    for( int i=0 ; i<uartRxAgentConfig.uartDataType ; i++) begin
      uartRxTransaction.receivingData[receiving_number][i] = uartRxPacketStruct.receivingData[receiving_number][i];
    end
    uartRxTransaction.parity[receiving_number] = uartRxPacketStruct.parity[receiving_number];
  end
endfunction : toRxClass
   
`endif
