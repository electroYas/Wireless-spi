
_SPI_RW:

;bk2421_initialize.c,166 :: 		UINT8 SPI_RW(UINT8 value)
;bk2421_initialize.c,169 :: 		for(bit_ctr=0;bit_ctr<8;bit_ctr++)   // output 8-bit
	CLRF        R1 
L_SPI_RW0:
	MOVLW       8
	SUBWF       R1, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SPI_RW1
;bk2421_initialize.c,171 :: 		if(value & 0x80)
	BTFSS       FARG_SPI_RW_value+0, 7 
	GOTO        L_SPI_RW3
;bk2421_initialize.c,173 :: 		MOSI=1;
	BSF         PORTC+0, 3 
;bk2421_initialize.c,174 :: 		}
	GOTO        L_SPI_RW4
L_SPI_RW3:
;bk2421_initialize.c,177 :: 		MOSI=0;
	BCF         PORTC+0, 3 
;bk2421_initialize.c,178 :: 		}
L_SPI_RW4:
;bk2421_initialize.c,180 :: 		value = value << 1;           // shift next bit into MSB..
	RLCF        FARG_SPI_RW_value+0, 1 
	BCF         FARG_SPI_RW_value+0, 0 
;bk2421_initialize.c,181 :: 		SCK = 1;                      // Set SCK high..
	BSF         PORTC+0, 2 
;bk2421_initialize.c,182 :: 		value |= MISO;                         // capture current MISO bit
	CLRF        R0 
	BTFSC       PORTC+0, 4 
	INCF        R0, 1 
	MOVF        R0, 0 
	IORWF       FARG_SPI_RW_value+0, 1 
;bk2421_initialize.c,183 :: 		SCK = 0;                              // ..then set SCK low again
	BCF         PORTC+0, 2 
;bk2421_initialize.c,169 :: 		for(bit_ctr=0;bit_ctr<8;bit_ctr++)   // output 8-bit
	INCF        R1, 1 
;bk2421_initialize.c,184 :: 		}
	GOTO        L_SPI_RW0
L_SPI_RW1:
;bk2421_initialize.c,185 :: 		return(value);                             // return read UINT8
	MOVF        FARG_SPI_RW_value+0, 0 
	MOVWF       R0 
;bk2421_initialize.c,186 :: 		}
	RETURN      0
; end of _SPI_RW

_SPI_Write_Reg:

;bk2421_initialize.c,195 :: 		void SPI_Write_Reg(UINT8 reg, UINT8 value)
;bk2421_initialize.c,197 :: 		CSN = 0;                   // CSN low, init SPI transaction
	BCF         PORTC+0, 1 
;bk2421_initialize.c,198 :: 		op_status = SPI_RW(reg);      // select register
	MOVF        FARG_SPI_Write_Reg_reg+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
	MOVF        R0, 0 
	MOVWF       _op_status+0 
;bk2421_initialize.c,199 :: 		SPI_RW(value);             // ..and write value to it..
	MOVF        FARG_SPI_Write_Reg_value+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
;bk2421_initialize.c,200 :: 		CSN = 1;                   // CSN high again
	BSF         PORTC+0, 1 
;bk2421_initialize.c,201 :: 		}
	RETURN      0
; end of _SPI_Write_Reg

_SPI_Read_Reg:

;bk2421_initialize.c,210 :: 		UINT8 SPI_Read_Reg(UINT8 reg)
;bk2421_initialize.c,213 :: 		CSN = 0;                // CSN low, initialize SPI communication...
	BCF         PORTC+0, 1 
;bk2421_initialize.c,214 :: 		op_status=SPI_RW(reg);            // Select register to read from..
	MOVF        FARG_SPI_Read_Reg_reg+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
	MOVF        R0, 0 
	MOVWF       _op_status+0 
;bk2421_initialize.c,215 :: 		value = SPI_RW(0);    // ..then read register value
	CLRF        FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
;bk2421_initialize.c,216 :: 		CSN = 1;                // CSN high, terminate SPI communication
	BSF         PORTC+0, 1 
;bk2421_initialize.c,218 :: 		return(value);        // return register value
;bk2421_initialize.c,219 :: 		}
	RETURN      0
; end of _SPI_Read_Reg

_SPI_Read_Buf:

;bk2421_initialize.c,228 :: 		void SPI_Read_Buf(UINT8 reg, UINT8 *pBuf, UINT8 length)
;bk2421_initialize.c,232 :: 		CSN = 0;                                    // Set CSN l
	BCF         PORTC+0, 1 
;bk2421_initialize.c,233 :: 		status = SPI_RW(reg);                       // Select register to write, and read status UINT8
	MOVF        FARG_SPI_Read_Buf_reg+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
;bk2421_initialize.c,235 :: 		for(byte_ctr=0;byte_ctr<length;byte_ctr++)
	CLRF        SPI_Read_Buf_byte_ctr_L0+0 
L_SPI_Read_Buf5:
	MOVF        FARG_SPI_Read_Buf_length+0, 0 
	SUBWF       SPI_Read_Buf_byte_ctr_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SPI_Read_Buf6
