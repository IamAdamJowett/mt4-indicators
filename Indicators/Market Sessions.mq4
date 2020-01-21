//+------------------------------------------------------------------+
//|                           Market Sessions Metatrader 4 Indicator |
//|                                  Copyright 2016-2019 Adam Jowett |
//|                                       https://www.buyselleat.com |
//+------------------------------------------------------------------+

/*
   ________________________________________________________________________________
   
   NAME: Market Sessions.mq4
   
   AUTHOR: Adam Jowett
   VERSION: 2.3.1
   DATE: 21 Jan 2020
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT: 
   https://www.buyselleat.com/trading/
   ________________________________________________________________________________

   LICENCE:

   buyselleat.com Source Code License Agreement	  
   Copyright (c) 2019 buyselleat.com


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

#property copyright "Copyright © 2014-2020, Buy Sell Eat"
#property link      "https://buyselleat.com"
#property strict

#property indicator_chart_window

input int              gmtServerOffset = 2;          // Broker GMT Offset
input bool             showSydney = true;            // Show Sydney open
input bool             showTokyo = false;            // Show Tokyo open
input bool             showLondon = false;           // Show London open
input bool             showNewYork = false;          // Show New York open
input bool             showPivot = true;             // Show Pivot
input bool             showRandS = true;             // Show Pivot Resistance & Support
input bool             showOpenPrice = false;        // Show session open price
input bool             showLabels = true;            // Show object labels
input bool             showWeekStart = true;         // Show weekly open price
input bool             showDayNames = true;          // Show day names
input ENUM_TIMEFRAMES  pivotLength = PERIOD_D1;      // Define line length for pivots
input color            pivotColour = clrRoyalBlue;      // Pivot line colour
input color            srColour = clrDimGray;           // Pivot Support & Resistance colour
input color            openColour = clrLimeGreen;       // Open price colour
input color            closeColour = clrRed;            // Close price colour
input color            tokyoColour = clrDeepSkyBlue;    // Tokyo session colour
input color            sydneyColour = clrPlum;          // Sydney session colour
input color            londonColour = clrMagenta;       // London session colour
input color            newYorkColour = clrGold;         // New york session colour
input color            weekColour = clrDarkSlateGray;   // Weekly line colour

int                     sydney = 22;                
int                     tokyo = 0;
int                     london = 7;
int                     newyork = 12;
int                     verticalShift = 0;

string   prefix="market_sessions_";
int      sessionLength,dayLength,lastDayNumber;
double   pivots[7],lastDrawnPivot;

int OnInit()
  {
   IndicatorShortName("Market Sessions"); 
  
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


void OnDeinit(const int reason)
  {
   switch(reason)
   {
      case REASON_CHARTCHANGE :
      case REASON_RECOMPILE   :
      case REASON_CLOSE       : break;
      default :
      {
         clearScreen(prefix,true,NULL);
      }                  
   }
  }


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {  
 
   if(Period()>60) // don't show on timeframes above hourly as lines will be too bunched together
     {
      clearScreen(prefix,true,NULL);
      return(0);
     }

   ArraySetAsSeries(open,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);
   
   datetime currentTime = time[0];
   double currentOpen = open[0];
   double prevOpen = open[1];
   double currentClose = close[0];
   double prevClose = close[1];
   int dayNumber = 0;
   int hr = 0;
   int min = 0;
   int i = 1;
   
   while(i<rates_total-1)
     {    
      currentTime = time[i];
      currentOpen = open[i];
      currentClose = close[i];
      prevOpen = open[i+1];
      prevClose = close[i+1];
      
      dayNumber=TimeDayOfWeek(currentTime);
      hr=TimeHour(currentTime);
      min=TimeMinute(currentTime);
      
      string objectIndex = IntegerToString(i);
      string labelSuffix = "";
      
      if (showDayNames) 
        {
         labelSuffix = " [" + getDayName(dayNumber)  + "]";
        } 
        
      if(lastDayNumber-dayNumber<0) // start of a new day
        {
         if(showWeekStart && dayNumber==1)
           {
            drawVerticalLine(prefix+"weekly_open_line"+objectIndex,currentTime,1,weekColour,3,true,"Weekly open" + labelSuffix);
            if(showOpenPrice)
              {
               drawBox(prefix+"week_open_range"+objectIndex,currentTime,currentTime+dayLength*5,currentOpen,prevClose,weekColour,false,true);
              }
           }
        }

      lastDayNumber=dayNumber;

      if((hr==sydney && min==0) && showSydney)
        {
           drawVerticalLine(prefix+"sydneyTimeOpen"+objectIndex,currentTime,1,sydneyColour,3,true,"Sydney open" + labelSuffix);
           if(showOpenPrice) drawTrendLine(prefix+"sydneyopen"+objectIndex,currentTime,currentTime+sessionLength,currentOpen,currentOpen,1,sydneyColour,4,true,false,"Open ["+DoubleToStr(currentOpen,Digits)+"]");
           
           if((showPivot || showRandS) && pivotLength>=PERIOD_D1)
           {
            doPivotCalculations(iBarShift(Symbol(),pivotLength,currentTime)+1,pivotLength);

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
                  drawTrendLine(prefix+"market_sessions_pivot"+objectIndex,currentTime,currentTime+pivotDrawLength,pivots[3],pivots[3],1,pivotColour,4,true,false,pivotPrefix+"Pivot ["+DoubleToStr(pivots[3],Digits)+"]"+labelSuffix);
                 }
               else
                 {
                  drawTrendLine(prefix+"market_sessions_pivot"+objectIndex,currentTime,currentTime+pivotDrawLength,pivots[3],pivots[3],1,pivotColour,4,true,false,"");
                 }

               // store the pivot value to see if we have changed days/weeks/months for labelling purposes
               lastDrawnPivot=pivots[3];
              }

            if(showRandS)
              {
               drawTrendLine(prefix+"dailyr3"+objectIndex,currentTime,currentTime+dayLength,pivots[0],pivots[0],1,srColour,4,true,false,pivotPrefix+"R3 ["+DoubleToStr(pivots[0],Digits)+"]"+labelSuffix);
               drawTrendLine(prefix+"dailyr2"+objectIndex,currentTime,currentTime+dayLength,pivots[1],pivots[1],1,srColour,4,true,false,pivotPrefix+"R2 ["+DoubleToStr(pivots[1],Digits)+"]"+labelSuffix);
               drawTrendLine(prefix+"dailyr1"+objectIndex,currentTime,currentTime+dayLength,pivots[2],pivots[2],1,srColour,4,true,false,pivotPrefix+"R1 ["+DoubleToStr(pivots[2],Digits)+"]"+labelSuffix);
               drawTrendLine(prefix+"dailys1"+objectIndex,currentTime,currentTime+dayLength,pivots[4],pivots[4],1,srColour,4,true,false,pivotPrefix+"S1 ["+DoubleToStr(pivots[4],Digits)+"]"+labelSuffix);
               drawTrendLine(prefix+"dailys2"+objectIndex,currentTime,currentTime+dayLength,pivots[5],pivots[5],1,srColour,4,true,false,pivotPrefix+"S2 ["+DoubleToStr(pivots[5],Digits)+"]"+labelSuffix);
               drawTrendLine(prefix+"dailys3"+objectIndex,currentTime,currentTime+dayLength,pivots[6],pivots[6],1,srColour,4,true,false,pivotPrefix+"S3 ["+DoubleToStr(pivots[6],Digits)+"]"+labelSuffix);
              }
           }
        }
      else if((hr==tokyo && min==0) && showTokyo)
        {
          drawVerticalLine(prefix+"line"+objectIndex,currentTime,1,tokyoColour,3,true,"Tokyo open" + labelSuffix);
          if(showOpenPrice) drawTrendLine(prefix+"tokyoopen"+objectIndex,currentTime,currentTime+sessionLength,currentOpen,currentOpen,1,tokyoColour,4,true,false,DoubleToStr(currentOpen,Digits));
        }
      else if((hr==london && min==0) && showLondon)
        {
         drawVerticalLine(prefix+"line"+objectIndex,currentTime,1,londonColour,3,true,"London open" + labelSuffix);
         if(showOpenPrice) drawTrendLine(prefix+"londonoopen"+objectIndex,currentTime,currentTime+sessionLength,currentOpen,currentOpen,1,londonColour,4,true,false,DoubleToStr(currentOpen,Digits));
        }
      else if((hr==newyork && min==0) && showNewYork)
        {
          drawVerticalLine(prefix+"line"+objectIndex,currentTime,1,newYorkColour,3,true,"New York open" + labelSuffix);
          if(showOpenPrice) drawTrendLine(prefix+"newyorkopen"+objectIndex,currentTime,currentTime+sessionLength,currentOpen,currentOpen,1,newYorkColour,4,true,false,DoubleToStr(currentOpen,Digits));
        }

       i++;
     }

   return(0);
  }

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

void drawVerticalLine(string name,datetime time,int thickness,color colour,int style,bool background,string label="")
  {
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name,OBJ_VLINE,0,time,0.00);
     }
   else
     {
      ObjectSet(name,OBJPROP_TIME1,time);
     }

   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_WIDTH,thickness);
   ObjectSet(name,OBJPROP_BACK,background);
   ObjectSet(name,OBJPROP_STYLE,style);

   ObjectSetText(name,label,10,"Arial",colour);
  }

void drawTrendLine(string name,datetime time1,datetime time2,double price1,double price2,int thickness,color colour,int style,bool background,bool ray,string label="")
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

void drawBox(string name,datetime time1,datetime time2,double price1,double price2,color colour,bool borderOnly=false,bool background=true)
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

string getDayName(int dayNumber)
  {
   string days[7]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
   return (days[dayNumber]);
  }

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
