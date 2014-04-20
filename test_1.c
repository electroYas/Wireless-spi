//TRANSMITTER SIDE
//8MHz,18F4580

#include "BK2421_Initialize.c"
#include "extra.h"
#include "bk2421.h"


//GLOBAL VARIABLES

unsigned short g_RFRecvBuff[RFPKT_LEN];
unsigned short g_RFSendBuff[RFPKT_LEN];
unsigned short g_RFIRQValid = 0;
unsigned short g_DelayTick = 0;
int tick;


//FUNCTION PROTOTYPES


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

void RFSendPacket( unsigned short Key );

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
  TRISD = 0XFF;

}

void main() {
  unsigned short data1;

  system_init();
  BK2421_Initialize();
  data1 = 0;
  
  while(1)
  {
      if(data1 != PORTD){
        data1 = PORTD;
        PORTB.F1 = 1; //LED ON
        RFSendPacket( data1 );
        delay_ms(100);
      }

  }
}

void RFSendPacket( unsigned short Key )
{
  unsigned short sta;

  g_RFSendBuff[0] = Key;
  SwitchToTxMode();   //Set RF to TX mode

  CE = 0;
  SPI_Write_Buf(WR_TX_PLOAD,(unsigned short *)&g_RFSendBuff,RFPKT_LEN); // Writes data to TX FIFO
  g_RFIRQValid = FALSE;
  CE = 1;
  delay_us(25);
  CE = 0;

  //Wait for send over
  g_DelayTick = 0;

  while( 1 )
  {
    if(g_RFIRQValid )
    {
      sta = SPI_Read_Reg( STATUS1 );   // read register STATUS's value

      if( (sta & STATUS_TX_DS) || (sta & STATUS_MAX_RT) )    //TX IRQ?
      {
        if( sta & STATUS_MAX_RT )   //if send fail
        {
         RF_FLUSH_TX();
        }
        RF_CLR_IRQ( sta );  // clear RX_DR or TX_DS or MAX_RT interrupt flag
        PORTB.F1 = 0;
        g_RFIRQValid = FALSE;
        break;
      }
    }
    else if( g_DelayTick >= 10 )  //if timeout
    {
      RF_FLUSH_TX();
      break;
    }
  }

  SwitchToRxMode();
}