;bk2421_initialize.c,236 :: 		pBuf[byte_ctr] = SPI_RW(0);    // Perform SPI_RW to read UINT8 from BK2421
	MOVF        SPI_Read_Buf_byte_ctr_L0+0, 0 
	ADDWF       FARG_SPI_Read_Buf_pBuf+0, 0 
	MOVWF       FLOC__SPI_Read_Buf+0 
	MOVLW       0
	ADDWFC      FARG_SPI_Read_Buf_pBuf+1, 0 
	MOVWF       FLOC__SPI_Read_Buf+1 
	CLRF        FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
	MOVFF       FLOC__SPI_Read_Buf+0, FSR1L
	MOVFF       FLOC__SPI_Read_Buf+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;bk2421_initialize.c,235 :: 		for(byte_ctr=0;byte_ctr<length;byte_ctr++)
	INCF        SPI_Read_Buf_byte_ctr_L0+0, 1 
;bk2421_initialize.c,236 :: 		pBuf[byte_ctr] = SPI_RW(0);    // Perform SPI_RW to read UINT8 from BK2421
	GOTO        L_SPI_Read_Buf5
L_SPI_Read_Buf6:
;bk2421_initialize.c,238 :: 		CSN = 1;                           // Set CSN high again
	BSF         PORTC+0, 1 
;bk2421_initialize.c,240 :: 		}
	RETURN      0
; end of _SPI_Read_Buf

_SPI_Write_Buf:

;bk2421_initialize.c,249 :: 		void SPI_Write_Buf(UINT8 reg, UINT8 *pBuf, UINT8 length)
;bk2421_initialize.c,253 :: 		CSN = 0;                   // Set CSN low, init SPI tranaction
	BCF         PORTC+0, 1 
;bk2421_initialize.c,254 :: 		op_status = SPI_RW(reg);    // Select register to write to and read status UINT8
	MOVF        FARG_SPI_Write_Buf_reg+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
	MOVF        R0, 0 
	MOVWF       _op_status+0 
;bk2421_initialize.c,255 :: 		for(byte_ctr=0; byte_ctr<length; byte_ctr++) // then write all UINT8 in buffer(*pBuf)
	CLRF        SPI_Write_Buf_byte_ctr_L0+0 
L_SPI_Write_Buf8:
	MOVF        FARG_SPI_Write_Buf_length+0, 0 
	SUBWF       SPI_Write_Buf_byte_ctr_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SPI_Write_Buf9
;bk2421_initialize.c,256 :: 		SPI_RW(*pBuf++);
	MOVFF       FARG_SPI_Write_Buf_pBuf+0, FSR0L
	MOVFF       FARG_SPI_Write_Buf_pBuf+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SPI_RW_value+0 
	CALL        _SPI_RW+0, 0
	INFSNZ      FARG_SPI_Write_Buf_pBuf+0, 1 
	INCF        FARG_SPI_Write_Buf_pBuf+1, 1 
;bk2421_initialize.c,255 :: 		for(byte_ctr=0; byte_ctr<length; byte_ctr++) // then write all UINT8 in buffer(*pBuf)
	INCF        SPI_Write_Buf_byte_ctr_L0+0, 1 
;bk2421_initialize.c,256 :: 		SPI_RW(*pBuf++);
	GOTO        L_SPI_Write_Buf8
L_SPI_Write_Buf9:
;bk2421_initialize.c,257 :: 		CSN = 1;                 // Set CSN high again
	BSF         PORTC+0, 1 
;bk2421_initialize.c,259 :: 		}
	RETURN      0
; end of _SPI_Write_Buf

_SwitchToRxMode:

;bk2421_initialize.c,268 :: 		void SwitchToRxMode()
;bk2421_initialize.c,272 :: 		SPI_Write_Reg(FLUSH_RX,0);//flush Rx
	MOVLW       226
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CLRF        FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,274 :: 		value=SPI_Read_Reg(STATUS1);        // read register STATUS's value
	MOVLW       7
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
;bk2421_initialize.c,275 :: 		SPI_Write_Reg(WRITE_REG|STATUS1,value);// clear RX_DR or TX_DS or MAX_RT interrupt flag
	MOVLW       39
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVF        R0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,277 :: 		CE=0;
	BCF         PORTC+0, 0 
;bk2421_initialize.c,279 :: 		value=SPI_Read_Reg(CONFIG);        // read register CONFIG's value
	CLRF        FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
;bk2421_initialize.c,281 :: 		value=value|0x01;//set bit 1
	MOVLW       1
	IORWF       R0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
;bk2421_initialize.c,282 :: 		SPI_Write_Reg(WRITE_REG | CONFIG, value); // Set PWR_UP bit, enable CRC(2 length) & Prim:RX. RX_DR enabled..
	MOVLW       32
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,284 :: 		CE=1;
	BSF         PORTC+0, 0 
;bk2421_initialize.c,285 :: 		}
	RETURN      0
; end of _SwitchToRxMode

_SwitchToTxMode:

;bk2421_initialize.c,292 :: 		void SwitchToTxMode()
;bk2421_initialize.c,295 :: 		SPI_Write_Reg(FLUSH_TX,0);//flush Tx
	MOVLW       225
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CLRF        FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,297 :: 		CE=0;
	BCF         PORTC+0, 0 
