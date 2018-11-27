[#ftl]


#ifndef _tpic595_H
#define _tpic595_H

#include "bitband.h"

#define TPIC_G     PBout(8)
#define TPIC_RCK   PBout(9)
#define TPIC_DATA  PBout(10)
#define TPIC_SRCK  PBout(11)



void Tpic_595_Init(void);
void Tpic_Shifting(void);
void Tpic_Send(void);

void WR_595(char temp);


#endif


