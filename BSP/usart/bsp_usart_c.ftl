[#ftl]
/*
	pirntf

	usart_fifo

*/
#include "bsp_usart.h"

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