;bk2421_initialize.c,298 :: 		value=SPI_Read_Reg(CONFIG);        // read register CONFIG's value
	CLRF        FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
;bk2421_initialize.c,300 :: 		value=value&0xfe;//set bit 1
	MOVLW       254
	ANDWF       R0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
;bk2421_initialize.c,301 :: 		SPI_Write_Reg(WRITE_REG | CONFIG, value); // Set PWR_UP bit, enable CRC(2 length) & Prim:RX. RX_DR enabled.
	MOVLW       32
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,303 :: 		CE=1;
	BSF         PORTC+0, 0 
;bk2421_initialize.c,304 :: 		}
	RETURN      0
; end of _SwitchToTxMode

_SwitchCFG:

;bk2421_initialize.c,318 :: 		void SwitchCFG(char _cfg)//1:Bank1 0:Bank0
;bk2421_initialize.c,322 :: 		Tmp=SPI_Read_Reg(7);
	MOVLW       7
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
	MOVF        R0, 0 
	MOVWF       SwitchCFG_Tmp_L0+0 
;bk2421_initialize.c,323 :: 		Tmp=Tmp & 0x80;
	MOVLW       128
	ANDWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       SwitchCFG_Tmp_L0+0 
;bk2421_initialize.c,325 :: 		if( ( (Tmp) && (_cfg==0) )||( ((Tmp)==0) && (_cfg) ) )
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L__SwitchCFG59
	MOVF        FARG_SwitchCFG__cfg+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__SwitchCFG59
	GOTO        L__SwitchCFG57
L__SwitchCFG59:
	MOVF        SwitchCFG_Tmp_L0+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__SwitchCFG58
	MOVF        FARG_SwitchCFG__cfg+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L__SwitchCFG58
	GOTO        L__SwitchCFG57
L__SwitchCFG58:
	GOTO        L_SwitchCFG17
L__SwitchCFG57:
;bk2421_initialize.c,327 :: 		SPI_Write_Reg(ACTIVATE_CMD,0x53);
	MOVLW       80
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVLW       83
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,328 :: 		}
L_SwitchCFG17:
;bk2421_initialize.c,329 :: 		}
	RETURN      0
; end of _SwitchCFG

_SetChannelNum:

;bk2421_initialize.c,337 :: 		void SetChannelNum(UINT8 ch)
;bk2421_initialize.c,339 :: 		SPI_Write_Reg((UINT8)(WRITE_REG|5),(UINT8)(ch));
	MOVLW       37
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVF        FARG_SetChannelNum_ch+0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,340 :: 		}
	RETURN      0
; end of _SetChannelNum

_BK2421_Initialize:

;bk2421_initialize.c,353 :: 		void BK2421_Initialize()
;bk2421_initialize.c,400 :: 		Delay_Ms(100);   //delay more than 50ms.
	MOVLW       130
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_BK2421_Initialize18:
	DECFSZ      R13, 1, 1
	BRA         L_BK2421_Initialize18
	DECFSZ      R12, 1, 1
	BRA         L_BK2421_Initialize18
	NOP
	NOP
;bk2421_initialize.c,402 :: 		SwitchCFG(0);
	CLRF        FARG_SwitchCFG__cfg+0 
	CALL        _SwitchCFG+0, 0
;bk2421_initialize.c,405 :: 		for( i = (BANK0_REG_LIST_CNT - 1); i >= 0; i-- )
	MOVLW       20
	MOVWF       BK2421_Initialize_i_L0+0 
L_BK2421_Initialize19:
	MOVLW       128
	XORWF       BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_BK2421_Initialize20
;bk2421_initialize.c,407 :: 		SPI_Write_Reg( (WRITE_REG | Bank0_Reg[i][0]), Bank0_Reg[i][1] );
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank0_Reg+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_Bank0_Reg+0)
	ADDWFC      R1, 1 
	MOVFF       R0, FSR2L
	MOVFF       R1, FSR2H
	MOVLW       32
	IORWF       POSTINC2+0, 0 
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,408 :: 		rData = SPI_Read_Reg( Bank0_Reg[i][0] );
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank0_Reg+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_Bank0_Reg+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
;bk2421_initialize.c,405 :: 		for( i = (BANK0_REG_LIST_CNT - 1); i >= 0; i-- )
	DECF        BK2421_Initialize_i_L0+0, 1 
;bk2421_initialize.c,409 :: 		}
	GOTO        L_BK2421_Initialize19
