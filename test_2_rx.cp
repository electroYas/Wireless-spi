#line 1 "C:/sugarsync/wireless_spi/test_2_rx.c"
#line 1 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
#line 1 "c:/sugarsync/wireless_spi/bk2421.h"
#line 108 "c:/sugarsync/wireless_spi/bk2421.h"
 unsigned char  SPI_Read_Reg( unsigned char  reg);
void SPI_Read_Buf( unsigned char  reg,  unsigned char  *pBuf,  unsigned char  bytes);

void SPI_Write_Reg( unsigned char  reg,  unsigned char  value);
void SPI_Write_Buf( unsigned char  reg,  unsigned char  *pBuf,  unsigned char  bytes);


void SwitchToTxMode();
void SwitchToRxMode();

void SPI_Bank1_Read_Reg( unsigned char  reg,  unsigned char  *pBuf);
void SPI_Bank1_Write_Reg( unsigned char  reg,  unsigned char  *pBuf);
void SwitchCFG(char _cfg);

void DelayMs( unsigned int  ms);
#line 36 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
 unsigned long  Bank1_Reg0_13[]={
0xE2014B40,
0x00004BC0,
0x028CFCD0,
0x41390099,
0x0B869ED9,

0xA67F0624,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00127300,
0x36B48000,
};

 unsigned char  Bank1_Reg14[]=
{
0x41,0x20,0x08,0x04,0x81,0x20,0xCF,0xF7,0xFE,0xFF,0xFF
};


 unsigned char  Bank0_Reg[ 21 ][2]={
 { 0x00 , 0x0F},
 { 0x01 , 0x01},
 { 0x02 , 0x01},
 { 0x03 , 0x03},
 { 0x04 ,0x25},
 { 0x05 , 0x20},
 { 0x06 , 0x15},
 { 0x07 , 0x70},
 { 0x08 ,0x00},
 { 0x09 , 0x00},
 { 0x0C ,0xc3},
 { 0x0D ,0xc4},
 { 0x0E ,0xc5},
 { 0x0F ,0xc6},
 { 0x11 , 0x20},
 { 0x12 , 0x20},
 { 0x13 , 0x20},
 { 0x14 , 0x20},
 { 0x15 , 0x20},
 { 0x16 , 0x20},
 { 0x17 ,0x11}
};








 unsigned char  Bank0_RegAct[ 2 ][2] = {
 { 0x1c , 0x01},
 { 0x1d , 0x04}
};
 unsigned char  RX_Address[5] = { 0x3a, 0x3b, 0x3c, 0x3d, 0x01 };


 unsigned char  TX_Address[5] = { 0x3a, 0x3b, 0x3c, 0x3d, 0x01 };

 unsigned char  RX0_Address[]={0x34,0x43,0x10,0x10,0x01};
 unsigned char  RX1_Address[]={0x39,0x38,0x37,0x36,0xc2};

 unsigned char  op_status;
