[#ftl]
#include "bsp_systick.h"

#define USE_TIM2


static volatile uint32_t s_uiDelayCount = 0;
static volatile uint32_t s_ucTimeoutFlag = 0;

//用于软件定时器结构体变量
static SOFT_TMR s_tTmr[TMR_COUNT];

//全局运行时间，单位1ms。最长可以表示24.85天，如果超过必须考虑溢出问题
__IO int32_t g_iRunTime = 0;

static void bsp_SoftTimerDec(SOFT_TMR *_tmr);

static void (*s_TIM_CallBack1)(void);
static void (*s_TIM_CallBack2)(void);
static void (*s_TIM_CallBack3)(void);
static void (*s_TIM_CallBack4)(void);

/*
*		函数名：bsp_InitTimer
*		功能说明：配置systick中断，并初始化软件定时器变量
*		形参：无
*		返回值：无
*/
void bsp_InitTimer(void)
{
	uint8_t i;
	for(i = 0;i < TMR_COUNT;i++)
	{
		s_tTmr[i].Count = 0;
		s_tTmr[i].PreLoad = 0;
		s_tTmr[i].Flag = 0;
		s_tTmr[i].Mode = TMR_ONCE_MODE;		//缺省是1次性工作模式
	}
	
}

/*
*		函数名：bsp_InitTimer
*		功能说明：配置systick中断，并初始化软件定时器变量
*		形参：无
*		返回值：无
*/
extern void bsp_RunPer1ms(void);
extern void bsp_RunPer10ms(void);

void SysTick_ISR(void)
{
	static uint8_t s_count = 0;
	uint8_t i;
	
	//每1ms进来1次
	if(s_uiDelayCount > 0)
	{
		if( --s_uiDelayCount == 0)
		{
			s_ucTimeoutFlag = 0;
		}
	}
	
	//每隔一毫秒，对软件定时器的计数器进行减一操作
	for( i = 0;i < TMR_COUNT; i++)
	{
		bsp_SoftTimerDec(&s_tTmr[i]);
	}
	
	//全局运行时间自加
	g_iRunTime++;
	if( g_iRunTime == 0x7FFFFFFF)
	{
		g_iRunTime = 0;
	}
	
	//每隔一毫秒调用一次
	bsp_RunPer1ms();
	//每隔十毫秒调用一次
	if( ++s_count >= 10 )
	{
		s_count = 0;
		bsp_RunPer10ms();
	}
	
}

/*
*		函数名：bsp_SoftTimerDec
*		功能说明：每隔一毫秒对所有定时器变量-1，必须被SysTick_ISR周期性调用
*		形参：_tmr：定时器变量指针
*		返回值：无
*/
static void bsp_SoftTimerDec(SOFT_TMR *_tmr)
{
	if( _tmr->Count > 0)
	{
		if( --_tmr->Count == 0)
		{
			_tmr->Flag = 1;
			if( _tmr->Mode == TMR_AUTO_MODE )
			{
				_tmr->Count = _tmr->PreLoad;
			}
		}
	}
}


/********************************CopyRight by Mr_Yang****************************************/



/********************************CopyRight by Mr_Yang****************************************/

