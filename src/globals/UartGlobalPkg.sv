`ifndef UARTGLOBALPKG_INCLUDED_
`define UARTGLOBALPKG_INCLUDED_

package UartGlobalPkg;
  // maximum width of data packet
  parameter DATA_WIDTH=8;

  // No. of packets to be transferred
  parameter NO_OF_PACKETS = 50;

  // can enable or disable parity
  parameter PARITY_ENABLED = 1'b 1;

  // indicates start bit
  parameter START_BIT = 0;

  // indicates stop bit
  parameter STOP_BIT = 1;

  // even or odd parity can be set
  typedef enum{ EVEN_PARITY , ODD_PARITY} PARITY_TYPE_E;

  // baud rate in which data transfers
  typedef enum bit[31:0]{ BAUD_4800 = 32'd 4800,
                          BAUD_9600 = 32'd 9600,
                         BAUD_19200 = 32'd 19200 }BAUD_RATE_E;
  // oversamping rate
  typedef enum bit[4:0]{ OVERSAMPLING_16 = 5'd 16,
                        OVERSAMPLING_13 = 5'd 13}OVER_SAMPLING_E;

  // no of stop bits 
  typedef enum bit[1:0]{ ONE_BIT = 1,
                        TWO_BIT = 2 } STOP_BIT_E;

  typedef enum bit[3:0]{ FIVE_BIT = 5,
                         SIX_BIT = 6,
                         SEVEN_BIT=7,
                        EIGHT_BIT=8} DATA_TYPE_E;

   // required Tx and Rx struct packet
  typedef struct packed { bit[NO_OF_PACKETS -1 :0][DATA_WIDTH-1:0] transmissionData; bit [NO_OF_PACKETS-1:0]parity; bit [NO_OF_PACKETS-1:0]parity_error; bit [NO_OF_PACKETS-1:0]breaking_error; bit [NO_OF_PACKETS-1:0]overrun_error;} UartTxPacketStruct;
  typedef struct packed { bit[NO_OF_PACKETS -1 :0][DATA_WIDTH-1:0] receivingData; bit [NO_OF_PACKETS-1:0]parity; bit [NO_OF_PACKETS-1:0]parity_error; bit [NO_OF_PACKETS-1:0]breaking_error; bit [NO_OF_PACKETS-1:0]overrun_error;} UartRxPacketStruct;
  typedef struct packed {OVER_SAMPLING_E uartOverSamplingMethod ; BAUD_RATE_E uartBaudRate; DATA_TYPE_E uartDataType;PARITY_TYPE_E uartParityType; bit uartParityEnable;}UartConfigStruct;

endpackage : UartGlobalPkg
`endif
