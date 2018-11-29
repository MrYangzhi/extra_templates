[#ftl]
#ifndef __bsp_systick_H
#define __bsp_systick_H

#include "bitband.h"

#define TMR_COUNT	4		//软件定时器个数

typedef enum{
	TMR_ONCE_MODE = 0,
	TMR_AUTO_MODE = 1,
}TMR_MODE_E;

typedef struct
{
	volatile uint8_t Mode;				//计数器模式
	volatile uint8_t Flag;				//定时到达标志
	volatile uint32_t Count;			//计数器
	volatile uint32_t PreLoad;		//计数器预装值
}SOFT_TMR;

void bsp_InitTimer(void);
void bsp_DelayMS(uint32_t n);
void bsp_DelayUS(uint32_t n);
void bsp_StartTimer(uint8_t id,uint32_t period);
void bsp_StartAutoTimer(uint8_t id,uint32_t period);
void bsp_StopTimer(uint8_t id);
uint8_t bsp_CheckTimer(uint8_t id);
int32_t bsp_GetRunTime(void);
int32_t bsp_CheckRunTime(int32_t lastTime);

void bsp_InitHardTimer(void);
void bsp_StartHardTimer(uint8_t cc,uint32_t timeout,void *pCallBack);

#endif