L_BK2421_Initialize20:
;bk2421_initialize.c,412 :: 		RF_SET_RX_ADDR( (UINT8 *)RX_Address );
	MOVLW       42
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       _RX_Address+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(_RX_Address+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       5
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,415 :: 		RF_SET_TX_ADDR( (UINT8 *)TX_Address );
	MOVLW       48
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       _TX_Address+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(_TX_Address+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       5
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,417 :: 		i = SPI_Read_Reg( 29 );
	MOVLW       29
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
	MOVF        R0, 0 
	MOVWF       BK2421_Initialize_i_L0+0 
;bk2421_initialize.c,419 :: 		if( i == 0 ) // i!=0 showed that chip has been actived.so do not active again.
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_BK2421_Initialize22
;bk2421_initialize.c,421 :: 		SPI_Write_Reg( ACTIVATE_CMD, 0x73 );// Active
	MOVLW       80
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVLW       115
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,422 :: 		}
L_BK2421_Initialize22:
;bk2421_initialize.c,424 :: 		for( i = (BANK0_REGACT_LIST_CNT - 1); i >= 0; i-- )
	MOVLW       1
	MOVWF       BK2421_Initialize_i_L0+0 
L_BK2421_Initialize23:
	MOVLW       128
	XORWF       BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_BK2421_Initialize24
;bk2421_initialize.c,426 :: 		SPI_Write_Reg( (WRITE_REG | Bank0_RegAct[i][0]), Bank0_RegAct[i][1] );
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank0_RegAct+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_Bank0_RegAct+0)
	ADDWFC      R1, 1 
	MOVFF       R0, FSR2L
	MOVFF       R1, FSR2H
	MOVLW       32
	IORWF       POSTINC2+0, 0 
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,428 :: 		SPI_Read_Reg( (Bank0_RegAct[i][0]) );
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank0_RegAct+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_Bank0_RegAct+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
;bk2421_initialize.c,424 :: 		for( i = (BANK0_REGACT_LIST_CNT - 1); i >= 0; i-- )
	DECF        BK2421_Initialize_i_L0+0, 1 
;bk2421_initialize.c,429 :: 		}
	GOTO        L_BK2421_Initialize23
L_BK2421_Initialize24:
;bk2421_initialize.c,433 :: 		SwitchCFG(1);
	MOVLW       1
	MOVWF       FARG_SwitchCFG__cfg+0 
	CALL        _SwitchCFG+0, 0
;bk2421_initialize.c,435 :: 		for( i = 0; i <= 8; i++ )//reverse
	CLRF        BK2421_Initialize_i_L0+0 
L_BK2421_Initialize26:
	MOVLW       128
	XORLW       8
	MOVWF       R0 
	MOVLW       128
	XORWF       BK2421_Initialize_i_L0+0, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_BK2421_Initialize27
;bk2421_initialize.c,437 :: 		for( j = 0; j < 4; j++ )
	CLRF        BK2421_Initialize_j_L0+0 
L_BK2421_Initialize29:
	MOVLW       128
	XORWF       BK2421_Initialize_j_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_BK2421_Initialize30
;bk2421_initialize.c,439 :: 		WriteArr[ j ] = ( Bank1_Reg0_13[i] >> ( 8 * (j) ) ) & 0xff;
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FSR1L 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FSR1H 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	ADDWF       FSR1L, 1 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank1_Reg0_13+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_Bank1_Reg0_13+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R5 
	MOVF        POSTINC0+0, 0 
	MOVWF       R6 
	MOVF        POSTINC0+0, 0 
	MOVWF       R7 
	MOVF        POSTINC0+0, 0 
	MOVWF       R8 
	MOVLW       3
	MOVWF       R2 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	MOVF        R2, 0 
L__BK2421_Initialize60:
	BZ          L__BK2421_Initialize61
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__BK2421_Initialize60
L__BK2421_Initialize61:
	MOVF        R0, 0 
	MOVWF       R4 
	MOVF        R5, 0 
	MOVWF       R0 
	MOVF        R6, 0 
	MOVWF       R1 
	MOVF        R7, 0 
	MOVWF       R2 
	MOVF        R8, 0 
	MOVWF       R3 
	MOVF        R4, 0 
L__BK2421_Initialize62:
	BZ          L__BK2421_Initialize63
	RRCF        R3, 1 
	RRCF        R2, 1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R3, 7 
	ADDLW       255
	GOTO        L__BK2421_Initialize62
L__BK2421_Initialize63:
	MOVLW       255
	ANDWF       R0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;bk2421_initialize.c,437 :: 		for( j = 0; j < 4; j++ )
	INCF        BK2421_Initialize_j_L0+0, 1 
;bk2421_initialize.c,440 :: 		}
	GOTO        L_BK2421_Initialize29
L_BK2421_Initialize30:
;bk2421_initialize.c,442 :: 		SPI_Write_Buf( (WRITE_REG|i), &(WriteArr[0]), 4 );
	MOVLW       32
	IORWF       BK2421_Initialize_i_L0+0, 0 
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       4
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,435 :: 		for( i = 0; i <= 8; i++ )//reverse
	INCF        BK2421_Initialize_i_L0+0, 1 
;bk2421_initialize.c,443 :: 		}
	GOTO        L_BK2421_Initialize26
L_BK2421_Initialize27:
;bk2421_initialize.c,445 :: 		for( i = 9; i <= 13; i++ )
	MOVLW       9
	MOVWF       BK2421_Initialize_i_L0+0 
L_BK2421_Initialize32:
	MOVLW       128
	XORLW       13
	MOVWF       R0 
	MOVLW       128
	XORWF       BK2421_Initialize_i_L0+0, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_BK2421_Initialize33
;bk2421_initialize.c,447 :: 		for( j = 0; j < 4; j++ )
	CLRF        BK2421_Initialize_j_L0+0 
