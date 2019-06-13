//+------------------------------------------------------------------+
//|                           Market Sessions Metatrader 4 Indicator |
//|                                  Copyright 2016-2019 Adam Jowett |
//|                                       https://www.100incomes.com |
//+------------------------------------------------------------------+

/*
   ________________________________________________________________________________
   
   NAME: Market Sessions.mq4
   
   AUTHOR: Adam Jowett
   VERSION: 2.1.2
   DATE: 13 June 2019
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT: 
   https://www.100incomes.com/trading/
   ________________________________________________________________________________

   LICENCE:

   adamjowett.com Source Code License Agreement	  
   Copyright (c) 2016 adamjowett.com


   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The Software shall be used for Good, not Evil. If I find anyone decompiling
   this code, or selling it off as their own, they will be slapped in the face with
   a wet fish and released to the hounds.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
   */

#property copyright "Copyright © 2016-2019, Adam Jowett"
#property link      "https://100incomes.com"

#property indicator_chart_window

extern int              gmtServerOffset = 2;
extern bool             showSydney = true;
extern bool             showTokyo = false;
extern bool             showLondon = false;
extern bool             showNewYork = false;
extern bool             showPivot = true;
extern bool             showRandS = true;
extern bool             showOpenPrice = false;
extern bool             showLabels = true;
extern bool             showWeekStart = true;
extern ENUM_TIMEFRAMES  pivotLength = PERIOD_D1;
extern color            pivotColour = RoyalBlue;
extern color            srColour = DimGray;
extern color            openColour = LimeGreen;
extern color            closeColour = Red;
extern color            tokyoColour = DeepSkyBlue;
extern color            sydneyColour = Plum;
extern color            londonColour = Magenta;
extern color            newYorkColour = Gold;
extern color            weekColour = DarkSlateGray;
extern int              sydney = 22;
extern int              tokyo = 0;
extern int              london = 7;
extern int              newyork = 12;
extern int              verticalShift = 0;

