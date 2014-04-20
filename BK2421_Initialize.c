#include "bk2421.h"



                                               //Set RX address
#define RF_SET_RX_ADDR(addr) { SPI_Write_Buf((WRITE_REG|RX_ADDR_P0), addr, 5); }
//TX address
#define RF_SET_TX_ADDR(addr) { SPI_Write_Buf((WRITE_REG|TX_ADDR), addr, 5); }
//Set ACK
#define RF_SET_AUTO_ACK(enable) { SPI_Write_Reg((WRITE_REG|EN_AA), enable); }
//choice pipe
#define RF_SET_CHN(ch) { SPI_Write_Reg((WRITE_REG|RF_CH), ch); }
//Read status register
#define RF_GET_RX_PL_LEN() ( SPI_Read_Reg(R_RX_PL_WID_CMD) )
//Read result of carry detection
#define RF_GET_CD() ( SPI_Read_Reg(CD) )
//Clear RX FIFO
#define RF_FLUSH_RX() { SPI_Write_Reg(FLUSH_RX,0); }
//Clear TX FIFO
#define RF_FLUSH_TX() { SPI_Write_Reg(FLUSH_TX,0); }

 #define DYNPD           0x1c
#define FEATURE         0x1d
    #define BANK0_REG_LIST_CNT                        21
#define BANK0_REGACT_LIST_CNT                2










UINT32 Bank1_Reg0_13[]={
0xE2014B40,
0x00004BC0,
0x028CFCD0,
0x41390099,
0x0B869ED9,     //Change REG4[29:27] from 00 to 11
//0x21869ED9,   //For single carrier mode
0xA67F0624,     //Disable RSSI measurement
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00127300,
0x36B48000,
};
//Reg14,    Ramp curve
UINT8 Bank1_Reg14[]=
{
0x41,0x20,0x08,0x04,0x81,0x20,0xCF,0xF7,0xFE,0xFF,0xFF
};

/*Bank0 register initialization value*/
UINT8 Bank0_Reg[BANK0_REG_LIST_CNT][2]={
        {CONFIG,        0x0F},        //Power up, PRX
        {EN_AA,                0x01},        //Enable pipe0 auto ACK
        {EN_RXADDR,        0x01},        //Enable data pipe 0
        {SETUP_AW,        0x03},        //Address width = 5Bytes
        {SETUP_RETR,0x25},        //Retransmit, ARD = 750us, ARC = 5
        {RF_CH,                0x20},        //channel = 60
        {RF_SETUP,        0x15},        //1Mbps data rate, output power=0dBm
        {STATUS1,        0x70},
        {OBSERVE_TX,0x00},
        {CD,                0x00},
        {RX_ADDR_P2,0xc3},
        {RX_ADDR_P3,0xc4},
        {RX_ADDR_P4,0xc5},
        {RX_ADDR_P5,0xc6},
        {RX_PW_P0,        0x20},        //RX Payload Length = 32
        {RX_PW_P1,        0x20},
        {RX_PW_P2,        0x20},
        {RX_PW_P3,        0x20},
        {RX_PW_P4,        0x20},
        {RX_PW_P5,        0x20},
        {FIFO_STATUS,0x11}
};








UINT8 Bank0_RegAct[BANK0_REGACT_LIST_CNT][2] = {
        {DYNPD,                0x01},        //Enable pipe 0, Dynamic payload length
        {FEATURE,        0x04}        //EN_DPL= 1, EN_ACK_PAY = 0, EN_DYN_ACK = 0
};
UINT8 RX_Address[5] = { 0x3a, 0x3b, 0x3c, 0x3d, 0x01 };

/*The Tx Address 5 bytes*/
UINT8 TX_Address[5] = { 0x3a, 0x3b, 0x3c, 0x3d, 0x01 };

UINT8 RX0_Address[]={0x34,0x43,0x10,0x10,0x01};
UINT8 RX1_Address[]={0x39,0x38,0x37,0x36,0xc2};

UINT8 op_status;
//Bank1 register initialization value

