[#ftl]

#include "tpic595.h"


void Tpic_595_Init()
{
   TPIC_RCK = 0;
   TPIC_SRCK = 0;
   TPIC_G = 1;
   TPIC_DATA=0;
}

void Tpic_Shifting()
{
	TPIC_SRCK=0;
	HAL_Delay(1); 
	TPIC_SRCK=1;
	HAL_Delay(1);
	TPIC_SRCK=0;
	HAL_Delay(1);
}

void Tpic_Send()
{
	TPIC_RCK=0;
	HAL_Delay(1); 
	TPIC_RCK=1;
	HAL_Delay(1);
	TPIC_RCK=0;
	HAL_Delay(1);
	TPIC_G = 0;
}

void WR_595(char temp)
{ 
	u8 i = 0;
	for(i=0;i<8;i++)
	{ 
		if(temp&0x80)
			TPIC_DATA=1;
		else
			TPIC_DATA=0;
		Tpic_Shifting();
		TPIC_DATA=0;		
		temp<<=1;
	} 
  Tpic_Send();
}


