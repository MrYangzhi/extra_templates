[#ftl]/*
*	默认使用printf方便
*	发送接收都使用中断的方式 
*	发送时：把数据填入DR然后开启中断  中断中判断是否还有数据需要发送有就填入DR启动中断这样发送是不阻塞的
*	Cube生成工程的时候不生成IRQ中断函数 由自己实现中断函数
*	
*
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

static void Usart_Var_Init(void);																		//全局变量值初始化函数
static void InitHardUsart(void);																		//硬件初始化
static void UsartSend(USART_T *pUsart,uint8_t *buf,uint16_t len);		//发送字符串
static uint8_t UsartGetChar(USART_T *pUsart,uint8_t *pChar);				//获取1个字节
static void UsartIRQ(USART_T *pUsart);															//中断函数 供每个中断调用

/*
*			函数名：bsp_InitUsart
*			功能说明：初始化函数，主要是全局变量
*			形参：无
*			返回值：无
*/
void bsp_InitUsart(void)
{
	Usart_Var_Init();			//初始化全局变量
	InitHardUsart();			//暂时没有任何内容
}

/*
*			函数名：ComToUsart
*			功能说明：将COM端口转化为hsuart_t指针
*			形参：port（端口号）
*			返回值：hsuart_t 指针
*/
USART_T* ComToUsart(COM_PORT port)
{
	if( port == COM1 )
	{
		#if USART1_FIFO_EN == 1
			return &y_USART1;
		#else
			return 0;
		#endif
	}
	else if( port == COM2 )
	{
		#if USART2_FIFO_EN == 1
			return &y_USART2;
		#else
			return 0;
		#endif
	}
	else if( port == COM3 )
	{
		#if USART3_FIFO_EN == 1
			return &y_USART3;
		#else
			return 0;
		#endif
	}
	else
	{
		return 0;
	}
}

/*
*			函数名：comSendBuf
*			功能说明：向串口发送一组数据，数据放到发送缓冲区后立即返回，由中断服务程序在后台完成发送
*			形参：port（COM~COM3）
*						buf:数据缓冲区
*						len：数据长度
*			返回值：无
*/
void comSendBuf(COM_PORT port,uint8_t *buf,uint16_t len)
{
	USART_T *pUsart;
	pUsart = ComToUsart(port);
	if( pUsart == 0)
	{
		return ;
	}
	if( pUsart->SendBefor != 0 )		//RS485通信才使用
	{
		pUsart->SendBefor();
	}
	UsartSend(pUsart,buf,len);			//调用发送函数
}


/*
*		函数名：comSendChar
*		功能说明：向串口发送1个字节，数据放到发送缓冲区后立即返回，由中断服务程序在后台完成发送
*		形参：port:端口号（COM1~COM3）
*		返回值：无
*/
void comSendChar(COM_PORT port,uint8_t ch)
{
	comSendBuf(port,&ch,1);
}

/*
*		函数名：comSendChar
*		功能说明：向串口发送1个字节，数据放到发送缓冲区后立即返回，由中断服务程序在后台完成发送
*		形参：port:端口号（COM1~COM3）
*		返回值：无
*/
uint8_t comGetChar(COM_PORT port,uint8_t *ch)
{
	USART_T *pUsart;
	pUsart = ComToUsart(port);
	if(pUsart == 0)
	{
		return 0;
	}
	return UsartGetChar(pUsart,ch);
}

/*
*			函数名：comClearTxFifo
*			功能说明：清零串口发送缓冲区
*			形参：port
*			返回值：无
*/
void comClearTxFifo(COM_PORT port)
{
	USART_T *pUsart;
	
	pUsart = ComToUsart(port);
	if(pUsart == 0)
	{
		return ;
	}
	pUsart->usTxWrite = 0;
	pUsart->usTxRead = 0;
	pUsart->usTxRead = 0;
}


/*
*			函数名：comClearRxFifo
*			功能说明：清零串口接收缓冲区
*			形参：port
*			返回值：无
*/
void comClearRxFifo(COM_PORT port)
{
	USART_T *pUsart;
	
	pUsart = ComToUsart(port);
	if(pUsart == 0)
	{
		return ;
	}
	pUsart->usRxWrite = 0;
	pUsart->usRxRead = 0;
	pUsart->usRxRead = 0;
}

/*
*			函数名：Usart_Var_Init
*			功能说明：初始化串口相关变量
*			形参：无
*			返回值：无
*/
static void Usart_Var_Init(void)
{
#if USART1_FIFO_EN == 1
	
	y_USART1.huart = &huart1;												//串口handle
	y_USART1.pTxBuf = y_TxBuf1;											//发送缓冲区指针
	y_USART1.pRxBuf = y_RxBuf1;											//接收缓冲区指针
	y_USART1.usTxBufSize = USART1_TX_BUF_SIZE;			//发送缓冲区大小
	y_USART1.usRxBufSize = USART1_RX_BUF_SIZE;			//接收缓冲区大小
	y_USART1.usTxWrite =  0;												//发送FIFO写索引
	y_USART1.usTxRead = 0;													//发送FIFO读索引
	y_USART1.usTxCount = 0;													//待发送数据个数
	y_USART1.usRxWrite = 0;													//接收FIFO写索引
	y_USART1.usRxRead = 0;													//接收FIFO读索引
	y_USART1.usRxCount = 0;													//接收到的新数据个数
	y_USART1.SendBefor = 0;													//发送数据前的回调函数 RS485使用
	y_USART1.SendOver = 0;													//发送完毕后的回调函数 RS485使用
	y_USART1.ReciveNew = 0;													//接收到新数据后的回调函数
	
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

/*
*			函数名：InitHardUsart
*			功能说明： 硬件初始化由CubeMX完成
*			形参：无
*			返回值：无
*/
static void InitHardUsart(void)
{
	
	
}

/*
*			函数名：UsartSend
*			功能说明：：填写数据到USART发送缓冲区，并启动发送中断。中断处理函数发送完毕后，自动关闭发送中断
*			形参：
*			返回值：无
*/
static void UsartSend(USART_T *pUsart,uint8_t *buf,uint16_t len)
{
	uint16_t i;
	//将len个数据填入缓冲区
	for(i = 0;i < len;i++)
	{
		while(1)
		{
			__IO uint16_t usCount;
			__disable_irq();
			usCount = pUsart->usTxCount;
			__enable_irq();
			//数据量过大则死机
			if(usCount < pUsart->usTxBufSize)
			{
				break;
			}
		}
		//将数据填入发送缓冲区
		pUsart->pTxBuf[pUsart->usTxWrite] = buf[i];
		__disable_irq();
		//超出bufsize则清零
		if( ++pUsart->usTxWrite >= pUsart->usTxBufSize )
		{
			pUsart->usTxWrite = 0;
		}
		//要发送的个数计数量自加
		pUsart->usTxCount++;
		__enable_irq();
	}
	//填入缓冲区完成则开启中断
	__HAL_UART_ENABLE_IT(pUsart->huart,UART_IT_TXE);
}

/*
*			函数名：UsartGetChar
*			功能说明：从串口接收缓冲区读取1字节数据（用于主程序调用）
*			形参：port
*						pChar:存放读取数据的指针
*			返回值：0：表示没有数据
*							1：表示读取到数据
*/
static uint8_t UsartGetChar(USART_T *pUsart,uint8_t *pChar)
{
	uint16_t usCount;
	__disable_irq();
	usCount = pUsart->usRxCount;
	__enable_irq();
	
	//如果读和写索引相同，则返回0
	//if( pUsart->usRxRead == pUsart->usRxWrite)
	if( usCount == 0)	//没有数据
	{
		return 0;
	}
	else
	{
		*pChar = pUsart->pRxBuf[pUsart->usRxRead];		//从串口接收FIFO取1个数据
		//改写FIFO读索引
		__disable_irq();
		if( ++pUsart->usRxRead >= pUsart->usRxBufSize )
		{
			pUsart->usRxRead = 0;
		}
		pUsart->usRxCount--;
		__enable_irq();
		return 1;
	}
}

/*
*		供中断服务程序调用，通用串口中断处理函数
*
*
*/
static void UsartIRQ(USART_T *pUsart)
{
	//处理接收中断
	if(__HAL_UART_GET_IT_SOURCE(pUsart->huart,UART_IT_RXNE) != RESET)
	{
		//从串口接收数据存放到FIFO
		uint8_t ch;
		ch = (uint16_t)(pUsart->huart->Instance->DR & (uint16_t)0x00FF);
		pUsart->pRxBuf[pUsart->usRxWrite] = ch;
		if( ++pUsart->usRxWrite >= pUsart->usRxBufSize )										//
		{
			pUsart->usRxWrite = 0;
		}
		if( pUsart->usRxCount < pUsart->usRxBufSize)
		{
			pUsart->usRxCount++;
		}
		//RS485使用
		if(pUsart->ReciveNew)
		{
			pUsart->ReciveNew(ch);
		}
	}
	//处理发送缓冲区空中断
	if(__HAL_UART_GET_IT_SOURCE(pUsart->huart,UART_IT_TXE) != RESET)
	{
		if(pUsart->usTxCount == 0)
		{
			//发送缓冲区数据已取完时，禁止发送缓冲区空中断  attention：此时最后1个数据还没有真正完成发送
			__HAL_UART_DISABLE_IT(pUsart->huart,UART_IT_TXE);
			//使能数据发送完毕中断
			__HAL_UART_ENABLE_IT(pUsart->huart,UART_IT_TC);
		}
		else
		{
			//从发送FIFO去一个字节写入串口发送数据寄存器
			pUsart->huart->Instance->DR = (pUsart->pTxBuf[pUsart->usTxRead] & (uint16_t)0x01FF);
			if(++pUsart->usTxRead >= pUsart->usTxBufSize)
			{
				pUsart->usTxRead = 0;
			}
			pUsart->usTxCount--;
		}
	}
	//数据全部发送完毕中断
	else if( __HAL_UART_GET_IT_SOURCE(pUsart->huart,UART_IT_TC) != RESET )
	{
		if( pUsart->usTxCount == 0 )
		{
			//发送缓冲区数据已取完时，禁止数据发送完毕中断
			__HAL_UART_DISABLE_IT(pUsart->huart,UART_IT_TC);
			if( pUsart->SendOver)
			{
				pUsart->SendOver();
			}
		}
		else	//正常情况下不会进入此分支
		{
			//如果发送FIFO的数据还没有完毕，则从发送FIFO取1个数据写入发送数据寄存器
			pUsart->huart->Instance->DR = (pUsart->pTxBuf[pUsart->usTxRead] & (uint16_t)0x01FF);
			if(++pUsart->usTxRead >= pUsart->usTxBufSize)
			{
				pUsart->usTxRead = 0;
			}
			pUsart->usTxCount--;
		}
	}
}

/*
*			函数名：USART1_IRQHandler
*			功能说明：USART中断服务程序
*			形参：无
*			返回值：无
*/
#if USART1_FIFO_EN == 1
void USART1_IRQHandler(void)
{
	UsartIRQ(&y_USART1);
}
#endif

#if USART2_FIFO_EN == 1
void USART2_IRQHandler(void)
{
	UsartIRQ(&y_USART2);
}
#endif

#if USART3_FIFO_EN == 1
void USART3_IRQHandler(void)
{
	UsartIRQ(&y_USART3);
}
#endif

/*
*			函数名：fputc
*			功能说明：重定义putc函数，可以使用printf函数从串口1打印输出
*			形参：无
*			返回值：无
*/
int fputc(int ch,FILE *f)
{
	#if 1
	comSendChar(COM1,ch);
	return ch;
	#endif
}

/*
*
*
*
*/
int fgetc(FILE *f)
{
	#if 1		//从串口接收FIFO读取1个数据，只有取到数据才返回
	uint8_t ch;
	while(comGetChar(COM1,&ch) == 0);
	return ch;
	#endif
}

void PrintfLOGO(void)
{
	//检测CPUID
	{
		uint32_t CPU_Sn0, CPU_Sn1, CPU_Sn2;

		CPU_Sn0 = *(__IO uint32_t*)(0x1FFF7A10);
		CPU_Sn1 = *(__IO uint32_t*)(0x1FFF7A10 + 4);
		CPU_Sn2 = *(__IO uint32_t*)(0x1FFF7A10 + 8);
		printf("\r\n UID = %08x	%08X	%08X\r\n",CPU_Sn2,CPU_Sn1,CPU_Sn0);
	}
	printf("\r\n");
	printf("*	发布日期	：2018-11-29");
	
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

/********************************CopyRight by Mr_Yang****************************************/

