/*
   ________________________________________________________________________________
   
   NAME: Market Sessions.mq4
   
   AUTHOR: Adam Jowett
   VERSION: 1.2.0
   DATE: 28 May 2014
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT: 
   http://adamjowett.com/2012/04/market-sessions-metatrader-indicator/
   ________________________________________________________________________________

   The MIT License (MIT)

   Copyright (c) 2014 Adam Jowett
   
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
*/

#property copyright "Copyright © 2014, Adam Jowett"
#property link      "http://adamjowett.com"

#property indicator_chart_window

extern string     __ = "Enter -1 to disable a line";
extern int        sydney = 22;
extern int        tokyo = 0;
extern int        london = 7;
extern int        newyork = 12;
extern int        gmtServerOffset = 20;
extern bool       showFutureSessions = true;
extern bool       showOpenPrice = true;
extern bool       showPreviousRange = true;
extern int        maxTimeframe = PERIOD_M15;
extern color      tokyoColour = DeepSkyBlue;
extern color      sydneyColour = Plum;
extern color      londonColour = Magenta;
extern color      newYorkColour = Gold;
extern color      futureSessionColour = DimGray;

string prefix = "market_sessions_";
int sessionLength;

int init()
{
   sessionLength = Period() * 60 * ((60 / Period()) * 9);
   
   if (sydney > -1)
   {
      sydney = sydney + gmtServerOffset;
      if (sydney > 23) sydney = sydney - 24;
      if (sydney < 0) sydney = sydney + 24;
   }
   
   if (tokyo > -1)
   {
      tokyo = tokyo + gmtServerOffset;
      if (tokyo > 23) tokyo = tokyo - 24;
      if (tokyo < 0) tokyo = tokyo + 24;
   }
   
   if (london > -1)
   {
      london = london + gmtServerOffset;
      if (london > 23) london = london - 24;
      if (london < 0) london = london + 24;
   }
   
   if (newyork > -1)
   {
      newyork = newyork + gmtServerOffset;
      if (newyork > 23) newyork = newyork - 24;
      if (newyork < 0) newyork = newyork + 24;
   }
   
   return(0);
}

int deinit()
{
   clearScreen(prefix, true, NULL);
   return(0);
}

int start()
{
   if (Bars <= 10) return(0);

   int counted = IndicatorCounted();
   if (counted < 0) return(-1);
   if (counted > 0) counted--;
   
   int i = Bars - counted;
   
   while (i >= 0)
   {
      int dayNumber = TimeDayOfWeek(Time[i]) + 1;
      
      if (TimeHour(Time[i]) == sydney && TimeMinute(Time[i]) == 0 && sydney > -1)
      {
         drawVerticalLine(prefix + "sydneyTimeOpen"+i, Time[i], 1, sydneyColour, 3, true, "Sydney open");
         if (showOpenPrice) drawTrendLine(prefix +"sydneyopen" + i, Time[i], Time[i] + sessionLength, Open[i], Open[i], 1, sydneyColour, 4, true, false, DoubleToStr(Open[i], Digits));
      } 
      else if ((TimeHour(Time[i]) == tokyo && TimeMinute(Time[i]) == 0) && tokyo > -1)
      {
         drawVerticalLine(prefix + "line"+i, Time[i], 1, tokyoColour, 3, true, "Tokyo open");
         if (showOpenPrice) drawTrendLine(prefix +"tokyoopen" + i, Time[i], Time[i] + sessionLength, Open[i], Open[i], 1, tokyoColour, 4, true, false, DoubleToStr(Open[i], Digits));
      }
      else if ((TimeHour(Time[i]) == london && TimeMinute(Time[i]) == 0) && london > -1)
      {
         drawVerticalLine(prefix + "line"+i, Time[i], 1, londonColour, 3, true, "London open");
         if (showOpenPrice) drawTrendLine(prefix +"londonoopen" + i, Time[i], Time[i] + sessionLength, Open[i], Open[i], 1, londonColour, 4, true, false, DoubleToStr(Open[i], Digits));
      }
      else if ((TimeHour(Time[i]) == newyork && TimeMinute(Time[i]) == 0) && newyork > -1)
      {
         drawVerticalLine(prefix + "line"+i, Time[i], 1, newYorkColour, 3, true, "New York open");
         if (showOpenPrice) drawTrendLine(prefix +"newyorkopen" + i, Time[i], Time[i] + sessionLength, Open[i], Open[i], 1, newYorkColour, 4, true, false, DoubleToStr(Open[i], Digits));
      }
      
      i--;
   }

   return(0);
}

void drawVerticalLine(string name, double time, int thickness, color colour, int style, bool background, string label = "") 
{ 
   if (ObjectFind(name) != 0) 
   {
      ObjectCreate(name, OBJ_VLINE, 0, time, 0);
   } 
   else 
   { 
      ObjectSet(name, OBJPROP_TIME1, time);
   }
   
   ObjectSet(name,OBJPROP_COLOR, colour);
   ObjectSet(name,OBJPROP_WIDTH, thickness);
   ObjectSet(name, OBJPROP_BACK, background);
   ObjectSet(name, OBJPROP_STYLE, style);
   
   ObjectSetText(name, label, 8, "Arial", colour);
}

void drawTrendLine(string name, double time1, double time2, double price1, double price2, int thickness, color colour, int style, bool background, bool ray, string label = "") 
{
   if (ObjectFind(name) != 0) 
   {
      ObjectCreate(name, OBJ_TREND, 0, time1, price1, time2, price2);
      ObjectSet(name,OBJPROP_RAY,ray);
   
   } 
   else 
   {
      ObjectSet(name, OBJPROP_TIME1, time1);
      ObjectSet(name, OBJPROP_TIME2, time2);
      ObjectSet(name, OBJPROP_PRICE1, price1);
      ObjectSet(name, OBJPROP_PRICE2, price2);
   }

   ObjectSet(name,OBJPROP_COLOR, colour);
   ObjectSet(name,OBJPROP_WIDTH, thickness);
   ObjectSet(name,OBJPROP_BACK, background);
   ObjectSet(name,OBJPROP_STYLE, style);  
   ObjectSetText(name, label, 8);
}

string getDayName(int dayNumber)
{
   string days[7] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
   return (days[dayNumber]);
}

void clearScreen(string pref, bool clearComments, string exception)
{   
   if (clearComments) Comment("");
   
   int i;
   string name = "";

   for (i = ObjectsTotal(); i >= 0; i--) 
   {
      name = ObjectName(i);
      if (StringFind(name, pref, 0) > -1) 
      {
         if (exception == "0" || StringFind(name, exception,0) == -1) ObjectDelete(name);
      } 
   }
}