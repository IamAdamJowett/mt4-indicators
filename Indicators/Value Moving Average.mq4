/*
   ________________________________________________________________________________

   NAME: Value Moving Average.mq4

   AUTHOR: Adam Jowett
   VERSION: 1.0.0
   DATE: 02 November 2016
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT:
   https://adamjowett.com/tag/downloads/
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
#property copyright "Copyright © 2016, Adam Jowett"
#property link      "https://www.adamjowett.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 DeepSkyBlue
#property indicator_color4 DimGray
#property indicator_color5 DimGray
#property indicator_color6 DimGray
#property indicator_color7 DimGray

extern ENUM_MA_METHOD   maMode = MODE_SMA;
extern ENUM_TIMEFRAMES  overrideTimeframe = PERIOD_CURRENT;
extern double           verticalShift = 0;
extern int              daysAhead = 2;
extern bool             showParallels = false;
extern bool             onlySmallerTimeframes = true;
extern bool             hideAnchor = false;
extern bool             hideAll = false;
extern bool             showTags = true;
extern bool             isBidChart = true;
extern string           prefix = "vma_";

double vmaH[];
double vmaC[];
double vmaL[];
double upPrl[];
double lwPrl[];
double upPrl2[];
double lwPrl2[];

int i = 0;
int markerTime = 0;
int sessionLength, dayLength;
double markerPrice = 0;
string markerName = "";
string tagName = "";

int init()
{
   i = 0;

   sessionLength = Period() * 60 * ((60 / Period()) * 9);
   dayLength = ((60 / Period()) * 24) * daysAhead;

   SetIndexBuffer(0, vmaH);
   SetIndexBuffer(1, vmaC);
   SetIndexBuffer(2, vmaL);
   SetIndexBuffer(3, upPrl);
   SetIndexBuffer(4, lwPrl);
   SetIndexBuffer(5, upPrl2);
   SetIndexBuffer(6, lwPrl2);

   if (hideAll)
   {
      SetIndexStyle(0,DRAW_LINE,2,1,CLR_NONE);
      SetIndexStyle(1,DRAW_LINE,0,2,CLR_NONE);
      SetIndexStyle(2,DRAW_LINE,2,1,CLR_NONE);
      SetIndexStyle(3,DRAW_LINE,0,2,CLR_NONE);
      SetIndexStyle(4,DRAW_LINE,0,2,CLR_NONE);
      SetIndexStyle(5,DRAW_LINE,0,2,CLR_NONE);
      SetIndexStyle(6,DRAW_LINE,0,2,CLR_NONE);
   }
   else
   {
      SetIndexStyle(0,DRAW_LINE,2,1,indicator_color1);
      SetIndexStyle(1,DRAW_LINE,0,2,indicator_color2);
      SetIndexStyle(2,DRAW_LINE,2,1,indicator_color3);
      SetIndexStyle(3,DRAW_LINE,2,1,indicator_color4);
      SetIndexStyle(4,DRAW_LINE,2,1,indicator_color5);
      SetIndexStyle(5,DRAW_LINE,2,1,indicator_color6);
      SetIndexStyle(6,DRAW_LINE,2,1,indicator_color7);
   }

   return(0);
}

int deinit()
{
   clearScreen(prefix, true, prefix + "marker");
   return(0);
}

int start()
{
   if (Period() > 60) {
      clearScreen(prefix, true, prefix + "marker");
      return(0);
   }

   if (markerName == "") markerName = prefix + "marker_";

   if (ObjectFind(markerName) == -1)
   {
      drawSymbol(markerName, 110, chartPriceMiddle(), Time[chartTimeMiddle()], Gold, 0, false);
      calculate();
   }

   return(0);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
{
   if(id==CHARTEVENT_OBJECT_DRAG)
   {
      calculate();
   }
}

void calculate()
{
   double valH, valC, valL;

   if (markerName == "") markerName = prefix + "marker_";
   if (tagName == "") tagName = prefix + "tag_";

   if (Period() > overrideTimeframe && onlySmallerTimeframes) overrideTimeframe = 0;

   if (hideAnchor || hideAll) ObjectSet(markerName, OBJPROP_COLOR, C'2,11,27');

   int markerShift = iBarShift(NULL, 0, ObjectGet(markerName, OBJPROP_TIME1));
   int mShift = iBarShift(NULL, overrideTimeframe, Time[markerShift]);

   if (markerShift != markerTime)
   {
      clearBuffers(MathMax(markerTime, markerShift) , 0);
      clearScreen(prefix, true, prefix + "marker");
      i = markerShift;
      markerTime = markerShift;
      markerPrice = ObjectGet(markerName, OBJPROP_PRICE1);
   }

   int max = 0;
   int extension;

   if (overrideTimeframe > 0) dayLength = MathMax(dayLength, dayLength * (overrideTimeframe / Period()));

   if (dayLength > 0)
   {
      max = MathMax(markerShift - dayLength, 0);
      extension = MathMax((max - dayLength), max);
   }

   int shift;
   double stdDev;

   while (i >= extension)
   {
      shift = iBarShift(NULL, overrideTimeframe, Time[i]);

      valH = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_HIGH, shift);
      valC = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_CLOSE, shift);
      valL = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_LOW, shift);

      if (valH > 0)
      {
         if (i > max)
         {
            vmaH[i] = valH + (verticalShift * Point);
            vmaC[i] = valC + (verticalShift * Point);
            vmaL[i] = valL + (verticalShift * Point);
         }
         else
         {
            vmaH[i] = vmaH[i + 1] + (vmaH[i + 1] - vmaH[i + 2]);
            vmaC[i] = vmaC[i + 1] + (vmaC[i + 1] - vmaC[i + 2]);
            vmaL[i] = vmaL[i + 1] + (vmaL[i + 1] - vmaL[i + 2]);
         }

         stdDev = iStdDev(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_CLOSE, shift);

         if (showParallels)
         {
            upPrl[i] = valH + stdDev;
            upPrl2[i] = valH + (stdDev * 2);
            lwPrl[i] = valL - stdDev;
            lwPrl2[i] = valL - (stdDev * 2);
         }
      }

      double tagPriceC = vmaC[i];
      double tagPriceH = vmaH[i];
      double tagPriceL = vmaL[i];

      if (markerPrice < vmaC[i] && isBidChart)
      {
         tagPriceH = vmaH[i] + (MarketInfo(Symbol(), MODE_SPREAD) * Point);
         tagPriceC = vmaC[i] + (MarketInfo(Symbol(), MODE_SPREAD) * Point);
         tagPriceL = vmaL[i] + (MarketInfo(Symbol(), MODE_SPREAD) * Point);
      }
      else if (markerPrice > vmaC[i] && !isBidChart)
      {
         tagPriceH = vmaH[i] - (MarketInfo(Symbol(), MODE_SPREAD) * Point);
         tagPriceC = vmaC[i] - (MarketInfo(Symbol(), MODE_SPREAD) * Point);
         tagPriceL = vmaL[i] - (MarketInfo(Symbol(), MODE_SPREAD) * Point);
      }

      if (showTags && !hideAll)
      {
         if (ObjectFind(tagName + "C") == -1)
         {
            drawSymbol(tagName + "C", SYMBOL_RIGHTPRICE, tagPriceC, Time[i], Gold, 0, false);
         }
         else
         {
            ObjectSet(tagName + "C", OBJPROP_PRICE1, tagPriceC);
            ObjectSet(tagName + "C", OBJPROP_TIME1, Time[i]);
         }
      }

      i--;

   }
}

void clearBuffers(int index, int l)
{
   while (index > l)
   {
      vmaH[index] = EMPTY_VALUE;
      vmaC[index] = EMPTY_VALUE;
      vmaL[index] = EMPTY_VALUE;

      upPrl[index] = EMPTY_VALUE;
      lwPrl[index] = EMPTY_VALUE;
      upPrl2[index] = EMPTY_VALUE;
      lwPrl2[index] = EMPTY_VALUE;

      index--;
   }
}

void drawSymbol (string name, int code, double price, int time, color colour, int window, bool background = false)
{
   ObjectCreate(name,OBJ_ARROW,window,time,price);
   ObjectSet(name,OBJPROP_ARROWCODE,code);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_BACK,background);
}

int chartTimeMiddle () { return(WindowFirstVisibleBar() - (WindowBarsPerChart() / 2)); }

double chartPriceMiddle() { return(WindowPriceMin() + ((WindowPriceMax() - WindowPriceMin()) / 2)); }

void clearScreen(string pre, bool clearComments, string exception)
{
   if (clearComments) Comment("");

   int index;
   string name = "";

   for (index = ObjectsTotal(); index >= 0; index--) {
      name = ObjectName(index);
      if (StringFind(name,pre,0) > -1) {
         if (exception == "0" || StringFind(name,exception,0) == -1) ObjectDelete(name);
      }
   }
}
