[#ftl]


#include "mpuiic.h"

void MPU_IIC_Delay(void)
{
	uint16_t count = 40;
	while(count-- > 0);
}

void Delay_ms_mpu(uint16_t nms)
{	
	uint16_t i,j;
	for(i=0;i<nms;i++)
		for(j=0;j<8500;j++);
} 

void MPU_IIC_Init(void)
{	
//    GPIO_InitTypeDef GPIO_Initure;
//
//    __HAL_RCC_GPIOB_CLK_ENABLE();         
//	
//    GPIO_Initure.Pin=GPIO_PIN_10|GPIO_PIN_11; 
//    GPIO_Initure.Mode=GPIO_MODE_OUTPUT_PP;  
//    GPIO_Initure.Pull=GPIO_PULLUP;         
//    GPIO_Initure.Speed=GPIO_SPEED_FREQ_HIGH;    	 
//    HAL_GPIO_Init(GPIOB,&GPIO_Initure);
	MPU_IIC_SCL=1;
	MPU_IIC_SDA=1;
}
void MPU_IIC_Start(void)
{
	MPU_SDA_OUT();     
	MPU_IIC_SDA=1;	  	  
	MPU_IIC_SCL=1;
	MPU_IIC_Delay();
 	MPU_IIC_SDA=0;						//START:when CLK is high,DATA change form high to low 
	MPU_IIC_Delay();
	MPU_IIC_SCL=0;//
}	  

void MPU_IIC_Stop(void)
{
	MPU_SDA_OUT();//sda
	MPU_IIC_SCL=0;
	MPU_IIC_SDA=0;						//STOP:when CLK is high DATA change form low to high
 	MPU_IIC_Delay();
	MPU_IIC_SCL=1; 
	MPU_IIC_SDA=1;//
	MPU_IIC_Delay();							   	
}


uint8_t MPU_IIC_Wait_Ack(void)
{
	uint8_t ucErrTime=0;
	MPU_SDA_IN();    		  			//SDA
	MPU_IIC_SDA=1;MPU_IIC_Delay();	   
	MPU_IIC_SCL=1;MPU_IIC_Delay();	 
	while(MPU_READ_SDA)
	{
		ucErrTime++;
		if(ucErrTime>250)
		{
			MPU_IIC_Stop();
			return 1;
		}
	}
	MPU_IIC_SCL=0;   
	return 0;  
} 

void MPU_IIC_Ack(void)
{
	MPU_IIC_SCL=0;
	MPU_SDA_OUT();
	MPU_IIC_SDA=0;
	MPU_IIC_Delay();
	MPU_IIC_SCL=1;
	MPU_IIC_Delay();
	MPU_IIC_SCL=0;
}

void MPU_IIC_NAck(void)
{
	MPU_IIC_SCL=0;
	MPU_SDA_OUT();
	MPU_IIC_SDA=1;
	MPU_IIC_Delay();
	MPU_IIC_SCL=1;
	MPU_IIC_Delay();
	MPU_IIC_SCL=0;
}					 				     

	  
void MPU_IIC_Send_Byte(uint8_t txd)
{                        
    uint8_t t;   
	MPU_SDA_OUT(); 	    
    MPU_IIC_SCL=0;
    for(t=0;t<8;t++)
    {              
        MPU_IIC_SDA=(txd&0x80)>>7;
        txd<<=1; 	  
		    MPU_IIC_SCL=1;
		    MPU_IIC_Delay(); 
		    MPU_IIC_SCL=0;	
		    MPU_IIC_Delay();
    }	 
} 	    

uint8_t MPU_IIC_Read_Byte(unsigned char ack)
{
	unsigned char i,receive=0;
	MPU_SDA_IN();
    for(i=0;i<8;i++ )
	{
        MPU_IIC_SCL=0; 
        MPU_IIC_Delay();
		MPU_IIC_SCL=1;
        receive<<=1;
        if(MPU_READ_SDA)receive++;   
		MPU_IIC_Delay(); 
    }					 
    if (!ack)
        MPU_IIC_NAck();
    else
        MPU_IIC_Ack();
    return receive;
}


