//In the array Bank1_Reg0_13,all[] the register value is the byte reversed!!!!!!!!!!!!!!!!!!!!!
/*unsigned long Bank1_Reg0_13[]={
0xE2014B40,
0x00004BC0,
0x028CFCD0,
0x41390099,
0x0B869ED9,  //Change REG4[29:27] from 00 to 11
0xA67F0624,  //Disable RSSI measurement
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00127300,
0x36B48000,
};

UINT8 Bank1_Reg14[]=
{
0x41,0x20,0x08,0x04,0x81,0x20,0xCF,0xF7,0xFE,0xFF,0xFF
};

//Bank0 register initialization value
UINT8 Bank0_Reg[][2]={
{0,0x0F},
{1,0x3F},
{2,0x3F},
{3,0x03},
{4,0xff},
{5,0x17},
{6,0x15},        //1Mbps data rate, output power=0dBm
{7,0x07},
{8,0x00},
{9,0x00},
{12,0xc3},
{13,0xc4},
{14,0xc5},
{15,0xc6},
{17,0x20},
{18,0x20},
{19,0x20},
{20,0x20},
{21,0x20},
{22,0x20},
{23,0x00},
{28,0x3F},
{29,0x07}
};*/

///////////////////////////////////////////////////////////////////////////////
//                  SPI access                                               //
///////////////////////////////////////////////////////////////////////////////

/**************************************************
Function: SPI_RW();

Description:
        Writes one UINT8 to BK2421, and return the UINT8 read
**************************************************/
UINT8 SPI_RW(UINT8 value)
{
        UINT8 bit_ctr;
        for(bit_ctr=0;bit_ctr<8;bit_ctr++)   // output 8-bit
        {
                if(value & 0x80)
                {
                        MOSI=1;
                }
                else
                {
                        MOSI=0;
                }

                value = value << 1;           // shift next bit into MSB..
                SCK = 1;                      // Set SCK high..
                value |= MISO;                         // capture current MISO bit
                SCK = 0;                              // ..then set SCK low again
        }
        return(value);                             // return read UINT8
}
/**************************************************/

/**************************************************
Function: SPI_Write_Reg();

Description:
        Writes value 'value' to register 'reg'
**************************************************/
void SPI_Write_Reg(UINT8 reg, UINT8 value)
{
        CSN = 0;                   // CSN low, init SPI transaction
        op_status = SPI_RW(reg);      // select register
        SPI_RW(value);             // ..and write value to it..
        CSN = 1;                   // CSN high again
}
/**************************************************/

/**************************************************
Function: SPI_Read_Reg();

Description:
        Read one UINT8 from BK2421 register, 'reg'
**************************************************/
UINT8 SPI_Read_Reg(UINT8 reg)
{
        UINT8 value;
        CSN = 0;                // CSN low, initialize SPI communication...
        op_status=SPI_RW(reg);            // Select register to read from..
        value = SPI_RW(0);    // ..then read register value
        CSN = 1;                // CSN high, terminate SPI communication

        return(value);        // return register value
}
/**************************************************/

/**************************************************
Function: SPI_Read_Buf();

Description:
        Reads 'length' #of length from register 'reg'
**************************************************/
void SPI_Read_Buf(UINT8 reg, UINT8 *pBuf, UINT8 length)
{
        UINT8 status,byte_ctr;

        CSN = 0;                                    // Set CSN l
        status = SPI_RW(reg);                       // Select register to write, and read status UINT8

        for(byte_ctr=0;byte_ctr<length;byte_ctr++)
                pBuf[byte_ctr] = SPI_RW(0);    // Perform SPI_RW to read UINT8 from BK2421

        CSN = 1;                           // Set CSN high again

}
/**************************************************/

/**************************************************
Function: SPI_Write_Buf();

Description:
        Writes contents of buffer '*pBuf' to BK2421
**************************************************/
void SPI_Write_Buf(UINT8 reg, UINT8 *pBuf, UINT8 length)
{
        UINT8 byte_ctr;

        CSN = 0;                   // Set CSN low, init SPI tranaction
        op_status = SPI_RW(reg);    // Select register to write to and read status UINT8
        for(byte_ctr=0; byte_ctr<length; byte_ctr++) // then write all UINT8 in buffer(*pBuf)
                SPI_RW(*pBuf++);
        CSN = 1;                 // Set CSN high again

}
/**************************************************/


