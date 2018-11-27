[#ftl]
/**
 * @brief  some defines
 *
 * @param  None
 * @retval None
 */
 
#ifndef _bitband_H
#define _bitband_H


#include "main.h"


//
typedef int32_t  s32;
typedef int16_t s16;
typedef int8_t  s8;

typedef const int32_t sc32;  
typedef const int16_t sc16;  
typedef const int8_t sc8;  

typedef __IO int32_t  vs32;
typedef __IO int16_t  vs16;
typedef __IO int8_t   vs8;

typedef __I int32_t vsc32;  
typedef __I int16_t vsc16; 
typedef __I int8_t vsc8;   

typedef uint32_t  u32;
typedef uint16_t u16;
typedef uint8_t  u8;

typedef const uint32_t uc32;  
typedef const uint16_t uc16;  
typedef const uint8_t uc8; 

typedef __IO uint32_t  vu32;
typedef __IO uint16_t vu16;
typedef __IO uint8_t  vu8;

typedef __I uint32_t vuc32;  
typedef __I uint16_t vuc16; 
typedef __I uint8_t vuc8;  																    


#define SETBIT(x,y)				x|=(1<<y)			
#define CLEARBIT(x,y)			x&=~(1<<y


#ifdef __STM32F4xx_HAL_H

//like 51 GPIO
//register address different from M3
#define BITBAND(addr, bitnum) ((addr & 0xF0000000)+0x2000000+((addr &0xFFFFF)<<5)+(bitnum<<2)) 
#define MEM_ADDR(addr)  *((volatile unsigned long  *)(addr)) 
#define BIT_ADDR(addr, bitnum)   MEM_ADDR(BITBAND(addr, bitnum)) 
//IO address
#define GPIOA_ODR_Addr    (GPIOA_BASE+20) //0x40020014
#define GPIOB_ODR_Addr    (GPIOB_BASE+20) //0x40020414 
#define GPIOC_ODR_Addr    (GPIOC_BASE+20) //0x40020814 
#define GPIOD_ODR_Addr    (GPIOD_BASE+20) //0x40020C14 
#define GPIOE_ODR_Addr    (GPIOE_BASE+20) //0x40021014 
#define GPIOF_ODR_Addr    (GPIOF_BASE+20) //0x40021414    
#define GPIOG_ODR_Addr    (GPIOG_BASE+20) //0x40021814   
#define GPIOH_ODR_Addr    (GPIOH_BASE+20) //0x40021C14    
#define GPIOI_ODR_Addr    (GPIOI_BASE+20) //0x40022014 
#define GPIOJ_ODR_ADDr    (GPIOJ_BASE+20) //0x40022414
#define GPIOK_ODR_ADDr    (GPIOK_BASE+20) //0x40022814

#define GPIOA_IDR_Addr    (GPIOA_BASE+16) //0x40020010 
#define GPIOB_IDR_Addr    (GPIOB_BASE+16) //0x40020410 
#define GPIOC_IDR_Addr    (GPIOC_BASE+16) //0x40020810 
#define GPIOD_IDR_Addr    (GPIOD_BASE+16) //0x40020C10 
#define GPIOE_IDR_Addr    (GPIOE_BASE+16) //0x40021010 
#define GPIOF_IDR_Addr    (GPIOF_BASE+16) //0x40021410 
#define GPIOG_IDR_Addr    (GPIOG_BASE+16) //0x40021810 
#define GPIOH_IDR_Addr    (GPIOH_BASE+16) //0x40021C10 
#define GPIOI_IDR_Addr    (GPIOI_BASE+16) //0x40022010 
#define GPIOJ_IDR_Addr    (GPIOJ_BASE+16) //0x40022410 
#define GPIOK_IDR_Addr    (GPIOK_BASE+16) //0x40022810 

//make sure n < 16
#define PAout(n)   BIT_ADDR(GPIOA_ODR_Addr,n)  //out
#define PAin(n)    BIT_ADDR(GPIOA_IDR_Addr,n)  //in 

#define PBout(n)   BIT_ADDR(GPIOB_ODR_Addr,n)  //out
#define PBin(n)    BIT_ADDR(GPIOB_IDR_Addr,n)  //in 

#define PCout(n)   BIT_ADDR(GPIOC_ODR_Addr,n)  //out
#define PCin(n)    BIT_ADDR(GPIOC_IDR_Addr,n)  //in 

#define PDout(n)   BIT_ADDR(GPIOD_ODR_Addr,n)  //out
#define PDin(n)    BIT_ADDR(GPIOD_IDR_Addr,n)  //in 

#define PEout(n)   BIT_ADDR(GPIOE_ODR_Addr,n)  //out
#define PEin(n)    BIT_ADDR(GPIOE_IDR_Addr,n)  //in

#define PFout(n)   BIT_ADDR(GPIOF_ODR_Addr,n)  //out
#define PFin(n)    BIT_ADDR(GPIOF_IDR_Addr,n)  //in

#define PGout(n)   BIT_ADDR(GPIOG_ODR_Addr,n)  //out
#define PGin(n)    BIT_ADDR(GPIOG_IDR_Addr,n)  //in

#define PHout(n)   BIT_ADDR(GPIOH_ODR_Addr,n)  //out
#define PHin(n)    BIT_ADDR(GPIOH_IDR_Addr,n)  //in

#define PIout(n)   BIT_ADDR(GPIOI_ODR_Addr,n)  //out
#define PIin(n)    BIT_ADDR(GPIOI_IDR_Addr,n)  //in

#define PJout(n)   BIT_ADDR(GPIOJ_ODR_Addr,n)  //out
#define PJin(n)    BIT_ADDR(GPIOJ_IDR_Addr,n)  //in

#define PKout(n)   BIT_ADDR(GPIOK_ODR_Addr,n)  //out
#define PKin(n)    BIT_ADDR(GPIOK_IDR_Addr,n)  //in\

#endif

#ifdef __STM32F1xx_HAL_H
#define BITBAND(addr, bitnum) ((addr & 0xF0000000)+0x2000000+((addr &0xFFFFF)<<5)+(bitnum<<2)) 
#define MEM_ADDR(addr)  *((volatile unsigned long  *)(addr)) 
#define BIT_ADDR(addr, bitnum)   MEM_ADDR(BITBAND(addr, bitnum)) 
//IO口地址映射
#define GPIOA_ODR_Addr    (GPIOA_BASE+12) //0x4001080C 
#define GPIOB_ODR_Addr    (GPIOB_BASE+12) //0x40010C0C 
#define GPIOC_ODR_Addr    (GPIOC_BASE+12) //0x4001100C 
#define GPIOD_ODR_Addr    (GPIOD_BASE+12) //0x4001140C 
#define GPIOE_ODR_Addr    (GPIOE_BASE+12) //0x4001180C 
#define GPIOF_ODR_Addr    (GPIOF_BASE+12) //0x40011A0C    
#define GPIOG_ODR_Addr    (GPIOG_BASE+12) //0x40011E0C    

#define GPIOA_IDR_Addr    (GPIOA_BASE+8) //0x40010808 
#define GPIOB_IDR_Addr    (GPIOB_BASE+8) //0x40010C08 
#define GPIOC_IDR_Addr    (GPIOC_BASE+8) //0x40011008 
#define GPIOD_IDR_Addr    (GPIOD_BASE+8) //0x40011408 
#define GPIOE_IDR_Addr    (GPIOE_BASE+8) //0x40011808 
#define GPIOF_IDR_Addr    (GPIOF_BASE+8) //0x40011A08 
#define GPIOG_IDR_Addr    (GPIOG_BASE+8) //0x40011E08 
 
//make sure n < 16
#define PAout(n)   BIT_ADDR(GPIOA_ODR_Addr,n)  //out 
#define PAin(n)    BIT_ADDR(GPIOA_IDR_Addr,n)  //in 

#define PBout(n)   BIT_ADDR(GPIOB_ODR_Addr,n)  //out 
#define PBin(n)    BIT_ADDR(GPIOB_IDR_Addr,n)  //in 

#define PCout(n)   BIT_ADDR(GPIOC_ODR_Addr,n)  //out 
#define PCin(n)    BIT_ADDR(GPIOC_IDR_Addr,n)  //in 

#define PDout(n)   BIT_ADDR(GPIOD_ODR_Addr,n)  //out 
#define PDin(n)    BIT_ADDR(GPIOD_IDR_Addr,n)  //in 

#define PEout(n)   BIT_ADDR(GPIOE_ODR_Addr,n)  //out 
#define PEin(n)    BIT_ADDR(GPIOE_IDR_Addr,n)  //in

#define PFout(n)   BIT_ADDR(GPIOF_ODR_Addr,n)  //out 
#define PFin(n)    BIT_ADDR(GPIOF_IDR_Addr,n)  //in

#define PGout(n)   BIT_ADDR(GPIOG_ODR_Addr,n)  //out 
#define PGin(n)    BIT_ADDR(GPIOG_IDR_Addr,n)  //in

#endif


#endif