string   prefix="market_sessions_";
int      sessionLength,dayLength,lastDayNumber;
double   pivots[7],lastDrawnPivot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   sessionLength=Period()*60 *((60/Period())*9);
   dayLength=Period()*60 *((60/Period())*24);

   if(showSydney)
     {
      sydney=sydney+gmtServerOffset;
      if(sydney > 23) sydney = sydney - 24;
      if(sydney < 0) sydney = sydney + 24;
     }

   if(showTokyo)
     {
      tokyo=tokyo+gmtServerOffset;
      if(tokyo > 23) tokyo = tokyo - 24;
      if(tokyo < 0) tokyo = tokyo + 24;
     }

   if(showLondon)
     {
      london=london+gmtServerOffset;
      if(london > 23) london = london - 24;
      if(london < 0) london = london + 24;
     }

   if(showNewYork)
     {
      newyork=newyork+gmtServerOffset;
      if(newyork > 23) newyork = newyork - 24;
      if(newyork < 0) newyork = newyork + 24;
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   clearScreen(prefix,true,NULL);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars <= 10) return(0);

   int counted=IndicatorCounted();
   if (counted < 0) return(-1);
   if (counted>0) counted--;

   int i=Bars-counted;
   
   if(Period()>60) // don't show on timeframes above hourly as lines will be too bunched together
     {
      clearScreen(prefix,true,NULL);
      return(0);
     }

   bool sydneyFound=false,tokyoFound=false; // tricky sessions due to them falling on a Sunday on some brokers

   while(i>=0)
     {
      int dayNumber=TimeDayOfWeek(Time[i]);
      int hr=TimeHour(Time[i]);
      int min=TimeMinute(Time[i]);
        
      if(lastDayNumber-dayNumber<0) // start of a new day
        {
         if(showWeekStart && dayNumber==1)
           {
            drawVerticalLine(prefix+"weekly_open_line"+i,Time[i],1,weekColour,3,true,"Weekly open");
            if(showOpenPrice)
              {
               drawBox(prefix+"week_open_range"+i,Time[i],Time[i]+dayLength*5,Open[i],Close[i+1],weekColour,false,true);
              }
           }
        }

      lastDayNumber=dayNumber;

      if(((hr==sydney) || (hr<london && hr>sydney && !sydneyFound)) && min==0)
        {
         sydneyFound=true;

         if(showSydney)
           {
            drawVerticalLine(prefix+"sydneyTimeOpen"+i,Time[i],1,sydneyColour,3,true,"Sydney open");
            if(showOpenPrice) drawTrendLine(prefix+"sydneyopen"+i,Time[i],Time[i]+sessionLength,Open[i],Open[i],1,sydneyColour,4,true,false,"Open ["+DoubleToStr(Open[i],Digits)+"]");
           }
           
           if((showPivot || showRandS) && pivotLength>=PERIOD_D1)
           {
            //---
            //Print("Doing Pivot Calculation for day " + dayNumber);
            doPivotCalculations(iBarShift(Symbol(),pivotLength,Time[i])+1,pivotLength);

            string pivotPrefix;
            int pivotDrawLength=dayLength;

            if(showPivot)
              {
               switch(pivotLength)
                 {
                  case PERIOD_D1:
                     pivotPrefix="Daily ";
                     break;
                  case PERIOD_W1:
                     pivotPrefix="Weekly ";
                     pivotDrawLength=dayLength*5;
                     break;
                  case PERIOD_MN1:
                     pivotPrefix="Monthly ";
                     pivotDrawLength=dayLength*30;
                     break;
                 }
                 
               if(lastDrawnPivot!=pivots[3])
                 {
                  drawTrendLine(prefix+"market_sessions_pivot"+i,Time[i],Time[i]+pivotDrawLength,pivots[3],pivots[3],1,pivotColour,4,true,false,pivotPrefix+"Pivot ["+DoubleToStr(pivots[3],Digits)+"]");
                 }
               else
                 {
                  drawTrendLine(prefix+"market_sessions_pivot"+i,Time[i],Time[i]+pivotDrawLength,pivots[3],pivots[3],1,pivotColour,4,true,false,"");
                 }

               // store the pivot value to see if we have changed days/weeks/months for labelling purposes
               lastDrawnPivot=pivots[3];
              }

            if(showRandS)
              {
               drawTrendLine(prefix+"dailyr3"+i,Time[i],Time[i]+dayLength,pivots[0],pivots[0],1,srColour,4,true,false,pivotPrefix+"R3 ["+DoubleToStr(pivots[0],Digits)+"]");
               drawTrendLine(prefix+"dailyr2"+i,Time[i],Time[i]+dayLength,pivots[1],pivots[1],1,srColour,4,true,false,pivotPrefix+"R2 ["+DoubleToStr(pivots[1],Digits)+"]");
               drawTrendLine(prefix+"dailyr1"+i,Time[i],Time[i]+dayLength,pivots[2],pivots[2],1,srColour,4,true,false,pivotPrefix+"R1 ["+DoubleToStr(pivots[2],Digits)+"]");
               drawTrendLine(prefix+"dailys1"+i,Time[i],Time[i]+dayLength,pivots[4],pivots[4],1,srColour,4,true,false,pivotPrefix+"S1 ["+DoubleToStr(pivots[4],Digits)+"]");
               drawTrendLine(prefix+"dailys2"+i,Time[i],Time[i]+dayLength,pivots[5],pivots[5],1,srColour,4,true,false,pivotPrefix+"S2 ["+DoubleToStr(pivots[5],Digits)+"]");
               drawTrendLine(prefix+"dailys3"+i,Time[i],Time[i]+dayLength,pivots[6],pivots[6],1,srColour,4,true,false,pivotPrefix+"S3 ["+DoubleToStr(pivots[6],Digits)+"]");
              }
           }
        }
      else if(((hr==tokyo) || (hr<london && hr>tokyo && !tokyoFound)) && min==0)
        {
         tokyoFound=true;

         if(showTokyo)
           {
            drawVerticalLine(prefix+"line"+i,Time[i],1,tokyoColour,3,true,"Tokyo open");
            if(showOpenPrice) drawTrendLine(prefix+"tokyoopen"+i,Time[i],Time[i]+sessionLength,Open[i],Open[i],1,tokyoColour,4,true,false,DoubleToStr(Open[i],Digits));
           }
        }
      else if((hr==london && min==0) && showLondon)
        {
         drawVerticalLine(prefix+"line"+i,Time[i],1,londonColour,3,true,"London open");
         if(showOpenPrice) drawTrendLine(prefix+"londonoopen"+i,Time[i],Time[i]+sessionLength,Open[i],Open[i],1,londonColour,4,true,false,DoubleToStr(Open[i],Digits));
        }
      else if((hr==newyork && min==0))
        {
         sydneyFound=false;
         tokyoFound=false;

         if(showNewYork)
           {
            drawVerticalLine(prefix+"line"+i,Time[i],1,newYorkColour,3,true,"New York open");
            if(showOpenPrice) drawTrendLine(prefix+"newyorkopen"+i,Time[i],Time[i]+sessionLength,Open[i],Open[i],1,newYorkColour,4,true,false,DoubleToStr(Open[i],Digits));
           }
        }

      i--;
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doPivotCalculations(int index,int period=PERIOD_D1)
  {
   pivots[3] = NormalizeDouble(((iHigh(Symbol(),period,index)+iLow(Symbol(),period,index)+iClose(Symbol(),period,index))/3),Digits); // pivot
   pivots[2] = NormalizeDouble(pivots[3] + (pivots[3] - iLow(Symbol(),period, index)),Digits); // r1
   pivots[4] = NormalizeDouble(pivots[3] - (iHigh(Symbol(),period,index) - pivots[3]),Digits); // s1
   pivots[1] = NormalizeDouble(pivots[3] + (iHigh(Symbol(),period,index) - iLow(Symbol(),period,index)),Digits); // r2
   pivots[5] = NormalizeDouble(pivots[3] - (iHigh(Symbol(),period,index) - iLow(Symbol(),period,index)),Digits); // s2
   pivots[0] = NormalizeDouble(pivots[2] + (iHigh(Symbol(),period,index) - iLow(Symbol(),period,index)),Digits); // r3
   pivots[6] = NormalizeDouble(pivots[4] - (iHigh(Symbol(),period,index) - iLow(Symbol(),period,index)),Digits); // s3

   int i;
   for(i=0; i<7; i++)
     {
      pivots[i]=pivots[i]+verticalShift*Point;
     }

   if(verticalShift>0)
     {
      Comment("Vertical shift active");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawVerticalLine(string name,double time,int thickness,color colour,int style,bool background,string label="")
  {
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name,OBJ_VLINE,0,time,0);
     }
   else
     {
      ObjectSet(name,OBJPROP_TIME1,time);
     }

   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_WIDTH,thickness);
   ObjectSet(name,OBJPROP_BACK,background);
   ObjectSet(name,OBJPROP_STYLE,style);

   ObjectSetText(name,label,8,"Arial",colour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawTrendLine(string name,double time1,double time2,double price1,double price2,int thickness,color colour,int style,bool background,bool ray,string label="")
  {
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name,OBJ_TREND,0,time1,price1,time2,price2);
      ObjectSet(name,OBJPROP_RAY,ray);

     }
   else
     {
      ObjectSet(name,OBJPROP_TIME1,time1);
      ObjectSet(name,OBJPROP_TIME2,time2);
      ObjectSet(name,OBJPROP_PRICE1,price1);
      ObjectSet(name,OBJPROP_PRICE2,price2);
     }

   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_WIDTH,thickness);
   ObjectSet(name,OBJPROP_BACK,background);
   ObjectSet(name,OBJPROP_STYLE,style);
   if(showLabels) ObjectSetText(name,label,8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawBox(string name,double time1,double time2,double price1,double price2,color colour,bool borderOnly=false,bool background=true)
  {
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name,OBJ_RECTANGLE,0,time1,price1,time2,price2);
     }
   else
     {
      ObjectSet(name,OBJPROP_TIME1,time1);
      ObjectSet(name,OBJPROP_TIME2,time2);
      ObjectSet(name,OBJPROP_PRICE1,price1);
      ObjectSet(name,OBJPROP_PRICE2,price2);
     }

   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_BACK,(borderOnly) ? false : background);
   ObjectSet(name,OBJPROP_BORDER_TYPE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getDayName(int dayNumber)
  {
   string days[7]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
   return (days[dayNumber]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clearScreen(string pref,bool clearComments,string exception)
  {
   if(clearComments) Comment("");

   int i;
   string name="";

   for(i=ObjectsTotal(); i>=0; i--)
     {
      name=ObjectName(i);
      if(StringFind(name,pref,0)>-1)
        {
         if(exception=="0" || StringFind(name,exception,0)==-1) ObjectDelete(name);
        }
     }
  }
//+------------------------------------------------------------------+