L_BK2421_Initialize35:
	MOVLW       128
	XORWF       BK2421_Initialize_j_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_BK2421_Initialize36
;bk2421_initialize.c,449 :: 		WriteArr[j] = ( Bank1_Reg0_13[i] >> ( 8 * ( 3 - j ) ) ) & 0xff;
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FSR1L 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FSR1H 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	ADDWF       FSR1L, 1 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        BK2421_Initialize_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_i_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _Bank1_Reg0_13+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_Bank1_Reg0_13+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R5 
	MOVF        POSTINC0+0, 0 
	MOVWF       R6 
	MOVF        POSTINC0+0, 0 
	MOVWF       R7 
	MOVF        POSTINC0+0, 0 
	MOVWF       R8 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	SUBLW       3
	MOVWF       R3 
	CLRF        R4 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	SUBWFB      R4, 1 
	MOVLW       3
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__BK2421_Initialize64:
	BZ          L__BK2421_Initialize65
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__BK2421_Initialize64
L__BK2421_Initialize65:
	MOVF        R0, 0 
	MOVWF       R4 
	MOVF        R5, 0 
	MOVWF       R0 
	MOVF        R6, 0 
	MOVWF       R1 
	MOVF        R7, 0 
	MOVWF       R2 
	MOVF        R8, 0 
	MOVWF       R3 
	MOVF        R4, 0 
L__BK2421_Initialize66:
	BZ          L__BK2421_Initialize67
	RRCF        R3, 1 
	RRCF        R2, 1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R3, 7 
	ADDLW       255
	GOTO        L__BK2421_Initialize66
L__BK2421_Initialize67:
	MOVLW       255
	ANDWF       R0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;bk2421_initialize.c,447 :: 		for( j = 0; j < 4; j++ )
	INCF        BK2421_Initialize_j_L0+0, 1 
;bk2421_initialize.c,450 :: 		}
	GOTO        L_BK2421_Initialize35
L_BK2421_Initialize36:
;bk2421_initialize.c,452 :: 		SPI_Write_Buf( ( WRITE_REG|i), &(WriteArr[0]), 4 );
	MOVLW       32
	IORWF       BK2421_Initialize_i_L0+0, 0 
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       4
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,445 :: 		for( i = 9; i <= 13; i++ )
	INCF        BK2421_Initialize_i_L0+0, 1 
;bk2421_initialize.c,453 :: 		}
	GOTO        L_BK2421_Initialize32
L_BK2421_Initialize33:
;bk2421_initialize.c,455 :: 		SPI_Write_Buf( ( WRITE_REG|14), (UINT8 *)&(Bank1_Reg14[0]), 11 );
	MOVLW       46
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       _Bank1_Reg14+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(_Bank1_Reg14+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       11
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,458 :: 		for( j = 0; j < 4; j++ )
	CLRF        BK2421_Initialize_j_L0+0 
L_BK2421_Initialize38:
	MOVLW       128
	XORWF       BK2421_Initialize_j_L0+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_BK2421_Initialize39
;bk2421_initialize.c,460 :: 		WriteArr[j] = ( Bank1_Reg0_13[4] >> ( 8 * (j) ) ) & 0xff;
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FSR1L 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FSR1H 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	ADDWF       FSR1L, 1 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVLW       3
	MOVWF       R2 
	MOVF        BK2421_Initialize_j_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       BK2421_Initialize_j_L0+0, 7 
	MOVLW       255
	MOVWF       R1 
	MOVF        R2, 0 
L__BK2421_Initialize68:
	BZ          L__BK2421_Initialize69
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__BK2421_Initialize68
L__BK2421_Initialize69:
	MOVF        R0, 0 
	MOVWF       R4 
	MOVF        _Bank1_Reg0_13+16, 0 
	MOVWF       R0 
	MOVF        _Bank1_Reg0_13+17, 0 
	MOVWF       R1 
	MOVF        _Bank1_Reg0_13+18, 0 
	MOVWF       R2 
	MOVF        _Bank1_Reg0_13+19, 0 
	MOVWF       R3 
	MOVF        R4, 0 
L__BK2421_Initialize70:
	BZ          L__BK2421_Initialize71
	RRCF        R3, 1 
	RRCF        R2, 1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R3, 7 
	ADDLW       255
	GOTO        L__BK2421_Initialize70
L__BK2421_Initialize71:
	MOVLW       255
	ANDWF       R0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;bk2421_initialize.c,458 :: 		for( j = 0; j < 4; j++ )
	INCF        BK2421_Initialize_j_L0+0, 1 
;bk2421_initialize.c,461 :: 		}
	GOTO        L_BK2421_Initialize38
L_BK2421_Initialize39:
;bk2421_initialize.c,463 :: 		WriteArr[0] = WriteArr[0] | 0x06;
	MOVLW       6
	IORWF       BK2421_Initialize_WriteArr_L0+0, 1 
;bk2421_initialize.c,464 :: 		SPI_Write_Buf( (WRITE_REG | 4), &(WriteArr[0]), 4 );
	MOVLW       36
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       4
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,466 :: 		WriteArr[0] = WriteArr[0] & 0xf9;
	MOVLW       249
	ANDWF       BK2421_Initialize_WriteArr_L0+0, 1 
