#include "BK2421_Initialize.c"
#include "extra.h"


//GLOBAL VARIABLES

unsigned short g_RFRecvBuff[RFPKT_LEN];
unsigned short g_RFSendBuff[RFPKT_LEN];
unsigned short g_RFIRQValid = 0;
unsigned short g_DelayTick = 0;
int tick;

//FUNCTION PROTOTYPES
void RF_READY();

void RF_WriteTxPayload( unsigned short* pbuf, unsigned short len )
{
    SPI_Write_Buf( WR_TX_PLOAD, pbuf, len ); // Writes data to TX FIFO
}

void RF_WriteAckPayload( unsigned short* pbuf, unsigned short len )
{
    SPI_Write_Buf( W_ACK_PAYLOAD_CMD, pbuf, len ); // Writes data to ACK FIFO
}


unsigned short RF_ReadRxPayload(unsigned short *pbuf, unsigned short maxlen)
{
  unsigned short i = 0;
  unsigned short len;

  len = RF_GET_RX_PL_LEN();                //Get Top of fifo packet length
  if( len > maxlen )
  {
          len = maxlen;
  }
  for ( i = 0; i < maxlen; i++ )          //Clear buffer
  {
      pbuf[ i ] = 0;
  }
  SPI_Read_Buf(RD_RX_PLOAD, pbuf, len);   // read receive payload from RX_FIFO buffer
  return len;
}

void system_init(){
  ADCON1 = 0X0F;
  TRISC = 0B00010000;
  PORTC = 0;
  TRISB = 0B00000001;
  PORTB = 0;

  //COMPARATOR OFF
  CMCON.CM0 = 1;
  CMCON.CM1 = 1;
  CMCON.CM2 = 1;
  //TIMER0 INTERRUPT 1ms
  T0CON.T08BIT = 1;
  T0CON.T0CS = 0;
  T0CON.PSA = 0;
  T0CON.T0PS0 = 1;
  T0CON.T0PS1 = 0;
  T0CON.T0PS2 = 0;
  T0CON.TMR0ON = 1;

  //INTERRUPT ENABLE
  INTCON.TMR0IE = 1;
  INTCON.INT0IE = 1;
  INTCON2.INTEDG0 = 0;
  INTCON.GIE = 1;

  PORTD = 0;
  TRISD = 0X00;

}

void interrupt(){
 if(INTCON.INT0IF){
  g_RFIRQValid = 1;
  INTCON.INT0IF = 0;
 }
 else if(INTCON.TMR0IF){
    g_DelayTick++;
    tick++;
    if(tick>=500){
       PORTB.F2 = PORTB.F2 ^ 1;
       tick = 0;
       TMR0L = 0;
    }
    INTCON.TMR0IF = 0;
 }

}



void main() {
 // short data1, buffer;
  
  system_init();
  BK2421_Initialize();

    while(1){
     
     RF_READY();
     delay_ms(100);

    }
}



void RF_READY(){
UINT8 sta;
    UINT8 rlen;

    if( g_RFIRQValid )
    {
    INTCON.GIE = 0;//DISABLE INTERRUPTS
        g_RFIRQValid = FALSE;

        sta = RF_GET_STATUS();      //Get the RF status

        if( sta & STATUS_RX_DR )    //Receive OK?
        {
            //Readout the received data from RX FIFO
            rlen = RF_ReadRxPayload( (UINT8 *)&g_RFRecvBuff, RFPKT_LEN );

            if ( rlen == RFPKT_LEN )
            {
            PORTD = g_RFRecvBuff[0];

            }
        }
        if( sta & STATUS_MAX_RT )  //Send fail?
        {
            RF_FLUSH_TX();  //Flush the TX FIFO
        }

        RF_CLR_IRQ( sta );  //Clear the IRQ flag
         INTCON.GIE = 1;// INTERRUPTS ENABLE
    }
    RF_CLR_IRQ( sta );  //Clear the IRQ flag
    

    

}