/**************************************************
Function: SwitchToRxMode();
Description:
        switch to Rx mode
**************************************************/
void SwitchToRxMode()
{
         UINT8 value;

        SPI_Write_Reg(FLUSH_RX,0);//flush Rx

        value=SPI_Read_Reg(STATUS1);        // read register STATUS's value
        SPI_Write_Reg(WRITE_REG|STATUS1,value);// clear RX_DR or TX_DS or MAX_RT interrupt flag

        CE=0;

        value=SPI_Read_Reg(CONFIG);        // read register CONFIG's value
//PRX
        value=value|0x01;//set bit 1
          SPI_Write_Reg(WRITE_REG | CONFIG, value); // Set PWR_UP bit, enable CRC(2 length) & Prim:RX. RX_DR enabled..

        CE=1;
}

/**************************************************
Function: SwitchToTxMode();
Description:
        switch to Tx mode
**************************************************/
void SwitchToTxMode()
{
         UINT8 value;
        SPI_Write_Reg(FLUSH_TX,0);//flush Tx

        CE=0;
        value=SPI_Read_Reg(CONFIG);        // read register CONFIG's value
//PTX
        value=value&0xfe;//set bit 1
          SPI_Write_Reg(WRITE_REG | CONFIG, value); // Set PWR_UP bit, enable CRC(2 length) & Prim:RX. RX_DR enabled.

        CE=1;
}

/**************************************************
Function: SwitchCFG();

Description:
         access switch between Bank1 and Bank0

Parameter:
        _cfg      1:register bank1
                  0:register bank0
Return:
     None
**************************************************/
void SwitchCFG(char _cfg)//1:Bank1 0:Bank0
{
        UINT8 Tmp;

        Tmp=SPI_Read_Reg(7);
        Tmp=Tmp & 0x80;

        if( ( (Tmp) && (_cfg==0) )||( ((Tmp)==0) && (_cfg) ) )
        {
                SPI_Write_Reg(ACTIVATE_CMD,0x53);
        }
}

/**************************************************
Function: SetChannelNum();
Description:
        set channel number

**************************************************/
void SetChannelNum(UINT8 ch)
{
        SPI_Write_Reg((UINT8)(WRITE_REG|5),(UINT8)(ch));
}



