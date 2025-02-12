`ifndef UARTGLOBALPKG_INCLUDED_
`define UARTGLOBALPKG_INCLUDED_

package UartGlobalPkg;
  // maximum width of data packet
  parameter DATA_WIDTH=8; 

  // no. of packets to be transferred
  parameter NO_OF_PACKETS = 2;

	// indicates start bit
  parameter START_BIT = 0;

  // indicates stop bit
  parameter STOP_BIT = 1;

  // can enable or disable parity
  parameter PARITY_ENABLED = 1'b 1;

  // even or odd parity can be set
	typedef enum{ EVEN_PARITY , ODD_PARITY} parityTypeEnum;

  // baud rate in which data transfers
  typedef enum bit[31:0]{ BAUD_4800 = 32'd 4800,
                          BAUD_9600 = 32'd 9600,
												  BAUD_19200 = 32'd 19200 } baudRateEnum;
  // oversamping rate
  typedef enum bit[4:0]{ OVERSAMPLING_16 = 5'd 16,
												 OVERSAMPLING_13 = 5'd 13} overSamplingEnum;

  // no of stop bits 
  typedef enum bit[1:0]{ ONE_BIT = 1,
												 TWO_BIT = 2 } stopBitEnum;

  // indicates data width on which uart working
	typedef enum bit[3:0]{ FIVE_BIT = 5,
                         SIX_BIT = 6,
                         SEVEN_BIT=7,
												 EIGHT_BIT=8} dataTypeEnum;

  // required Tx struct packet
	typedef struct packed {logic [DATA_WIDTH-1:0] transmissionData; 
												  logic parity; 
												  logic parityError; 
												  logic breakingError; 
												  logic overrunError;
			                    logic framingError; } UartTxPacketStruct;
	
	// required Rx struct packet
	typedef struct packed { logic[DATA_WIDTH-1:0] receivingData;
												  logic parity; 
												  logic parityError; 
												  logic breakingError; 
												  logic overrunError;} UartRxPacketStruct;

	// config parameter struct packet
	typedef struct packed { overSamplingEnum uartOverSamplingMethod; 
												  baudRateEnum uartBaudRate; 
												  dataTypeEnum uartDataType;
												  parityTypeEnum uartParityType; 
												  bit uartParityEnable; 
												  bit uartParityErrorInjection;
												  bit uartFramingErrorInjection;
												  bit OverSampledBaudFrequencyClk;} UartConfigStruct;


	typedef enum{RESET, IDLE, STARTBIT ,DATABITTRANSFER ,PARITYBIT, STOPBIT}UartTransmitterStateEnum;
endpackage : UartGlobalPkg
`endif 