#line 166 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
 unsigned char  SPI_RW( unsigned char  value)
{
  unsigned char  bit_ctr;
 for(bit_ctr=0;bit_ctr<8;bit_ctr++)
 {
 if(value & 0x80)
 {
  PORTC.F3 =1;
 }
 else
 {
  PORTC.F3 =0;
 }

 value = value << 1;
  PORTC.F2  = 1;
 value |=  PORTC.F4 ;
  PORTC.F2  = 0;
 }
 return(value);
}
#line 195 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SPI_Write_Reg( unsigned char  reg,  unsigned char  value)
{
  PORTC.F1  = 0;
 op_status = SPI_RW(reg);
 SPI_RW(value);
  PORTC.F1  = 1;
}
#line 210 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
 unsigned char  SPI_Read_Reg( unsigned char  reg)
{
  unsigned char  value;
  PORTC.F1  = 0;
 op_status=SPI_RW(reg);
 value = SPI_RW(0);
  PORTC.F1  = 1;

 return(value);
}
#line 228 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SPI_Read_Buf( unsigned char  reg,  unsigned char  *pBuf,  unsigned char  length)
{
  unsigned char  status,byte_ctr;

  PORTC.F1  = 0;
 status = SPI_RW(reg);

 for(byte_ctr=0;byte_ctr<length;byte_ctr++)
 pBuf[byte_ctr] = SPI_RW(0);

  PORTC.F1  = 1;

}
#line 249 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SPI_Write_Buf( unsigned char  reg,  unsigned char  *pBuf,  unsigned char  length)
{
  unsigned char  byte_ctr;

  PORTC.F1  = 0;
 op_status = SPI_RW(reg);
 for(byte_ctr=0; byte_ctr<length; byte_ctr++)
 SPI_RW(*pBuf++);
  PORTC.F1  = 1;

}
#line 268 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SwitchToRxMode()
{
  unsigned char  value;

 SPI_Write_Reg( 0xE2 ,0);

 value=SPI_Read_Reg( 0x07 );
 SPI_Write_Reg( 0x20 | 0x07 ,value);

  PORTC.F0 =0;

 value=SPI_Read_Reg( 0x00 );

 value=value|0x01;
 SPI_Write_Reg( 0x20  |  0x00 , value);

  PORTC.F0 =1;
}
#line 292 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SwitchToTxMode()
{
  unsigned char  value;
 SPI_Write_Reg( 0xE1 ,0);

  PORTC.F0 =0;
 value=SPI_Read_Reg( 0x00 );

 value=value&0xfe;
 SPI_Write_Reg( 0x20  |  0x00 , value);

  PORTC.F0 =1;
}
#line 318 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SwitchCFG(char _cfg)
{
  unsigned char  Tmp;

 Tmp=SPI_Read_Reg(7);
 Tmp=Tmp & 0x80;

 if( ( (Tmp) && (_cfg==0) )||( ((Tmp)==0) && (_cfg) ) )
 {
 SPI_Write_Reg( 0x50 ,0x53);
 }
}
#line 337 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void SetChannelNum( unsigned char  ch)
{
 SPI_Write_Reg(( unsigned char )( 0x20 |5),( unsigned char )(ch));
}
#line 353 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
void BK2421_Initialize()
{
#line 395 "c:/sugarsync/wireless_spi/bk2421_initialize.c"
signed char i,j;
  unsigned char  rData;
  unsigned char  WriteArr[4];


 Delay_Ms(100);

 SwitchCFG(0);


 for( i = ( 21  - 1); i >= 0; i-- )
 {
 SPI_Write_Reg( ( 0x20  | Bank0_Reg[i][0]), Bank0_Reg[i][1] );
 rData = SPI_Read_Reg( Bank0_Reg[i][0] );
 }


  { SPI_Write_Buf(( 0x20 | 0x0A ), ( unsigned char  *)RX_Address, 5); } ;


  { SPI_Write_Buf(( 0x20 | 0x10 ), ( unsigned char  *)TX_Address, 5); } ;

 i = SPI_Read_Reg( 29 );

 if( i == 0 )
 {
 SPI_Write_Reg(  0x50 , 0x73 );
 }

 for( i = ( 2  - 1); i >= 0; i-- )
 {
 SPI_Write_Reg( ( 0x20  | Bank0_RegAct[i][0]), Bank0_RegAct[i][1] );

 SPI_Read_Reg( (Bank0_RegAct[i][0]) );
 }



 SwitchCFG(1);

 for( i = 0; i <= 8; i++ )
 {
 for( j = 0; j < 4; j++ )
 {
 WriteArr[ j ] = ( Bank1_Reg0_13[i] >> ( 8 * (j) ) ) & 0xff;
 }

 SPI_Write_Buf( ( 0x20 |i), &(WriteArr[0]), 4 );
 }

 for( i = 9; i <= 13; i++ )
 {
 for( j = 0; j < 4; j++ )
 {
 WriteArr[j] = ( Bank1_Reg0_13[i] >> ( 8 * ( 3 - j ) ) ) & 0xff;
 }

 SPI_Write_Buf( (  0x20 |i), &(WriteArr[0]), 4 );
 }

 SPI_Write_Buf( (  0x20 |14), ( unsigned char  *)&(Bank1_Reg14[0]), 11 );


 for( j = 0; j < 4; j++ )
 {
 WriteArr[j] = ( Bank1_Reg0_13[4] >> ( 8 * (j) ) ) & 0xff;
 }

 WriteArr[0] = WriteArr[0] | 0x06;
 SPI_Write_Buf( ( 0x20  | 4), &(WriteArr[0]), 4 );

 WriteArr[0] = WriteArr[0] & 0xf9;
 SPI_Write_Buf( ( 0x20  | 4 ), &(WriteArr[0] ), 4 );

 Delay_Ms( 10 );


 SwitchCFG( 0 );

 SwitchToRxMode();

  { SPI_Write_Reg( 0xE2 ,0); } ;
  { SPI_Write_Reg( 0xE1 ,0); } ;
}
#line 1 "c:/sugarsync/wireless_spi/extra.h"
#line 7 "C:/sugarsync/wireless_spi/test_2_rx.c"
unsigned short g_RFRecvBuff[ 5 ];
unsigned short g_RFSendBuff[ 5 ];
unsigned short g_RFIRQValid = 0;
unsigned short g_DelayTick = 0;
int tick;