///////////////////////////////////////////////////////////////////////////////
//                  BK2421 initialization                                    //
///////////////////////////////////////////////////////////////////////////////
/**************************************************
Function: BK2421_Initialize();

Description:
        register initialization
**************************************************/
void BK2421_Initialize()
{
        //INT8 i,j;
         //UINT8 WriteArr[4];

        //delay_ms(100);//delay more than 50ms.

       // SwitchCFG(0);
     //   for(i=20;i>=0;i--){
   //      SPI_Write_Reg((WRITE_REG|Bank0_Reg[i][0]),Bank0_Reg[i][1]);
 //        }
//        SPI_Write_Buf((WRITE_REG|10),RX0_Address,5);
//        SPI_Write_Buf((WRITE_REG|11),RX1_Address,5);
//        SPI_Write_Buf((WRITE_REG|16),RX0_Address,5);
//        i=SPI_Read_Reg(29);
//        if(i==0) SPI_Write_Reg(ACTIVATE_CMD,0x73);// Active
//        for(i=22;i>=21;i--) SPI_Write_Reg((WRITE_REG|Bank0_Reg[i][0]),Bank0_Reg[i][1]);
//        SwitchCFG(1);

//        for(i=0;i<=8;i++)//reverse
//        {
//                for(j=0;j<4;j++) WriteArr[j]=(Bank1_Reg0_13[i]>>(8*(j) ) )& 0xff;
//                SPI_Write_Buf((WRITE_REG|i),&(WriteArr[0]),4);
//        }
//       for(i=9;i<=13;i++)
//        {
//                for(j=0;j<4;j++) WriteArr[j]=(Bank1_Reg0_13[i]>>(8*(3-j) ) ) & 0xff;
//                SPI_Write_Buf((WRITE_REG|i),&(WriteArr[0]),4);
//        }
//       SPI_Write_Buf((WRITE_REG|14),&(Bank1_Reg14[0]),11);
//        for(j=0;j<4;j++) WriteArr[j]=(Bank1_Reg0_13[4]>>(8*(j) ) )& 0xff;
//        WriteArr[0] = WriteArr[0] | 0x06;
//        SPI_Write_Buf((WRITE_REG|4),&(WriteArr[0]),4);
//        WriteArr[0] = WriteArr[0] & 0xf9;
//        SPI_Write_Buf((WRITE_REG|4),&(WriteArr[0]),4);
//        Delay_ms(10);
//        SwitchCFG(0);
//        SwitchToRxMode();//switch to RX mode




signed char i,j;
    UINT8 rData;
    UINT8 WriteArr[4];
    //UINT8 addr,value;

   Delay_Ms(100);   //delay more than 50ms.

    SwitchCFG(0);

//********************Write Bank0 register******************
    for( i = (BANK0_REG_LIST_CNT - 1); i >= 0; i-- )
    {
        SPI_Write_Reg( (WRITE_REG | Bank0_Reg[i][0]), Bank0_Reg[i][1] );
        rData = SPI_Read_Reg( Bank0_Reg[i][0] );
    }

    //reg 10 - Rx0 addr
    RF_SET_RX_ADDR( (UINT8 *)RX_Address );

    //REG 16 - TX addr
    RF_SET_TX_ADDR( (UINT8 *)TX_Address );

    i = SPI_Read_Reg( 29 );

    if( i == 0 ) // i!=0 showed that chip has been actived.so do not active again.
    {
        SPI_Write_Reg( ACTIVATE_CMD, 0x73 );// Active
    }

    for( i = (BANK0_REGACT_LIST_CNT - 1); i >= 0; i-- )
    {
        SPI_Write_Reg( (WRITE_REG | Bank0_RegAct[i][0]), Bank0_RegAct[i][1] );

        SPI_Read_Reg( (Bank0_RegAct[i][0]) );
    }


//********************Write Bank1 register******************
    SwitchCFG(1);

    for( i = 0; i <= 8; i++ )//reverse
    {
        for( j = 0; j < 4; j++ )
        {
            WriteArr[ j ] = ( Bank1_Reg0_13[i] >> ( 8 * (j) ) ) & 0xff;
        }

        SPI_Write_Buf( (WRITE_REG|i), &(WriteArr[0]), 4 );
    }

    for( i = 9; i <= 13; i++ )
    {
        for( j = 0; j < 4; j++ )
        {
            WriteArr[j] = ( Bank1_Reg0_13[i] >> ( 8 * ( 3 - j ) ) ) & 0xff;
        }

        SPI_Write_Buf( ( WRITE_REG|i), &(WriteArr[0]), 4 );
    }

    SPI_Write_Buf( ( WRITE_REG|14), (UINT8 *)&(Bank1_Reg14[0]), 11 );

    //toggle REG4<25,26>
    for( j = 0; j < 4; j++ )
    {
        WriteArr[j] = ( Bank1_Reg0_13[4] >> ( 8 * (j) ) ) & 0xff;
    }

    WriteArr[0] = WriteArr[0] | 0x06;
    SPI_Write_Buf( (WRITE_REG | 4), &(WriteArr[0]), 4 );

    WriteArr[0] = WriteArr[0] & 0xf9;
    SPI_Write_Buf( (WRITE_REG | 4 ), &(WriteArr[0] ), 4 );

    Delay_Ms( 10 );

//********************switch back to Bank0 register access******************
    SwitchCFG( 0 );

    SwitchToRxMode();//switch to RX mode

    RF_FLUSH_RX();
    RF_FLUSH_TX();
}