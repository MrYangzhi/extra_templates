[#ftl]


#ifndef __MPUIIC_H
#define __MPUIIC_H

#include "bitband.h"


#define MPU_SDA_IN()  {GPIOB->CRH&=0XFFFF0FFF;GPIOB->CRH|=8<<12;}
#define MPU_SDA_OUT() {GPIOB->CRH&=0XFFFF0FFF;GPIOB->CRH|=3<<12;}

#define MPU_IIC_SCL    PBout(10) 		//SCL
#define MPU_IIC_SDA    PBout(11) 		//SDA	 
#define MPU_READ_SDA   PBin(11) 	    

void MPU_IIC_Delay(void);				          
void MPU_IIC_Init(void);              		 
void MPU_IIC_Start(void);			
void MPU_IIC_Stop(void);	  		
void MPU_IIC_Send_Byte(uint8_t txd);		
uint8_t MPU_IIC_Read_Byte(unsigned char ack);//
uint8_t MPU_IIC_Wait_Ack(void); 			
void MPU_IIC_Ack(void);				
void MPU_IIC_NAck(void);			

void IMPU_IC_Write_One_Byte(uint8_t daddr,uint8_t addr,uint8_t data);
uint8_t MPU_IIC_Read_One_Byte(uint8_t daddr,uint8_t addr);	  


#endif
















