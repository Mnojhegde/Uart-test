//-------------------------------------------------------
// Importing Uart global package
//-------------------------------------------------------
import UartGlobalPkg::*;

//--------------------------------------------------------------------------------------------
// Interface : UartTxDriverBfm
//  Used as the HDL driver for Uart
//  It connects with the HVL driver_proxy for driving the stimulus
//--------------------------------------------------------------------------------------------
interface UartTxDriverBfm (input  logic   clk,
                           input  logic   reset,
                           output logic   tx
                          );

  //-------------------------------------------------------
  // Importing uvm package file
  //-------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  //-------------------------------------------------------
  // Importing the Transmitter package file
  //-------------------------------------------------------
  import UartTxPkg::*;
  
  //Variable: name
  //Used to store the name of the interface
  string name = "UART_TRANSMITTER_DRIVER_BFM"; 

  
   //Variable: bclk
  //baud clock for uart transmisson/reception	
  bit baudClk;
     
  //Variable: oversamplingClk
  // clk used to sample the data
  bit oversamplingClk;
  
  //Variable: counter
  // Counter to keep track of clock cycles
  
  //Variable: baudDivider
  //to Calculate baud rate divider

  //Variable: count
  //to count the no of clock cycles
  int count=0;

  //Variable: baudDivisor
  //used to generate the baud clock
  int baudDivisor;

  //Variable: baudDivider
  //to count the no of baud clock cycles
  int countbClk = 0;	
  
  //Creating the handle for the proxy_driver
  UartTxDriverProxy uartTxDriverProxy;
   
  //-------------------------------------------------------
  // Used to display the name of the interface
  //-------------------------------------------------------
  initial begin
    `uvm_info(name, $sformatf(name),UVM_LOW)
  end
  


  //------------------------------------------------------------------
  // Task: bauddivCalculation
  // this task will calculate the baud divider based on sys clk frequency
  //-------------------------------------------------------------------
	
   task GenerateBaudClk(inout UartConfigStruct uartConfigStruct);
      real clkPeriodStartTime; 
      real clkPeriodStopTime;
      real clkPeriod;
      real clkFrequency;
      int baudDivisor;
      int count;

      @(posedge clk);
      clkPeriodStartTime = $realtime;
      @(posedge clk);
      clkPeriodStopTime = $realtime; 
      clkPeriod = clkPeriodStopTime - clkPeriodStartTime;
      clkFrequency = ( 10 **9 )/ clkPeriod;

      baudDivisor = (clkFrequency)/(uartConfigStruct.uartOverSamplingMethod * uartConfigStruct.uartBaudRate); 

     BaudClkGenerator(baudDivisor);

    endtask

  //------------------------------------------------------------------
  // this block will generate baud clk based on baud divider
  //-------------------------------------------------------------------

    task BaudClkGenerator(input int baudDivisor);
      static int count=0;
      
      forever begin

        @(posedge clk or negedge clk)
        if(count == (baudDivisor-1))begin 
          count <= 0;
          baudClk <= ~baudClk;
        end 
        else begin 
          count <= count +1;
        end  
      end
    endtask

	     
  //-------------------------------------------------------
  // Task: WaitForReset
  //  Waiting for the system reset
  //-------------------------------------------------------

  task WaitForReset();
	  @(negedge reset);
	  `uvm_info(name,$sformatf("RESET DETECTED"),UVM_LOW);
	  tx = 1; //DRIVE THE UART TO IDEAL STATE
	  @(posedge reset);
	  `uvm_info(name,$sformatf("RESET DEASSERTED"),UVM_LOW);
  endtask: WaitForReset
  
  //--------------------------------------------------------------------------------------------
  // Task: DriveToBfm
  //  This task will drive the data from bfm to proxy using converters
  //--------------------------------------------------------------------------------------------

  task DriveToBfm(inout UartTxPacketStruct uartTxPacketStruct , inout UartConfigStruct uartConfigStruct);
    	`uvm_info(name,$sformatf("data_packet=\n%p",uartTxPacketStruct),UVM_LOW);
    	`uvm_info(name,$sformatf("DRIVE TO BFM TASK"),UVM_LOW);

	fork
	BclkCounter(uartConfigStruct.uartOverSamplingMethod);   /* NEED TO UPDATE CONFIG CONVERTER IN DRIVER PROXY SIDE */
        SampleData(uartTxPacketStruct , uartConfigStruct);
	join_any
	disable fork;
		
  endtask: DriveToBfm
 
  //--------------------------------------------------------------------------------------------
  //  This block will count the number of cycles of bclk and generate oversamplingClk to sample data
  //--------------------------------------------------------------------------------------------

  task BclkCounter(input int uartOverSamplingMethod);
    static int countbClk = 0;
    $display("inside overclk task count value is %0d baud clock is %b",countbClk,baudClk);
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
  
  //--------------------------------------------------------------------------------------------
  // Task: sample_data
  //  This task will send the data to the uart interface based on oversamplingClk
  //--------------------------------------------------------------------------------------------
  
  task SampleData(inout UartTxPacketStruct uartTxPacketStruct , inout UartConfigStruct uartConfigStruct);
    static int total_transmission = $size(uartTxPacketStruct.transmissionData);	 
   static int uartType = 5;
    for(int transmission_number=0 ; transmission_number < total_transmission; transmission_number++)begin 
    @(posedge oversamplingClk);
      tx = START_BIT;
      for( int i=0 ; i< uartConfigStruct.uartDataType ; i++) begin
      	@(posedge oversamplingClk)
        tx = uartTxPacketStruct.transmissionData[transmission_number][i];
	$display("tx here is %b",tx);
      end
      if(uartConfigStruct.uartParityEnable ==1) begin 
       if(uartConfigStruct.uartParityErrorInjection==0) begin 
	if(uartConfigStruct.uartParityType == EVEN_PARITY)begin
	  @(posedge oversamplingClk)
	  case(uartConfigStruct.uartDataType)
            FIVE_BIT: tx = ^(uartTxPacketStruct.transmissionData[transmission_number][4:0]);
            SIX_BIT :tx = ^(uartTxPacketStruct.transmissionData[transmission_number][5:0]);
            SEVEN_BIT: tx = ^(uartTxPacketStruct.transmissionData[transmission_number][6:0]);
            EIGHT_BIT : tx = ^(uartTxPacketStruct.transmissionData[transmission_number][7:0]);
	  endcase  
        end
	else if (uartConfigStruct.uartParityType == ODD_PARITY) begin 
	  @(posedge oversamplingClk)
            case(uartConfigStruct.uartDataType)
	      FIVE_BIT: tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][4:0]);
	      SIX_BIT :tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][5:0]);
	      SEVEN_BIT: tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][6:0]);
	      EIGHT_BIT : tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][7:0]);
	    endcase  
        end 
       end
       else begin 
         if(uartConfigStruct.uartParityType == EVEN_PARITY)begin
	   @(posedge oversamplingClk)
           case(uartConfigStruct.uartDataType)
	     FIVE_BIT: tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][4:0]);
	     SIX_BIT :tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][5:0]);
	     SEVEN_BIT: tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][6:0]);
	     EIGHT_BIT : tx = ~^(uartTxPacketStruct.transmissionData[transmission_number][7:0]);
           endcase	 
	 end 
	 else if(uartConfigStruct.uartParityType == ODD_PARITY) begin
           @(posedge oversamplingClk)
	    case(uartConfigStruct.uartDataType)
	      FIVE_BIT: tx = ^(uartTxPacketStruct.transmissionData[transmission_number][4:0]);
	      SIX_BIT :tx = ^(uartTxPacketStruct.transmissionData[transmission_number][5:0]);
	      SEVEN_BIT: tx = ^(uartTxPacketStruct.transmissionData[transmission_number][6:0]);
	      EIGHT_BIT : tx = ^(uartTxPacketStruct.transmissionData[transmission_number][7:0]);
	    endcase 
	 end 
       end 
      end 
      @(posedge oversamplingClk)
      tx = STOP_BIT;  
    end//packet for
  endtask 
  always@(posedge oversamplingClk) 
  $display("DATA IS BEING SENT  %b",tx);
  
endinterface : UartTxDriverBfm