;bk2421_initialize.c,467 :: 		SPI_Write_Buf( (WRITE_REG | 4 ), &(WriteArr[0] ), 4 );
	MOVLW       36
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVLW       BK2421_Initialize_WriteArr_L0+0
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVLW       hi_addr(BK2421_Initialize_WriteArr_L0+0)
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVLW       4
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;bk2421_initialize.c,469 :: 		Delay_Ms( 10 );
	MOVLW       13
	MOVWF       R12, 0
	MOVLW       251
	MOVWF       R13, 0
L_BK2421_Initialize41:
	DECFSZ      R13, 1, 1
	BRA         L_BK2421_Initialize41
	DECFSZ      R12, 1, 1
	BRA         L_BK2421_Initialize41
	NOP
	NOP
;bk2421_initialize.c,472 :: 		SwitchCFG( 0 );
	CLRF        FARG_SwitchCFG__cfg+0 
	CALL        _SwitchCFG+0, 0
;bk2421_initialize.c,474 :: 		SwitchToRxMode();//switch to RX mode
	CALL        _SwitchToRxMode+0, 0
;bk2421_initialize.c,476 :: 		RF_FLUSH_RX();
	MOVLW       226
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CLRF        FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,477 :: 		RF_FLUSH_TX();
	MOVLW       225
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CLRF        FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;bk2421_initialize.c,478 :: 		}
	RETURN      0
; end of _BK2421_Initialize

_RF_WriteTxPayload:

;test_2_rx.c,16 :: 		void RF_WriteTxPayload( unsigned short* pbuf, unsigned short len )
;test_2_rx.c,18 :: 		SPI_Write_Buf( WR_TX_PLOAD, pbuf, len ); // Writes data to TX FIFO
	MOVLW       160
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVF        FARG_RF_WriteTxPayload_pbuf+0, 0 
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVF        FARG_RF_WriteTxPayload_pbuf+1, 0 
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVF        FARG_RF_WriteTxPayload_len+0, 0 
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;test_2_rx.c,19 :: 		}
	RETURN      0
; end of _RF_WriteTxPayload

_RF_WriteAckPayload:

;test_2_rx.c,21 :: 		void RF_WriteAckPayload( unsigned short* pbuf, unsigned short len )
;test_2_rx.c,23 :: 		SPI_Write_Buf( W_ACK_PAYLOAD_CMD, pbuf, len ); // Writes data to ACK FIFO
	MOVLW       168
	MOVWF       FARG_SPI_Write_Buf_reg+0 
	MOVF        FARG_RF_WriteAckPayload_pbuf+0, 0 
	MOVWF       FARG_SPI_Write_Buf_pBuf+0 
	MOVF        FARG_RF_WriteAckPayload_pbuf+1, 0 
	MOVWF       FARG_SPI_Write_Buf_pBuf+1 
	MOVF        FARG_RF_WriteAckPayload_len+0, 0 
	MOVWF       FARG_SPI_Write_Buf_length+0 
	CALL        _SPI_Write_Buf+0, 0
;test_2_rx.c,24 :: 		}
	RETURN      0
; end of _RF_WriteAckPayload

_RF_ReadRxPayload:

;test_2_rx.c,27 :: 		unsigned short RF_ReadRxPayload(unsigned short *pbuf, unsigned short maxlen)
;test_2_rx.c,29 :: 		unsigned short i = 0;
	CLRF        RF_ReadRxPayload_i_L0+0 
;test_2_rx.c,32 :: 		len = RF_GET_RX_PL_LEN();                //Get Top of fifo packet length
	MOVLW       96
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
	MOVF        R0, 0 
	MOVWF       RF_ReadRxPayload_len_L0+0 
;test_2_rx.c,33 :: 		if( len > maxlen )
	MOVF        R0, 0 
	SUBWF       FARG_RF_ReadRxPayload_maxlen+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_RF_ReadRxPayload42
;test_2_rx.c,35 :: 		len = maxlen;
	MOVF        FARG_RF_ReadRxPayload_maxlen+0, 0 
	MOVWF       RF_ReadRxPayload_len_L0+0 
;test_2_rx.c,36 :: 		}
L_RF_ReadRxPayload42:
;test_2_rx.c,37 :: 		for ( i = 0; i < maxlen; i++ )          //Clear buffer
	CLRF        RF_ReadRxPayload_i_L0+0 
L_RF_ReadRxPayload43:
	MOVF        FARG_RF_ReadRxPayload_maxlen+0, 0 
	SUBWF       RF_ReadRxPayload_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_RF_ReadRxPayload44
;test_2_rx.c,39 :: 		pbuf[ i ] = 0;
	MOVF        RF_ReadRxPayload_i_L0+0, 0 
	ADDWF       FARG_RF_ReadRxPayload_pbuf+0, 0 
	MOVWF       FSR1L 
	MOVLW       0
	ADDWFC      FARG_RF_ReadRxPayload_pbuf+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;test_2_rx.c,37 :: 		for ( i = 0; i < maxlen; i++ )          //Clear buffer
	INCF        RF_ReadRxPayload_i_L0+0, 1 
