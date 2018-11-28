[#ftl]
/*
	pirntf

	usart_fifo

*/
#include "bsp_usart.h"

#if USART1_FIFO_EN == 1
	static USART_T y_USART1;
	static uint8_t y_TxBuf1[USART1_TX_BUF_SIZE];
	static uint8_t y_RxBuf1[USART1_RX_BUF_SIZE];
#endif

#if USART2_FIFO_EN == 1
	static USART_T y_USART2;
	static uint8_t y_TxBuf2[USART2_TX_BUF_SIZE];
	static uint8_t y_RxBuf2[USART2_RX_BUF_SIZE];
#endif

#if USART3_FIFO_EN == 1
	static USART_T y_USART3;
	static uint8_t y_TxBuf3[USART3_TX_BUF_SIZE];
	static uint8_t y_RxBuf3[USART3_RX_BUF_SIZE];
#endif

static void Usart_Var_Init(void);
static void UsartSend(USART_T *pUsart,uint8_t *buf,uint16_t len);
static uint8_t UsartGetChar(USART_T *pUsart,uint8_t *pChar);
static void UsartIRQ(USART_T *pUsart);
static void ConfigUsartNVIC(void);

void bsp_usart(void)
{
	Usart_Var_Init();
	
}

static void Usart_Var_Init(void)
{
#if USART1_FIFO_EN == 1
	
	y_USART1.huart = &huart1;
	y_USART1.pTxBuf = y_TxBuf1;
	y_USART1.pRxBuf = y_RxBuf1;
	y_USART1.usTxBufSize = USART1_TX_BUF_SIZE;
	y_USART1.usRxBufSize = USART1_RX_BUF_SIZE;
	y_USART1.usTxWrite =  0;
	y_USART1.usTxRead = 0;
	y_USART1.usTxCount = 0;
	y_USART1.usRxWrite = 0;
	y_USART1.usRxRead = 0;
	y_USART1.usRxCount = 0;
	y_USART1.SendBefor = 0;
	y_USART1.SendOver = 0;
	y_USART1.ReciveNew = 0;
	
#endif

#if USART2_FIFO_EN == 1
	
	y_USART2.huart = &huart2;
	y_USART2.pTxBuf = y_TxBuf2;
	y_USART2.pRxBuf = y_RxBuf2;
	y_USART2.usTxBufSize = USART2_TX_BUF_SIZE;
	y_USART2.usRxBufSize = USART2_RX_BUF_SIZE;
	y_USART2.usTxWrite =  0;
	y_USART2.usTxRead = 0;
	y_USART2.usTxCount = 0;
	y_USART2.usRxWrite = 0;
	y_USART2.usRxRead = 0;
	y_USART2.usRxCount = 0;
	y_USART2.SendBefor = 0;
	y_USART2.SendOver = 0;
	y_USART2.ReciveNew = 0;

#endif

#if USART3_FIFO_EN == 1
	
	y_USART3.huart = &huart3;
	y_USART3.pTxBuf = y_TxBuf3;
	y_USART3.pRxBuf = y_RxBuf3;
	y_USART3.usTxBufSize = USART3_TX_BUF_SIZE;
	y_USART3.usRxBufSize = USART3_RX_BUF_SIZE;
	y_USART3.usTxWrite =  0;
	y_USART3.usTxRead = 0;
	y_USART3.usTxCount = 0;
	y_USART3.usRxWrite = 0;
	y_USART3.usRxRead = 0;
	y_USART3.usRxCount = 0;
	y_USART3.SendBefor = 0;
	y_USART3.SendOver = 0;
	y_USART3.ReciveNew = 0;

#endif

}

static void UartSend(USART_T *pUsart,uint8_t *buf,uint16_t len)
{
	uint16_t i;
	for(i = 0;i < len;i++)
	{
		while(1)
		{
			__IO uint16_t usCount;
			__disable_irq();
			usCount = pUsart->usTxCount;
			__enable_irq();
			if(usCount < pUsart->usTxBufSize)
			{
				break;
			}
		}
		pUsart->pTxBuf[pUsart->usTxWrite] = buf[i];
		__disable_irq();
		if( ++pUsart->usTxWrite >= pUsart->usTxBufSize )
		{
			pUsart->usTxWrite = 0;
		}
		pUsart->usTxCount++;
		__enable_irq();
	}
	__HAL_UART_ENABLE_IT(pUsart->huart,UART_IT_TXE);
	//HAL_UART_Transmit(
}


#ifdef PRINTF_UART

	#define DEBUG_PRINTF_BUFFER_SIZE	100

	void debug_printf(char *fmt,...)
	{
		char buffer[DEBUG_PRINTF_BUFFER_SIZE];
		uint8_t i = 0;
		va_list arg_ptr;
		va_start(arg_ptr,fmt);
		vsnprintf(buffer,DEBUG_PRINTF_BUFFER_SIZE,fmt,arg_ptr);
		while( i < (DEBUG_PRINTF_BUFFER_SIZE-1) && buffer[i] )
		{
			HAL_UART_Transmit(&PRINTF_UART,(uint8_t *)&buffer[i],1,0xFF);
			i++;
		}
		va_end(arg_ptr);
	}

#endif

