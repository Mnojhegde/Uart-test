//-------------------------------------------------------
// Importing Uart global package
//-------------------------------------------------------
import UartGlobalPkg::*;

//--------------------------------------------------------------------------------------------
// Interface : UartTxMonitorBfm
//  Connects the master monitor bfm with the master monitor prox
//--------------------------------------------------------------------------------------------

interface UartTxMonitorBfm (input  bit   clk,
                            input  bit   reset,
                            input  bit   tx
                           );

  //-------------------------------------------------------
  // Importing uvm package file
  //-------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  //-------------------------------------------------------
  // Importing the Transmitter package file
  //-------------------------------------------------------
  //import UartTxPkg:: UartTxMonitorProxy;
  
  //Variable: name
  //Used to store the name of the interface

  string name = "UART_TRANSMITTER_MONITOR_BFM"; 

  //Variable: bclk
  //baud clock for uart transmisson/reception
	
  bit baudClk;
   bit oversamplingClk;
   //Variable: baudRate
  //Used to sample the uart data
	
 // reg[31:0] baudRate = 9600;
  
   //Variable: baudRate
  // Counter to keep track of clock cycles
	
  reg [15:0] counter;  
  
   //Variable: baudDivider
  //to Calculate baud rate divider
	
  reg [15:0] baudDivider;
	

 //Creating the handle for the proxy_driver

 // UartTxMonitorProxy uartTxMonitorProxy;
   

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
	task Baud_div(input int oversamplingmethod,input int baudrate);
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

      baudDivisor = (clkFrequency)/(oversamplingmethod * baudrate); 

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
  // Task: bclk_counter
  //  This task will count the number of cycles of bclk and generate oversamplingClk to sample data
  //--------------------------------------------------------------------------------------------

  task BclkCounter(input int uartOverSamplingMethod);
    static int countbClk = 0;
    forever begin
	@(posedge baudClk)
	if(countbClk == (uartOverSamplingMethod/2)-1) begin
      	  oversamplingClk = ~oversamplingClk;
      	  countbClk=0;
      	end
      	else begin
      	countbClk = countbClk+1;
      end
   
    end
  endtask
	
  //-------------------------------------------------------
  // Task: WaitForReset
  //  Waiting for the system reset
  //-------------------------------------------------------

  task WaitForReset();
    @(negedge reset)
    `uvm_info(name, $sformatf("system reset detected"), UVM_HIGH)
    
    @(posedge reset);
    `uvm_info(name, $sformatf("system reset deactivated"), UVM_HIGH)
  endtask: WaitForReset

  //-------------------------------------------------------
  // Task: DeSerializer
  //  converts serial data to parallel
  //-------------------------------------------------------

  task Deserializer(inout UartTxPacketStruct uartTxPacketStruct, input UartConfigStruct uartConfigStruct);
    static int total_transmission = NO_OF_PACKETS;
    for(int transmission_number=0 ; transmission_number < total_transmission; transmission_number++)begin 
      @(negedge tx);
      for( int i=0 ; i < uartConfigStruct.uartDataType ; i++) begin
	@(posedge oversamplingClk );
	uartTxPacketStruct.transmissionData[transmission_number][i] = tx;
      end
  
      if(uartConfigStruct.uartParityEnable ==1) begin 
        if(uartConfigStruct.uartParityType == EVEN_PARITY)begin
	  @(posedge oversamplingClk);
	  uartTxPacketStruct.parity[transmission_number] = ^uartTxPacketStruct.transmissionData[transmission_number];
	end
	
	else begin 
	  @(posedge oversamplingClk);
	  uartTxPacketStruct.parity[transmission_number] = ~^uartTxPacketStruct.transmissionData[transmission_number];
	end 
      end 	
 
     
      @(posedge oversamplingClk);
      if(tx == 0)
	`uvm_info(TxMonitor, $sformatf(" Stop bit is detected in Tx monitor "), UVM_LOW);
      else
 	`uvm_info(TxMonitor, $sformatf(" Stop bit is detected in Tx monitor "), UVM_LOW);
    end
 endtask
	
endinterface : UartTxMonitorBfm
