[#ftl]

#include "mpu6050.h"
#include "mpuiic.h"

/*
*	init mpu6050
*	return:			0:success  
*					1:failed
**/

uint8_t MPU_Init(void)
{ 
	uint8_t res;

	MPU_IIC_Init();											//init iic bus 
	MPU_Write_Byte(MPU_PWR_MGMT1_REG,0X80);					//reset MPU6050
	HAL_Delay(100);
	MPU_Write_Byte(MPU_PWR_MGMT1_REG,0X00);					//wake up MPU6050 
	MPU_Set_Gyro_Fsr(MPU6050_GYRO_FS_250);					//gryo 250dps
	MPU_Set_Accel_Fsr(MPU6050_ACCEL_FS_16);					//accel 16g
	MPU_Set_Rate(0);										//rate :1000/(1+0)=1000
	MPU_Write_Byte(MPU_INT_EN_REG,0X00);					//close all interrupt
	MPU_Write_Byte(MPU_USER_CTRL_REG,0X00);					//close I2C master mode 
	MPU_Write_Byte(MPU_FIFO_EN_REG,0X00);					//close FIFO
	MPU_Write_Byte(MPU_INTBP_CFG_REG,0X80);					//INT low 
	res=MPU_Read_Byte(MPU_DEVICE_ID_REG);					//mpu6050 address		
	if(res==MPU_ADDR)										//ID Right
	{
		MPU_Write_Byte(MPU_PWR_MGMT1_REG,0X01);				//
		MPU_Write_Byte(MPU_PWR_MGMT2_REG,0X00);				//both accel and gyro work
		MPU_Set_Rate(0);									//set rate to 1000Hz
 	}
	else 
		 return 1;											//init failed
	return 0;												//init success
}

/*
*	fsr:0,250dps;1,500dps;2,1000dps;3,2000dps
*	return:		0:set success
*				1:set failed
*/
uint8_t MPU_Set_Gyro_Fsr(uint8_t fsr)
{
	return MPU_Write_Byte(MPU_GYRO_CFG_REG,fsr<<3);
}

/*
*	fsr:0,2g;1,4g;2,8g;3,16g
*	return:	0:success
*			1:failed
*/
uint8_t MPU_Set_Accel_Fsr(uint8_t fsr)
{
	return MPU_Write_Byte(MPU_ACCEL_CFG_REG,fsr<<3);
}

/*
*
*	lpf:hz
*
*/
uint8_t MPU_Set_LPF(uint16_t lpf)
{
	uint8_t data=0;
	if(lpf>=188)data=1;
	else if(lpf>=98)data=2;
	else if(lpf>=42)data=3;
	else if(lpf>=20)data=4;
	else if(lpf>=10)data=5;
	else data=6; 
	return MPU_Write_Byte(MPU_CFG_REG,data);
}
/*
*	set MPU6050 rate(in Fs=1KHz)
*	rate:4~1000(Hz)
*	return:	0:
*			1:
*/
uint8_t MPU_Set_Rate(uint16_t rate)
{
	uint8_t data;
	if(rate>1000)rate=1000;
	if(rate<4)rate=4;
	data=1000/rate-1;
	data=MPU_Write_Byte(MPU_SAMPLE_RATE_REG,data);	//
 	return MPU_Set_LPF(rate/2);						//
}

/*
*	get temperature
*	attention:        temp * 100 
*/
short MPU_Get_Temperature(void)
{
    uint8_t buf[2]; 
    short raw;
	float temp;
	MPU_Read_Len(MPU_ADDR,MPU_TEMP_OUTH_REG,2,buf); 
    raw=((uint16_t)buf[0]<<8)|buf[1];  
    temp=36.53+((double)raw)/340;  
    return temp*100;;
}

/*
*	get gyro
*	return:	0:
*			1:
*/
uint8_t MPU_Get_Gyroscope(short *gx,short *gy,short *gz)
{
  uint8_t buf[6],res;  
	res=MPU_Read_Len(MPU_ADDR,MPU_GYRO_XOUTH_REG,6,buf);
	if(res==0)
	{
		*gx=((uint16_t)buf[0]<<8)|buf[1];  
		*gy=((uint16_t)buf[2]<<8)|buf[3];  
		*gz=((uint16_t)buf[4]<<8)|buf[5];
	} 	
    return res;;
}

/*
*	get accel
*	return:	0:
*			1:
*/
uint8_t MPU_Get_Accelerometer(short *ax,short *ay,short *az)
{
    uint8_t buf[6],res;  
	res=MPU_Read_Len(MPU_ADDR,MPU_ACCEL_XOUTH_REG,6,buf);
	if(res==0)
	{
		*ax=((uint16_t)buf[0]<<8)|buf[1];  
		*ay=((uint16_t)buf[2]<<8)|buf[3];  
		*az=((uint16_t)buf[4]<<8)|buf[5];
	} 	
    return res;;
}

/*
*	write len data to reg
*	addr:	Device address
*	reg:	regester address
*	led:	data len
*	buf:	data pointer
*	return:	0:
*			1:
*/
uint8_t MPU_Write_Len(uint8_t addr,uint8_t reg,uint8_t len,uint8_t *buf)
{
	uint8_t i; 
    MPU_IIC_Start(); 
	MPU_IIC_Send_Byte((addr<<1)|0);			//device address + 0(wirte command)
	if(MPU_IIC_Wait_Ack())					//wait for ack
	{
		MPU_IIC_Stop();		 
		return 1;		
	}
    MPU_IIC_Send_Byte(reg);					//wirte regester address
    MPU_IIC_Wait_Ack();						//wait for ack
	for(i=0;i<len;i++)
	{
		MPU_IIC_Send_Byte(buf[i]);			//write data 
		if(MPU_IIC_Wait_Ack())				//wait for ack
		{
			MPU_IIC_Stop();	 
			return 1;		 
		}		
	}    
    MPU_IIC_Stop();	 
	return 0;	
} 

/*
*	read len data to buf
*	addr:	Device address
*	reg:	regester address
*	led:	data len
*	buf:	data pointer
*	return:	0:
*			1:
*/
uint8_t MPU_Read_Len(uint8_t addr,uint8_t reg,uint8_t len,uint8_t *buf)
{ 
 	MPU_IIC_Start(); 
	MPU_IIC_Send_Byte((addr<<1)|0);			//device address + 0(write command)
	if(MPU_IIC_Wait_Ack())					
	{
		MPU_IIC_Stop();		 
		return 1;		
	}
    MPU_IIC_Send_Byte(reg);					//regester address
    MPU_IIC_Wait_Ack();						//wait for ack
    MPU_IIC_Start();
	MPU_IIC_Send_Byte((addr<<1)|1);			//device address + 1(read command)
    MPU_IIC_Wait_Ack();							
	while(len)
	{
		if(len==1)
			*buf=MPU_IIC_Read_Byte(0);//read data send nACK 
		else 
			*buf=MPU_IIC_Read_Byte(1);		//read data send ACK  
		len--;
		buf++; 
	}    
    MPU_IIC_Stop();	
	return 0;	
}

/*
*	iic wirte one byte
*	reg:regester address
*	data:data to write
*/
uint8_t MPU_Write_Byte(uint8_t reg,uint8_t data) 				 
{ 
  	MPU_IIC_Start(); 
	MPU_IIC_Send_Byte((MPU_ADDR<<1)|0);		//device address + 0(write command)
	if(MPU_IIC_Wait_Ack())	
	{
		MPU_IIC_Stop();		 
		return 1;		
	}
	MPU_IIC_Send_Byte(reg);					//write regester address
	MPU_IIC_Wait_Ack();		
	MPU_IIC_Send_Byte(data);				//write data
	if(MPU_IIC_Wait_Ack())	
	{
		MPU_IIC_Stop();	 
		return 1;		 
	}		 
    MPU_IIC_Stop();	 
	return 0;
}

/*
*	iic read one byte
*	reg:regester address
*	return: data 
*/
uint8_t MPU_Read_Byte(uint8_t reg)
{
	uint8_t res;
    MPU_IIC_Start(); 
	MPU_IIC_Send_Byte((MPU_ADDR<<1)|0);		//device address + 0(write command)
	MPU_IIC_Wait_Ack();	
    MPU_IIC_Send_Byte(reg);					//write regester address
    MPU_IIC_Wait_Ack();		
    MPU_IIC_Start();
	MPU_IIC_Send_Byte((MPU_ADDR<<1)|1);		//device address + 1(read command)
    MPU_IIC_Wait_Ack();	
	res=MPU_IIC_Read_Byte(0);				//read data send nACK
    MPU_IIC_Stop();		
	return res;		
}