;test_2_rx.c,40 :: 		}
	GOTO        L_RF_ReadRxPayload43
L_RF_ReadRxPayload44:
;test_2_rx.c,41 :: 		SPI_Read_Buf(RD_RX_PLOAD, pbuf, len);   // read receive payload from RX_FIFO buffer
	MOVLW       97
	MOVWF       FARG_SPI_Read_Buf_reg+0 
	MOVF        FARG_RF_ReadRxPayload_pbuf+0, 0 
	MOVWF       FARG_SPI_Read_Buf_pBuf+0 
	MOVF        FARG_RF_ReadRxPayload_pbuf+1, 0 
	MOVWF       FARG_SPI_Read_Buf_pBuf+1 
	MOVF        RF_ReadRxPayload_len_L0+0, 0 
	MOVWF       FARG_SPI_Read_Buf_length+0 
	CALL        _SPI_Read_Buf+0, 0
;test_2_rx.c,42 :: 		return len;
	MOVF        RF_ReadRxPayload_len_L0+0, 0 
	MOVWF       R0 
;test_2_rx.c,43 :: 		}
	RETURN      0
; end of _RF_ReadRxPayload

_system_init:

;test_2_rx.c,45 :: 		void system_init(){
;test_2_rx.c,46 :: 		ADCON1 = 0X0F;
	MOVLW       15
	MOVWF       ADCON1+0 
;test_2_rx.c,47 :: 		TRISC = 0B00010000;
	MOVLW       16
	MOVWF       TRISC+0 
;test_2_rx.c,48 :: 		PORTC = 0;
	CLRF        PORTC+0 
;test_2_rx.c,49 :: 		TRISB = 0B00000001;
	MOVLW       1
	MOVWF       TRISB+0 
;test_2_rx.c,50 :: 		PORTB = 0;
	CLRF        PORTB+0 
;test_2_rx.c,53 :: 		CMCON.CM0 = 1;
	BSF         CMCON+0, 0 
;test_2_rx.c,54 :: 		CMCON.CM1 = 1;
	BSF         CMCON+0, 1 
;test_2_rx.c,55 :: 		CMCON.CM2 = 1;
	BSF         CMCON+0, 2 
;test_2_rx.c,57 :: 		T0CON.T08BIT = 1;
	BSF         T0CON+0, 6 
;test_2_rx.c,58 :: 		T0CON.T0CS = 0;
	BCF         T0CON+0, 5 
;test_2_rx.c,59 :: 		T0CON.PSA = 0;
	BCF         T0CON+0, 3 
;test_2_rx.c,60 :: 		T0CON.T0PS0 = 1;
	BSF         T0CON+0, 0 
;test_2_rx.c,61 :: 		T0CON.T0PS1 = 0;
	BCF         T0CON+0, 1 
;test_2_rx.c,62 :: 		T0CON.T0PS2 = 0;
	BCF         T0CON+0, 2 
;test_2_rx.c,63 :: 		T0CON.TMR0ON = 1;
	BSF         T0CON+0, 7 
;test_2_rx.c,66 :: 		INTCON.TMR0IE = 1;
	BSF         INTCON+0, 5 
;test_2_rx.c,67 :: 		INTCON.INT0IE = 1;
	BSF         INTCON+0, 4 
;test_2_rx.c,68 :: 		INTCON2.INTEDG0 = 0;
	BCF         INTCON2+0, 6 
;test_2_rx.c,69 :: 		INTCON.GIE = 1;
	BSF         INTCON+0, 7 
;test_2_rx.c,71 :: 		PORTD = 0;
	CLRF        PORTD+0 
;test_2_rx.c,72 :: 		TRISD = 0X00;
	CLRF        TRISD+0 
;test_2_rx.c,74 :: 		}
	RETURN      0
; end of _system_init

_interrupt:

;test_2_rx.c,76 :: 		void interrupt(){
;test_2_rx.c,77 :: 		if(INTCON.INT0IF){
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt46
;test_2_rx.c,78 :: 		g_RFIRQValid = 1;
	MOVLW       1
	MOVWF       _g_RFIRQValid+0 
;test_2_rx.c,79 :: 		INTCON.INT0IF = 0;
	BCF         INTCON+0, 1 
;test_2_rx.c,80 :: 		}
	GOTO        L_interrupt47
L_interrupt46:
;test_2_rx.c,81 :: 		else if(INTCON.TMR0IF){
	BTFSS       INTCON+0, 2 
	GOTO        L_interrupt48
;test_2_rx.c,82 :: 		g_DelayTick++;
	INCF        _g_DelayTick+0, 1 
;test_2_rx.c,83 :: 		tick++;
	INFSNZ      _tick+0, 1 
	INCF        _tick+1, 1 
;test_2_rx.c,84 :: 		if(tick>=500){
	MOVLW       128
	XORWF       _tick+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       1
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__interrupt73
	MOVLW       244
	SUBWF       _tick+0, 0 
L__interrupt73:
	BTFSS       STATUS+0, 0 
	GOTO        L_interrupt49
;test_2_rx.c,85 :: 		PORTB.F2 = PORTB.F2 ^ 1;
	BTG         PORTB+0, 2 
;test_2_rx.c,86 :: 		tick = 0;
	CLRF        _tick+0 
	CLRF        _tick+1 
;test_2_rx.c,87 :: 		TMR0L = 0;
	CLRF        TMR0L+0 
;test_2_rx.c,88 :: 		}
L_interrupt49:
;test_2_rx.c,89 :: 		INTCON.TMR0IF = 0;
	BCF         INTCON+0, 2 
;test_2_rx.c,90 :: 		}
L_interrupt48:
L_interrupt47:
;test_2_rx.c,92 :: 		}
L__interrupt72:
	RETFIE      1
