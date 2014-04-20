#define READ_REG        0x00  // Define read command to register
#define WRITE_REG       0x20  // Define write command to register
#define RD_RX_PLOAD     0x61  // Define RX payload register address
#define WR_TX_PLOAD     0xA0  // Define TX payload register address
#define FLUSH_TX        0xE1  // Define flush TX register command
#define FLUSH_RX        0xE2  // Define flush RX register command
#define REUSE_TX_PL     0xE3  // Define reuse TX payload register command
#define W_TX_PAYLOAD_NOACK_CMD        0xb0
#define W_ACK_PAYLOAD_CMD        0xa8
#define ACTIVATE_CMD                0x50
#define R_RX_PL_WID_CMD                0x60

#define     RFPKT_LEN       5


//EXTERN MACROS=====================================================================
//Set RX address
#define RF_SET_RX_ADDR(addr) { SPI_Write_Buf((WRITE_REG|RX_ADDR_P0), addr, 5); }
//TX address
#define RF_SET_TX_ADDR(addr) { SPI_Write_Buf((WRITE_REG|TX_ADDR), addr, 5); }
//Set ACK
#define RF_SET_AUTO_ACK(enable) { SPI_Write_Reg((WRITE_REG|EN_AA), enable); }
//choice pipe
#define RF_SET_CHN(ch) { SPI_Write_Reg((WRITE_REG|RF_CH), ch); }
//Read status register
#define RF_GET_STATUS() ( SPI_Read_Reg(STATUS) )
//Clear IRQ
#define RF_CLR_IRQ(x) { SPI_Write_Reg(WRITE_REG|STATUS, x); }
//Read receiver data length
#define RF_GET_RX_PL_LEN() ( SPI_Read_Reg(R_RX_PL_WID_CMD) )
//Read result of carry detection
#define RF_GET_CD() ( SPI_Read_Reg(CD) )
//Clear RX FIFO
#define RF_FLUSH_RX() { SPI_Write_Reg(FLUSH_RX,0); }
//Clear TX FIFO
#define RF_FLUSH_TX() { SPI_Write_Reg(FLUSH_TX,0); }
