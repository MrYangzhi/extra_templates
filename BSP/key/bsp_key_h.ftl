[#ftl]
#ifndef __bsp_key_H
#define __bsp_key_H

#ifdef __cplusplus
 extern "C" {
#endif

#include "bitband.h"

#define KEY_COUNT 6				//按键个数   6个独立按键 
typedef enum
{
	KID_K1 = 0,
	KID_K2,
	KID_K3,
	KID_K4,
	KID_K5,
	KID_K6,
	
}KEY_ID_E;

/************************************************************************************************
*
*												按键滤波时间   
*					只有连续检测到KEY_FILTER_TIME状态不变才认为有效， 包括弹起和按下两种事件
*
****************************************************************************************************/

#define KEY_FILTER_TIME 5
#define KEY_LONG_TIME 	5


typedef struct 
{
	//函数指针用于判断按键是否按下
	uint8_t (*IsKeyDownFunc)(void);					//按键按下的判断函数，1表示按下
	
	uint8_t Count;										//滤波器计数器
	uint16_t LongCount;								//长按计数器
	uint16_t LongTime;								//按键按下持续时间，0表示不检测长按
	uint8_t State;										//按键按下持续时间，0表示不检测长按
	uint8_t RepeatSpeed;							//连续按键周期
	uint8_t RepeatCount;							//连续按键计数器	
}KEY_T;

typedef enum
{
	
	KEY_NONE = 0,
	
	KEY_1_DOWN,
	KEY_1_UP,
	KEY_1_LONG,
	
	KEY_2_DOWN,
	KEY_2_UP,
	KEY_2_LONG,
	
	KEY_3_DOWN,
	KEY_3_UP,
	KEY_3_LONG,
	
	KEY_4_DOWN,
	KEY_4_UP,
	KEY_4_LONG,
	
	KEY_5_DOWN,
	KEY_5_UP,
	KEY_5_LONG,
	
	KEY_6_DOWN,
	KEY_6_UP,
	KEY_6_LONG,
	
}KEY_ENUM;

#define KEY_FIFO_SIZE 10

typedef struct
{
	uint8_t Buf[KEY_FIFO_SIZE];							//键值缓冲区
	uint8_t Read;														//缓冲区读指针1
	uint8_t Write;													//缓冲区写指针
	uint8_t Read2;													//缓冲区读指针2
}KEY_FIFO_T;


/* USER CODE END Private defines */


/* USER CODE BEGIN Prototypes */
void bsp_InitKey(void);
void bsp_KeyScan(void);
void bsp_Key_PutKey(uint8_t _KeyCode);
uint8_t bsp_GetKey(void);
uint8_t bsp_GetKey2(void);
uint8_t bsp_GetKeyState(KEY_ID_E _ucKeyID);
void bsp_SetKeyParam(uint8_t _ucKeyID,uint16_t _LongTime,uint8_t _RepeatSpeed);
void bsp_ClearKey(void);



#ifdef __cplusplus
}
#endif

#endif
