; end of _interrupt

_main:

;test_2_rx.c,96 :: 		void main() {
;test_2_rx.c,99 :: 		system_init();
	CALL        _system_init+0, 0
;test_2_rx.c,100 :: 		BK2421_Initialize();
	CALL        _BK2421_Initialize+0, 0
;test_2_rx.c,102 :: 		while(1){
L_main50:
;test_2_rx.c,104 :: 		RF_READY();
	CALL        _RF_READY+0, 0
;test_2_rx.c,105 :: 		delay_ms(100);
	MOVLW       130
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_main52:
	DECFSZ      R13, 1, 1
	BRA         L_main52
	DECFSZ      R12, 1, 1
	BRA         L_main52
	NOP
	NOP
;test_2_rx.c,107 :: 		}
	GOTO        L_main50
;test_2_rx.c,108 :: 		}
	GOTO        $+0
; end of _main

_RF_READY:

;test_2_rx.c,112 :: 		void RF_READY(){
;test_2_rx.c,116 :: 		if( g_RFIRQValid )
	MOVF        _g_RFIRQValid+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_RF_READY53
;test_2_rx.c,118 :: 		INTCON.GIE = 0;//DISABLE INTERRUPTS
	BCF         INTCON+0, 7 
;test_2_rx.c,119 :: 		g_RFIRQValid = FALSE;
	CLRF        _g_RFIRQValid+0 
;test_2_rx.c,121 :: 		sta = RF_GET_STATUS();      //Get the RF status
	MOVF        STATUS+0, 0 
	MOVWF       FARG_SPI_Read_Reg_reg+0 
	CALL        _SPI_Read_Reg+0, 0
	MOVF        R0, 0 
	MOVWF       RF_READY_sta_L0+0 
;test_2_rx.c,123 :: 		if( sta & STATUS_RX_DR )    //Receive OK?
	BTFSS       R0, 6 
	GOTO        L_RF_READY54
;test_2_rx.c,126 :: 		rlen = RF_ReadRxPayload( (UINT8 *)&g_RFRecvBuff, RFPKT_LEN );
	MOVLW       _g_RFRecvBuff+0
	MOVWF       FARG_RF_ReadRxPayload_pbuf+0 
	MOVLW       hi_addr(_g_RFRecvBuff+0)
	MOVWF       FARG_RF_ReadRxPayload_pbuf+1 
	MOVLW       5
	MOVWF       FARG_RF_ReadRxPayload_maxlen+0 
	CALL        _RF_ReadRxPayload+0, 0
;test_2_rx.c,128 :: 		if ( rlen == RFPKT_LEN )
	MOVF        R0, 0 
	XORLW       5
	BTFSS       STATUS+0, 2 
	GOTO        L_RF_READY55
;test_2_rx.c,130 :: 		PORTD = g_RFRecvBuff[0];
	MOVF        _g_RFRecvBuff+0, 0 
	MOVWF       PORTD+0 
;test_2_rx.c,132 :: 		}
L_RF_READY55:
;test_2_rx.c,133 :: 		}
L_RF_READY54:
;test_2_rx.c,134 :: 		if( sta & STATUS_MAX_RT )  //Send fail?
	BTFSS       RF_READY_sta_L0+0, 4 
	GOTO        L_RF_READY56
;test_2_rx.c,136 :: 		RF_FLUSH_TX();  //Flush the TX FIFO
	MOVLW       225
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	CLRF        FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;test_2_rx.c,137 :: 		}
L_RF_READY56:
;test_2_rx.c,139 :: 		RF_CLR_IRQ( sta );  //Clear the IRQ flag
	MOVLW       32
	IORWF       STATUS+0, 0 
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVF        RF_READY_sta_L0+0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;test_2_rx.c,140 :: 		INTCON.GIE = 1;// INTERRUPTS ENABLE
	BSF         INTCON+0, 7 
;test_2_rx.c,141 :: 		}
L_RF_READY53:
;test_2_rx.c,142 :: 		RF_CLR_IRQ( sta );  //Clear the IRQ flag
	MOVLW       32
	IORWF       STATUS+0, 0 
	MOVWF       FARG_SPI_Write_Reg_reg+0 
	MOVF        RF_READY_sta_L0+0, 0 
	MOVWF       FARG_SPI_Write_Reg_value+0 
	CALL        _SPI_Write_Reg+0, 0
;test_2_rx.c,147 :: 		}
	RETURN      0
; end of _RF_READY
