[#ftl]

#include "TM1637.h"

/******************************************************************************
						
*******************************************************************************/ 

#define SETBIT(num,n)  num|=(1<<n)
#define CLEARBIT(num,n) num&=~(1<<n)


#define CLK_Pin 	GPIO_Pin_10
#define DIO_Pin 	GPIO_Pin_11


//#define	CLK_H   	{GPIOB->BSRR = CLK_Pin;I2C_delay(4);}	 //SCL�ߵ�ƽ
//#define	CLK_L   	{GPIOB->BRR  = CLK_Pin;I2C_delay(4);}	 //SCL�͵�ƽ
//#define	DIO_H   	{GPIOB->BSRR = DIO_Pin;I2C_delay(4);}	 //SDA�ߵ�ƽ
//#define	DIO_L   	{GPIOB->BRR  = DIO_Pin;I2C_delay(4);}	 //SDA�͵�ƽ
#define	DIO_Read	GPIOB->IDR  & DIO_Pin	 //SDA


/******************************************************************************


*******************************************************************************/ 
void TM1637_Init(void)
{

}

/******************************************************************************

*******************************************************************************/ 
static void delay_140us()
{
	u16	delay = 20;
	while (delay)
			delay--;
}

/******************************************************************** 
* ?? : void TM1637_start( void ) 
* ?? : start?? 
* ?? : void 
* ?? : ? 
**************************************************************/  
void TM1637_start( void )  
{  
    CLK = 1;  
    DIO = 1;  
    delay_140us();  
    DIO = 0;  
    delay_140us();  
    CLK = 0;  
    delay_140us();  
} 

  
/******************************************************************** 
* ?? : void TM1637_stop( void ) 
* ?? : stop?? 
* ?? : void 
* ?? : ? 
**************************************************************/  
void TM1637_stop( void )  
{  
    CLK = 0;  
    delay_140us();  
    DIO = 0;  
    delay_140us();  
    CLK = 1;  
    delay_140us();  
    DIO = 1;  
    delay_140us();  
}  
  
  
/******************************************************************** 
* ?? : void TM1637_write1Bit(unsigned char mBit ) 
* ?? : ?1bit 
* ?? : unsigned char mBit 
* ?? : ? 
**************************************************************/  
void TM1637_write1Bit(unsigned char mBit )  
{  
    CLK = 0;  
    delay_140us();  
    if(mBit)  
        DIO = 1;  
    else  
        DIO = 0;  
    delay_140us();    
    CLK = 1;  
    delay_140us();  
}  
  
/******************************************************************** 
* ?? : void TM1637_write1Byte(unsigned char mByte) 
* ?? : ?1byte 
* ?? : unsigned char mByte 
* ?? : ? 
**************************************************************/  
void TM1637_write1Byte(unsigned char mByte)  
{  
    char loop = 0;  
    for(loop = 0; loop < 8; loop++)  
    {  
        TM1637_write1Bit((mByte>>loop)&0x01); //ȡ�����λ
    }  
    CLK = 0;  
    delay_140us();  
    DIO = 1;  
    delay_140us();  
    CLK = 1;  
    delay_140us();  
    while( (DIO_Read) == 1);  //���Ӧ�� 
} 

void TM1637_writeCammand(unsigned char mData)  
{  
    TM1637_start();  
    TM1637_write1Byte(mData);  //??  
    TM1637_stop();    
}  

/******************************************************************** 
* ?? : void TM1637_writeData(unsigned char addr, unsigned char mData) 
* ?? : ???????1byte 
* ?? : unsigned char addr, unsigned char mData 
* ?? : ? 
**************************************************************/  
void TM1637_writeData(unsigned char addr, unsigned char mData)  
{  
    TM1637_start();  
    TM1637_write1Byte(addr);  //??  
    TM1637_write1Byte(mData);  //??  
    TM1637_stop();    
} 

/******************************************************************** 
* void time_display( void ) 
* num:Ҫ��ʾ������
* flag:����λ 	0��PM2.5			1��CO2
*	speed:���ٵȼ�  0~6
* 
**************************************************************/  
void time_display(u32 num,u8 flag,u8 speed)  
{  
	
	//�����ݽ��зֽ�
	u8 qian,bai,shi,ge;
	u8 seg6 = 0;											//����������ܵ�����  ��Ӧflag��speed
	qian = num/1000;
	bai = (num-qian*1000)/100;
	shi = (num-qian*1000-bai*100)/10;
	ge = num%10;
	//�����Ϊ���д���
	if( qian == 0 )
	{
		qian = 10;				//���λΪ0����ʾ
		if(bai == 0)
		{
				bai =10;			//ǧλ��λΪ0����ʾ
				if( shi == 0)
					shi = 10;
		}
	}
	
	//��PM2.5��CO2ָʾ��  ���з��ٵȼ�����  �������ݺϳ�һ��
	if(flag == 0)							//0��PM25
	{
		SETBIT(seg6,PM25);
		CLEARBIT(seg6,CO2);
	}
	else if( flag == 2)				//2��CO2
	{
		CLEARBIT(seg6,PM25);
		SETBIT(seg6,CO2);
	}
	if(speed == 6)
	{
		SETBIT(seg6,5);
		SETBIT(seg6,4);
		SETBIT(seg6,3);
		SETBIT(seg6,2);
		SETBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 5)
	{
		CLEARBIT(seg6,5);
		SETBIT(seg6,4);
		SETBIT(seg6,3);
		SETBIT(seg6,2);
		SETBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 4)
	{
		CLEARBIT(seg6,5);
		CLEARBIT(seg6,4);
		SETBIT(seg6,3);
		SETBIT(seg6,2);
		SETBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 3)
	{
		CLEARBIT(seg6,5);
		CLEARBIT(seg6,4);
		CLEARBIT(seg6,3);
		SETBIT(seg6,2);
		SETBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 2)
	{
		CLEARBIT(seg6,5);
		CLEARBIT(seg6,4);
		CLEARBIT(seg6,3);
		CLEARBIT(seg6,2);
		SETBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 1)
	{
		CLEARBIT(seg6,5);
		CLEARBIT(seg6,4);
		CLEARBIT(seg6,3);
		CLEARBIT(seg6,2);
		CLEARBIT(seg6,1);
		SETBIT(seg6,0);
	}
	else if(speed == 0)
	{
		CLEARBIT(seg6,5);
		CLEARBIT(seg6,4);
		CLEARBIT(seg6,3);
		CLEARBIT(seg6,2);
		CLEARBIT(seg6,1);
		CLEARBIT(seg6,0);
	}	
	TM1637_writeCammand(0x44);  			//
	TM1637_writeData(0xc0,SEGData[qian]);  	//1 
	TM1637_writeData(0xc1,SEGData[bai]);  
	TM1637_writeData(0xc2,SEGData[shi]);  
	TM1637_writeData(0xc3,SEGData[ge]);  
	TM1637_writeData(0xc4,0x00);  			//
	TM1637_writeData(0xc5,seg6);  			//
	
	TM1637_writeCammand(0x8C);  			//  
}  
