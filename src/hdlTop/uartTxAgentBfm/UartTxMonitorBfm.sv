import UartGlobalPkg::*;
//--------------------------------------------------------------------------------------------
// Interface : UartTxMonitorBfm
//  Connects the master monitor bfm with the master monitor prox
//--------------------------------------------------------------------------------------------
interface UartTxMonitorBfm (input  logic   clk,
                            input  logic reset,
                            input  logic   tx
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
				@(negedge tx);
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
        task StartMonitoring(inout UartTxPacketStruct uartTxPacketStruct , inout UartConfigStruct uartConfigStruct);
        //baudClkCounter(uartConfigStruct.uartOverSamplingMethod);
        // fork
        // baudClkCounter(uartConfigStruct.uartOverSamplingMethod);
        Deserializer(uartTxPacketStruct,uartConfigStruct);
         //        join_any
         // @(negedge oversamplingClk);
         // disable fork ;
        endtask

function evenParityCompute(input UartConfigStruct uartConfigStruct,input UartTxPacketStruct uartTxPacketStruct);
  bit parity;
  case(uartConfigStruct.uartDataType)
    FIVE_BIT: parity = ^(uartTxPacketStruct.transmissionData[4:0]);
    SIX_BIT :parity = ^(uartTxPacketStruct.transmissionData[5:0]);
    SEVEN_BIT: parity = ^(uartTxPacketStruct.transmissionData[6:0]);
    EIGHT_BIT : parity = ^(uartTxPacketStruct.transmissionData[7:0]);
  endcase
return tx;
endfunction
function oddParityCompute(input UartConfigStruct uartConfigStruct,input UartTxPacketStruct uartTxPacketStruct);
  bit parity;
  case(uartConfigStruct.uartDataType)
      FIVE_BIT: parity = ~^(uartTxPacketStruct.transmissionData[4:0]);
      SIX_BIT :parity = ~^(uartTxPacketStruct.transmissionData[5:0]);
      SEVEN_BIT: parity = ~^(uartTxPacketStruct.transmissionData[6:0]);
      EIGHT_BIT : parity = ~^(uartTxPacketStruct.transmissionData[7:0]);
  endcase
return parity;
endfunction
  //-------------------------------------------------------
  // Task: DeSerializer
  //  converts serial data to parallel
  //-------------------------------------------------------
  task Deserializer(inout UartTxPacketStruct uartTxPacketStruct, inout UartConfigStruct uartConfigStruct);
        @(negedge tx);
        if(uartConfigStruct.OverSampledBaudFrequencyClk==1)begin
        repeat(8) @(posedge baudClk); //needs this posedge or 1 cycle delay to avoid race around or delay in output
				uartTransmitterState = STARTBIT;
				repeat(8) @(posedge baudClk); 
        for( int i=0 ; i < uartConfigStruct.uartDataType ; i++) begin
        	repeat(8) @(posedge baudClk); 
					uartTxPacketStruct.transmissionData[i] = tx;
					uartTransmitterState = DATABITTRANSFER;
          repeat(8) @(posedge baudClk);
        end
        if(uartConfigStruct.uartParityEnable ==1) begin
					repeat(8) @(posedge baudClk);
					uartTxPacketStruct.parity = tx;
				  parityCheck(uartConfigStruct,uartTxPacketStruct,tx);
					uartTransmitterState = PARITYBIT;
					repeat(8) @(posedge baudClk);
        end
        repeat(8) @(posedge baudClk);
				stopBitCheck(uartTxPacketStruct,tx);
				uartTransmitterState = STOPBIT;
				repeat(8) @(posedge baudClk);
				repeat(8) @(posedge baudClk);
				uartTransmitterState = IDLE;
        end
        else if(uartConfigStruct.OverSampledBaudFrequencyClk==0)begin
         repeat(1)@(posedge baudClk);
          for( int i=0 ; i < uartConfigStruct.uartDataType ; i++) begin
          @(posedge baudClk)begin
            uartTxPacketStruct.transmissionData[i] = tx;
          end
         end
         if(uartConfigStruct.uartParityEnable ==1) begin
         @(posedge baudClk)
         uartTxPacketStruct.parity = tx;
                 parityCheck(uartConfigStruct,uartTxPacketStruct,tx);
         end
         @(posedge baudClk);
                stopBitCheck(uartTxPacketStruct,tx);
        end
        endtask
  task stopBitCheck (inout  UartTxPacketStruct uartTxPacketStruct,input bit tx);
                if (tx == 1) begin
                        uartTxPacketStruct.framingError = 0;
                        `uvm_info(name, $sformatf("???????????????????????????????????Stop bit detected"), UVM_LOW)
                end
                else begin
                        uartTxPacketStruct.framingError = 1;
                        `uvm_info(name, $sformatf("??????????????????????????????????????????????Stop bit not detected"), UVM_LOW)
                end
  endtask
task parityCheck(inout UartConfigStruct uartConfigStruct,inout UartTxPacketStruct uartTxPacketStruct,input bit tx);
   int cal_parity;
   if(uartConfigStruct.uartParityType == EVEN_PARITY)begin
           cal_parity = evenParityCompute(uartConfigStruct,uartTxPacketStruct);
     end
           else begin
           cal_parity = oddParityCompute(uartConfigStruct,uartTxPacketStruct);
       end
   if(tx==cal_parity)begin
       uartTxPacketStruct.parityError=0;
     end
     else begin
     uartTxPacketStruct.parityError=1;
     end
  endtask:parityCheck
endinterface : UartTxMonitorBfm
