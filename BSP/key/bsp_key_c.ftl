[#ftl]
/*
*		按键FIFO  
*		使用方法：首先调用初始化函数bsp_InitKey()
*		在static uint8_t IsK1Down(void)函数值补全按键按下时高电平还是低电平
*		周期性调用：bsp_KeyScan()扫描按键
*		使用key = bsp_GetKey()获取键值
*		
*		默认键值有keydown  keyup没有KEY_LONG
*		如果要使用长按功能请在初始化函数bsp_InitKeyVar()中
*		修改s_tBtn[i].LongTime 		= 0;
*/
#include "bsp_key.h"


static void bsp_InitKeyVar(void);
static void bsp_DetectKey(uint8_t i);


static KEY_T s_tBtn[KEY_COUNT];
static KEY_FIFO_T s_tKey;							//按键FIFO变量

//按键是否按下
static uint8_t IsK1Down(void) 	
{ 
	if( 0 )
	{
		return 1;
	}
	else
		return 0;
}
static uint8_t IsK2Down(void) 	
{ 
	if(  0 )
	{
		return 1;
	}
	else
		return 0;
}
static uint8_t IsK3Down(void) 	
{ 
		return 0;
}
static uint8_t IsK4Down(void) 	
{ 
		return 0;
}
static uint8_t IsK5Down(void) 	
{ 

	return 0;
}
static uint8_t IsK6Down(void) 	
{
	return 0;
}

/*
*****************************************************************************
*		功能：初始化
*		形参：无
*		返回值：无
****************************************************************************
*/
void bsp_InitKey(void)
{
	bsp_InitKeyVar();
}

/*
********************************************************************************************
*		功能：将1个键值压入FIFO缓冲区，可用于模拟一个按键
*		形参：_KeyCode :按键代码
*		返回值：无
***********************************************************************************************
*/
void bsp_PutKey(uint8_t _KeyCode)
{
	s_tKey.Buf[s_tKey.Write] = _KeyCode;
	if( ++s_tKey.Write >= KEY_FIFO_SIZE)		//写指针满了清零
	{
		s_tKey.Write = 0;
	}
	
}

/*
********************************************************************************************
*		功能：从FIFO缓冲区读取一个键值
*		形参：无
*		返回值：按键代码
***********************************************************************************************
*/
uint8_t bsp_GetKey(void)
{
	uint8_t ret = 0;
	
	//没有按键按下
	if( s_tKey.Read == s_tKey.Write)
	{
		return KEY_NONE;
	}
	else
	{
		//读取
		ret = s_tKey.Buf[s_tKey.Read];
		//是否读到最后一个了 从头开始  指针自加1
		if( ++s_tKey.Read >= KEY_FIFO_SIZE )
		{
			s_tKey.Read = 0;
		}
		return ret;
	}
}


/*
********************************************************************************************
*		功能：从FIFO缓冲区读取一个键值
*		形参：无
*		返回值：按键代码
***********************************************************************************************
*/
uint8_t bsp_GetKey2(void)
{
	uint8_t ret;
	
	if( s_tKey.Read2 == s_tKey.Write)
	{
		return KEY_NONE;
	}
	else
	{
		ret = s_tKey.Buf[s_tKey.Read2];
		if( ++s_tKey.Read2 >= KEY_FIFO_SIZE )
		{
			s_tKey.Read2 = 0;
		}
		return ret;
	}
}

/*
********************************************************************************************
*		功能：从FIFO缓冲区读取一个键值
*		形参：无
*		返回值：按键代码
***********************************************************************************************
*/
uint8_t bsp_GetKeyState(KEY_ID_E _ucKeyID)
{
	return s_tBtn[_ucKeyID].State;
}

/*
********************************************************************************************
*		功能：设置按键参数
*		形参： _ucKeyID :按键ID，从0开始
_LongTime:长按事件时间
_RepeatSpeed:连发速度
*		返回值：无
***********************************************************************************************
*/
void bsp_SetKeyParam(uint8_t _ucKeyID,uint16_t _LongTime,uint8_t _RepeatSpeed)
{
	s_tBtn[_ucKeyID].LongTime 		= _LongTime;
	s_tBtn[_ucKeyID].RepeatSpeed 	= _RepeatSpeed;
	s_tBtn[_ucKeyID].RepeatCount 	= 0;
}

/*
********************************************************************************************
*		功能：清空按键FIFO缓冲区
*		形参：无
*		返回值：无
***********************************************************************************************
*/
void bsp_ClearKey(void)
{
	s_tKey.Read = s_tKey.Write;
}

/*
********************************************************************************************
*		功能：设置按键参数
*		形参： _ucKeyID :按键ID，从0开始
*		返回值：无
***********************************************************************************************
*/
static void bsp_InitKeyVar(void)
{
	uint8_t i;
	//对按键FIFO读写指针清零
	s_tKey.Read 	= 0;
	s_tKey.Write 	= 0;
	s_tKey.Read2 	= 0;
	//给每个按键结构体成员变量赋值			默认不长按  没有重复按键
	for(i = 0; i<KEY_COUNT;i++)
	{
		s_tBtn[i].LongTime 		= 0;
		s_tBtn[i].Count 			= KEY_FILTER_TIME / 2;
		s_tBtn[i].State 			= 0;
		s_tBtn[i].RepeatSpeed = 0;									//
		s_tBtn[i].RepeatCount = 0;									//
	}
	//按键按下函数
	s_tBtn[KID_K1].IsKeyDownFunc 		= IsK1Down;
	s_tBtn[KID_K2].IsKeyDownFunc 		= IsK2Down;
	s_tBtn[KID_K3].IsKeyDownFunc 		= IsK3Down;
	s_tBtn[KID_K4].IsKeyDownFunc 		= IsK4Down;
	s_tBtn[KID_K5].IsKeyDownFunc 		= IsK5Down;
	s_tBtn[KID_K6].IsKeyDownFunc 		= IsK6Down;
}


/*
**************************************************************************
*		功能：检测一个按键，非阻塞状态，必须被周期性的调用  每个按键都能被检测到 然后存入缓冲区
*	  形参：按键结构变量指针  
*		返回值：无
*		
**************************************************************************
*/
static void bsp_DetectKey(uint8_t i)
{
	KEY_T *pBtn;
	//赋值
	pBtn = &s_tBtn[i];
	
	if( pBtn->IsKeyDownFunc() )														//按键按下了
	{
		
		if(  pBtn->Count < KEY_FILTER_TIME )								//从KEY_FILTER_TIME开始计数
		{
			pBtn->Count = KEY_FILTER_TIME;
		}
		else if( pBtn->Count < 2 * KEY_FILTER_TIME )				//开始计数到2*KEY_FILTER_TIME
		{
			pBtn->Count++;
		}
		//确认按下
		else
		{
			if( pBtn->State == 0)															//如果是弹起状态
			{
				pBtn->State = 1;																//状态改为按下
				bsp_PutKey( (uint8_t)( 3 * i + 1 ) );						//将按下的状态存入缓冲
			}
			if( pBtn->LongTime > 0)														//连续按键开启
			{
				if( pBtn->LongCount < pBtn->LongTime )					//开始计数
				{
					if(  ++pBtn->LongCount == pBtn->LongTime )		//达到长按时间 存入缓冲
					{
						bsp_PutKey( (uint8_t)(3 * i + 3));
					}
				}
				else
				{
					if ( pBtn->RepeatSpeed > 0 )									//一直按键则开始直接加法
					{
						if ( ++pBtn->RepeatCount >= pBtn->RepeatSpeed)
						{
							pBtn->RepeatCount = 0;										//清零 重新开始计数
							bsp_PutKey( (uint8_t)(3 * i + 1) );
						}
					}
				}
			}
		}
	}
	//按键弹起状态
	else
	{
		//如果已经计数过  则清零到
		if(pBtn->Count > KEY_FILTER_TIME)
		{
			pBtn->Count = KEY_FILTER_TIME;
		}
		else if( pBtn->Count != 0)
		{
			pBtn->Count--;
		}
		//
		else
		{
			if(pBtn->State == 1)										//之前为按下状态 则转变为弹起状态
			{
				pBtn->State = 0;
				bsp_PutKey( (uint8_t)(3 * i +2) );		//存入缓冲
			}
		}
		//
		pBtn->LongCount 	= 0;						
		pBtn->RepeatCount = 0;
	}
}

/*
**********************************************************
*		功能：扫描所有按键，非阻塞，被周期调用
*		形参：无
*		返回值：无
*********************************************************
*/
void bsp_KeyScan(void)
{
	uint8_t i;
	for(i = 0; i<KEY_COUNT;i++)
	{
		bsp_DetectKey(i);
	}
}



