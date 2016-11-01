//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
   ________________________________________________________________________________

   NAME: bsebars.mqh

   AUTHOR: Adam Jowett
   VERSION: 1.1.0
   DATE: 09 October 2016
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT:
   http://adamjowett.com/tag/downloads/
   ________________________________________________________________________________

   The MIT License (MIT)

   Copyright (c) 2016 Adam Jowett

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

#property copyright "Copyright 2016, Adam Jowett."
#property link      "https://www.adamjowett.com"
#property strict
//+------------------------------------------------------------------+
//| Higher close bar
//+------------------------------------------------------------------+
bool closeUp(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) > iOpen(symbol,timeframe,index));
  }
//+------------------------------------------------------------------+
//| Lower close bar
//+------------------------------------------------------------------+
bool closeDown(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) < iOpen(symbol,timeframe,index));
  }
//+------------------------------------------------------------------+
//| Close is higher than close n bars back
//+------------------------------------------------------------------+
bool higherClose(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) > iClose(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Close is lower than close n bars back
//+------------------------------------------------------------------+
bool lowerClose(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) < iClose(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Open is higher than open n bars back
//+------------------------------------------------------------------+
bool higherOpen(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iOpen(symbol,timeframe,index) > iOpen(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Open is lower than open n bars back
//+------------------------------------------------------------------+
bool lowerOpen(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iOpen(symbol,timeframe,index) < iOpen(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| High is higher than high n bars back
//+------------------------------------------------------------------+
bool higherHigh(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iHigh(symbol,timeframe,index) > iHigh(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| High is lower than high n bars back
//+------------------------------------------------------------------+
bool lowerHigh(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iHigh(symbol,timeframe,index) < iHigh(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Low is lower than low n bars back
//+------------------------------------------------------------------+
bool lowerLow(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iLow(symbol,timeframe,index) < iLow(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Low is higher than low n bars back
//+------------------------------------------------------------------+
bool higherLow(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iLow(symbol,timeframe,index) > iLow(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Bar has closer lower than low n bars back
//+------------------------------------------------------------------+
bool closeBelow(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) < iLow(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Bar has closed higher than high n bars back
//+------------------------------------------------------------------+
bool closeAbove(int index=0,int lookback=1,string symbol=NULL,int timeframe=0)
  {
   return (iClose(symbol,timeframe,index) < iHigh(symbol,timeframe,index + lookback));
  }
//+------------------------------------------------------------------+
//| Size of the entire bar/candle (difference between high and low)
//+------------------------------------------------------------------+
double barSize(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (iHigh(symbol,timeframe,index) - iLow(symbol,timeframe,index));
  }
//+------------------------------------------------------------------+
//| Size of upper candle wick (high - open/close)
//+------------------------------------------------------------------+
double upperWickSize(int index=0,string symbol=NULL,int timeframe=0)
  {
   return iHigh(symbol,timeframe,index) - MathMax(iOpen(symbol,timeframe,index),iClose(symbol,timeframe,index));
  }
//+------------------------------------------------------------------+
//| Size of the lower wick (open/close - low)
//+------------------------------------------------------------------+
double lowerWickSize(int index=0,string symbol=NULL,int timeframe=0)
  {
   return MathMin(iOpen(symbol,timeframe,index),iClose(symbol,timeframe,index)) - iLow(symbol,timeframe,index);
  }
//+------------------------------------------------------------------+
//| The candle body size (difference between open and close)
//+------------------------------------------------------------------+
double bodySize(int index=0,string symbol=NULL,int timeframe=0)
  {
   return MathAbs(iOpen(symbol,timeframe,index) - iClose(symbol,timeframe,index));
  }
//+------------------------------------------------------------------+
//| When a bar closes below n bar back's lowest of open/close and
//| high and low outside range of n bars back
//+------------------------------------------------------------------+
bool bearishEngulfing(int index=0,string symbol=NULL,int timeframe=0)
  {
   return outsideBar(index, symbol, timeframe) && closeBelow(index, 1, symbol, timeframe);
  }
//+------------------------------------------------------------------+
//| When a bar closes above n bars back's highest of open/close and
//| high and low outside the range of n bars back
//+------------------------------------------------------------------+
bool bullishEngulfing(int index=0,string symbol=NULL,int timeframe=0)
  {
   return outsideBar(index, symbol, timeframe) && closeAbove(index, 1, symbol, timeframe);
  }
//+------------------------------------------------------------------+
//| Low and high inside n bars back low and high and body smaller
//+------------------------------------------------------------------+
bool insideBar(int index=0,string symbol=NULL,int timeframe=0)
  {
   return barSize(index, symbol, timeframe) < barSize(index+1,symbol,timeframe);
  }
//+------------------------------------------------------------------+
//| Low and high outside n bars back low and high and body larger
//+------------------------------------------------------------------+
bool outsideBar(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (barSize(index,symbol,timeframe) > barSize(index+1,symbol,timeframe)) && (bodySize(index,symbol,timeframe) > bodySize(index+1,symbol,timeframe));
  }
//+------------------------------------------------------------------+
//| Lower wick larger than upper wick and body size, lower low and high
//| than n bars back
//+------------------------------------------------------------------+
bool pinUp(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (lowerWickSize(index, symbol, timeframe) > upperWickSize(index, symbol, timeframe) &&
           lowerWickSize(index,symbol,timeframe)>bodySize(index,symbol,timeframe) &&
           lowerHigh(index,1,symbol,timeframe) &&
           lowerLow(index,1,symbol,timeframe));
  }
//+------------------------------------------------------------------+
//| Upper wick larger than lower wick and body size, higher low and
//| high than n bars back
//+------------------------------------------------------------------+
bool pinDown(int index=0,string symbol=NULL,int timeframe=0)
  {
   return (upperWickSize(index, symbol, timeframe) > lowerWickSize(index, symbol, timeframe) &&
           upperWickSize(index,symbol,timeframe)>bodySize(index,symbol,timeframe) &&
           higherHigh(index,1,symbol,timeframe) &&
           higherLow(index,1,symbol,timeframe));
  }
//+------------------------------------------------------------------+
//| Bar has a higher high and lower low than price
//+------------------------------------------------------------------+
bool straddles(double price,int index=0,string symbol=NULL,int timeframe=0)
  {
   return (iHigh(symbol,timeframe,index) > price && iLow(symbol,timeframe,index) < price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullishPin(int index=0,string symbol=NULL,int timeframe=0)
  {
   return lowerWickSize(index,symbol,timeframe) > upperWickSize(index,symbol,timeframe) && lowerWickSize(index,symbol,timeframe) > bodySize(index,symbol,timeframe);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullishPinAt(double price,int index=0,string symbol=NULL,int timeframe=0)
  {
   return (bullishPin(index,symbol,timeframe) && iClose(symbol,timeframe,index) > price && iOpen(symbol,timeframe,index) > price && iLow(symbol,timeframe,index) <= price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishPin(int index=0,string symbol=NULL,int timeframe=0)
  {
   return upperWickSize(index,symbol,timeframe) > lowerWickSize(index,symbol,timeframe) && upperWickSize(index,symbol,timeframe) > bodySize(index,symbol,timeframe);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishPinAt(double price,int index=0,string symbol=NULL,int timeframe=0)
  {
   return (bearishPin(index,symbol,timeframe) && iClose(symbol,timeframe,index) < price && iOpen(symbol,timeframe,index) < price && iHigh(symbol,timeframe,index) >= price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishBarAt(double price,int index=0,string symbol=NULL,int timeframe=0)
  {
   return closeDown(index,symbol,timeframe) && straddles(price,index,symbol,timeframe);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullishBarAt(double price,int index=0,string symbol=NULL,int timeframe=0)
  {
   return closeUp(index,symbol,timeframe) && straddles(price,index,symbol,timeframe);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool largerThan(int lookback,double perc=1,int index=0,string symbol=NULL,int timeframe=0)
  {
   return barSize(index,symbol,timeframe) > (barSize(lookback,symbol,timeframe) * perc);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool smallerThan(int lookback,double perc=1,int index=0,string symbol=NULL,int timeframe=0)
  {
   return barSize(index,symbol,timeframe) < (barSize(lookback,symbol,timeframe) * perc);
  }
//+------------------------------------------------------------------+