void RF_READY();

void RF_WriteTxPayload( unsigned short* pbuf, unsigned short len )
{
 SPI_Write_Buf(  0xA0 , pbuf, len );
}

void RF_WriteAckPayload( unsigned short* pbuf, unsigned short len )
{
 SPI_Write_Buf(  0xa8 , pbuf, len );
}


unsigned short RF_ReadRxPayload(unsigned short *pbuf, unsigned short maxlen)
{
 unsigned short i = 0;
 unsigned short len;

 len =  ( SPI_Read_Reg( 0x60 ) ) ;
 if( len > maxlen )
 {
 len = maxlen;
 }
 for ( i = 0; i < maxlen; i++ )
 {
 pbuf[ i ] = 0;
 }
 SPI_Read_Buf( 0x61 , pbuf, len);
 return len;
}

void system_init(){
 ADCON1 = 0X0F;
 TRISC = 0B00010000;
 PORTC = 0;
 TRISB = 0B00000001;
 PORTB = 0;


 CMCON.CM0 = 1;
 CMCON.CM1 = 1;
 CMCON.CM2 = 1;

 T0CON.T08BIT = 1;
 T0CON.T0CS = 0;
 T0CON.PSA = 0;
 T0CON.T0PS0 = 1;
 T0CON.T0PS1 = 0;
 T0CON.T0PS2 = 0;
 T0CON.TMR0ON = 1;


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


 system_init();
 BK2421_Initialize();

 while(1){

 RF_READY();
 delay_ms(100);

 }
}



void RF_READY(){
 unsigned char  sta;
  unsigned char  rlen;

 if( g_RFIRQValid )
 {
 INTCON.GIE = 0;
 g_RFIRQValid =  0 ;

 sta =  ( SPI_Read_Reg(STATUS) ) ;

 if( sta &  0x40  )
 {

 rlen = RF_ReadRxPayload( ( unsigned char  *)&g_RFRecvBuff,  5  );

 if ( rlen ==  5  )
 {
 PORTD = g_RFRecvBuff[0];

 }
 }
 if( sta &  0x10  )
 {
  { SPI_Write_Reg( 0xE1 ,0); } ;
 }

  { SPI_Write_Reg( 0x20 |STATUS, sta); } ;
 INTCON.GIE = 1;
 }
  { SPI_Write_Reg( 0x20 |STATUS, sta); } ;




}
