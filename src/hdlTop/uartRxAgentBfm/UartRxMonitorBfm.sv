// Importing Uart global package
//-------------------------------------------------------
import UartGlobalPkg::*;

//--------------------------------------------------------------------------------------------
// Interface : UartrxMonitorBfm
//  Connects the master monitor bfm with the master monitor prox
//--------------------------------------------------------------------------------------------
interface UartRxMonitorBfm (input  logic   clk,
                            input  logic reset,
                            input  logic   rx
                           );

  //-------------------------------------------------------
  // Importing uvm package file
  //-------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  //-------------------------------------------------------
  // Importing the Transmitter package file
  //-------------------------------------------------------
   
  string name = "UART_TRANSMITTER_MONITOR_BFM"; 

  //Variable: baudClk
  //baud clock for uart transmisson/reception
	bit baudClk;
	
	bit oversamplingClk;

	UartTransmitterStateEnum uartTransmitterState;
	
  //-------------------------------------------------------
  // Used to display the name of the interface
  //-------------------------------------------------------
  initial begin
    `uvm_info(name, $sformatf(name),UVM_LOW)
  end

  
  //------------------------------------------------------------------
  // Task: Baud_div
  // this task will calculate the baud divider based on sys clk frequency
  //-------------------------------------------------------------------
  task GenerateBaudClk(inout UartConfigStruct uartConfigStruct);
      real clkPeriodStartTime; 
      real clkPeriodStopTime;
      real clkPeriod;
      real clkFrequency;
      int baudDivisor;
      @(posedge clk);
      clkPeriodStartTime = $realtime;
      @(posedge clk);
      clkPeriodStopTime = $realtime; 
      clkPeriod = clkPeriodStopTime - clkPeriodStartTime;
      clkFrequency = ( 10 **9 )/ clkPeriod;
       
      if(uartConfigStruct.OverSampledBaudFrequencyClk==1)begin 
      baudDivisor = (clkFrequency)/(uartConfigStruct.uartOverSamplingMethod * uartConfigStruct.uartBaudRate); 
      end 
      else begin 
      baudDivisor = (clkFrequency)/(uartConfigStruct.uartBaudRate);
      end 
      BaudClkGenerator(baudDivisor);
    endtask

  //------------------------------------------------------------------
  // Task: BaudClkGenerator
  // this task will generate baud clk based on baud divider
  //-------------------------------------------------------------------
    task BaudClkGenerator(input int baudDiv);
      static int count=0;
      forever begin 
        @(posedge clk or negedge clk)
    
        if(count == (baudDiv-1))begin 
          count <= 0;
          baudClk <= ~baudClk;
        end 
        else begin 
          count <= count +1;
        end   
      end
    endtask

  //--------------------------------------------------------------------------------------------
  // Task: baudClk_counter
  //  This task will count the number of cycles of baudClk and generate oversamplingClk to sample data
  //--------------------------------------------------------------------------------------------

  task baudClkCounter(input int uartOverSamplingMethod);
		static int countbaudClk = 0;
		forever begin
			@(posedge baudClk)
			if(countbaudClk == (uartOverSamplingMethod/2)-1) begin
				oversamplingClk = ~oversamplingClk;
				countbaudClk=0;
			end
			else begin
				countbaudClk = countbaudClk+1;
			end 
	  end
  endtask
	
  //-------------------------------------------------------
  // Task: WaitForReset
  //  Waiting for the system reset
  //-------------------------------------------------------
  task WaitForReset();
    @(negedge reset);
    `uvm_info(name, $sformatf("system reset activated"), UVM_LOW)
    uartTransmitterState = RESET;
    @(posedge reset);
    `uvm_info(name, $sformatf("system reset deactivated"), UVM_LOW)
     uartTransmitterState = IDLE;
  endtask: WaitForReset

	task StartMonitoring(inout UartRxPacketStruct uartRxPacketStruct , inout UartConfigStruct uartConfigStruct);
		// fork 
  //   	baudClkCounter(uartConfigStruct.uartOverSamplingMethod);
		Deserializer(uartRxPacketStruct,uartConfigStruct);
	 	// join_any
   // 	disable fork ;
	endtask 

  //-------------------------------------------------------
  // Task: DeSerializer
  //  converts serial data to parallel
  //-------------------------------------------------------
task Deserializer(inout UartRxPacketStruct uartRxPacketStruct, inout UartConfigStruct uartConfigStruct);
      	@(negedge rx);
       	if(uartConfigStruct.OverSampledBaudFrequencyClk==1)begin 
	repeat(8) @(posedge baudClk);//needs this posedge or 1 cycle delay to avoid race around or delay in output
	uartTransmitterState = STARTBIT;
	repeat(8) @(posedge baudClk);	
       	for( int i=0 ; i < uartConfigStruct.uartDataType ; i++) begin
     			repeat(8) @(posedge baudClk); begin
        		uartRxPacketStruct.receivingData[i] = rx;
			uartTransmitterState = DATABITTRANSFER;
			$display("i$$$$$$$$$$rx in receiver monitor is %b",rx);
        	end
		repeat(8) @(posedge baudClk);
       	end
      	if(uartConfigStruct.uartParityEnable ==1) begin   
	   			repeat(8) @(posedge baudClk);
	   			uartRxPacketStruct.parity = rx;
				uartTransmitterState = PARITYBIT;
				repeat(8) @(posedge baudClk);
      	end
      	repeat(8) @(posedge baudClk);
	uartTransmitterState = STOPBIT;
	repeat(8) @(posedge baudClk);
	repeat(8) @(posedge baudClk);
	uartTransmitterState = IDLE;
	end 
	else if(uartConfigStruct.OverSampledBaudFrequencyClk==0)begin 
         repeat(1)@(posedge baudClk);
          for( int i=0 ; i < uartConfigStruct.uartDataType ; i++) begin
	  @(posedge baudClk)begin 
            uartRxPacketStruct.receivingData[i] = rx;
	    $display("i$$$$$$$$$$rx in receiver monitor is %b",rx);
	  end
         end 
	 if(uartConfigStruct.uartParityEnable ==1) begin   
	 @(posedge baudClk)
	 uartRxPacketStruct.parity = rx;
	 end 
	 @(posedge baudClk);

	end 
  	endtask
			

  //-------------------------------------------------------
  // Task: StopBitCheck
  // to check valid stop bit and framing error occurs when a received character does not have a valid STOP bit.
  //-------------------------------------------------------
  //task StopBitCheck (inout  UartrxPacketStruct uartrxPacketStruct,input bit rx,input int transmission_number);
 //		if (rx == 1) begin
  //			FramingError = 0;
  //			`uvm_info(name, $sformatf("Stop bit detected"), UVM_HIGH)
  //		end
  //		else begin
  //			FramingError = 1;
  //			`uvm_info(name, $sformatf("Stop bit not detected"), UVM_HIGH)
  //		end
  //endtask	
  //-------------------------------------------------------
  // Task: parityCheck
  //  The parityCheck task checks for parity errors in the transmitted data 
  //-------------------------------------------------------
  // task parityCheck(inout UartrxPacketStruct uartrxPacketStruct,input bit rx,input int transmission_number);
    
   // int cal_parity;
    
   //if(uartConfigStruct.uartParityType == EVEN_PARITY)begin
  //	cal_parity = ^uartrxPacketStruct.transmissionData[transmission_number];
//      end
	
//	   else begin 
//	      cal_parity = ~^uartrxPacketStruct.transmissionData[transmission_number];
 //       end 
 //   if(rx==cal_parity)
  //    begin
    //    parity_error==0;
     // end
     //else
      //begin
     // parity_error==1;
     // end
  // endtask:parityCheck
endinterface : UartRxMonitorBfm
