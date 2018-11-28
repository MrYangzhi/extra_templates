[#ftl]
#ifndef __bsp_usart_H
#define __bsp_usart_H


#include "bitband.h"
#include "usart.h"
#include <stdarg.h>

//printf_uart
#define PRINTF_UART     huart1

typedef enum
{
    COM1 = 0;       //USART1 PA9 PA10
    COM2 = 1;       //USART2 PA2 PA3
    COM3 = 2;       //USART3 PB10 PB11
}COM_PORT;

#define USART1_FIFO_EN  0           //used to printf
#define USART2_FIFO_EN  1           //
#define USART3_FIFO_EN  1           //

#if USART1_FIFO_EN == 1
    #define UART1_TX_BUF_SIZE   1*1024
    #define UART1_RX_BUF_SIZE   1*1024
#endif

#if USART2_FIFO_EN == 1
    #define UART2_TX_BUF_SIZE   1*1024
    #define UART2_RX_BUF_SIZE   1*1024
#endif

#if USART3_FIFO_EN == 1
    #define UART3_TX_BUF_SIZE   1*1024
    #define UART3_RX_BUF_SIZE   1*1024
#endif

typedef struct
{
    UART_HandleTypeDef *huart;  //uart handle pointer 

    uint8_t *pTxBuf;            //send buffer
    uint8_t *pRxBuf;            //recive buffer
    uint16_t usTxBufSize;       //send buffer size
    uint16_t usRxBufSize;       //recive buffer size
    uint16_t usTxWrite;         //send buffer write index
    uint16_t usTxRead;          //send buffer write index
    uint16_t usTxCount;         //count wait for sneding

    uint16_t usRxWrite;         //recive buffer write index
    uint16_t usRxRead;          //recive buffer write index
    uint16_t usRxCount;         //count wait for reciving

    void (*SendBefor)(void);    //
    void (*SendOver)(void);     //
    void (*ReciveNew)(void);    //
}USART_T;

void bsp_InitUsart(void);
void comSendBuf(COM_PORT port,uint8_t *buf,uint16_t len);
void comSendChar(COM_PORT port,uint8_t char);
uint8_t comGetChar(COM_PORT port,uint8_t *pChar);

void comClearTxFifo(COM_PORT port,);
void comClearRxFifo(COM_PORT port,);

void debug_printf(char *fmt,...);




#endif
















