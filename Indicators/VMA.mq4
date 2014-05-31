   /*
   ________________________________________________________________________________
   
   NAME: Value Moving Average.mq4
   
   AUTHOR: Adam Jowett
   VERSION: 2.1.0
   DATE: 2014-04-20
   METAQUOTES LANGUAGE VERSION: 4.0/5.0
   LICENSE: MIT
   UPDATES & MORE DETAILED DOCUMENTATION AT: 
   http://adamjowett.com/
   ________________________________________________________________________________
   
   The MIT License (MIT)

   Copyright (c) 2014 Adam Jowett (http://adamjowett.com)
   
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
   
   */

   // Default properties
   #property copyright "Copyright © 2014, Adam Jowett, adamjowett.com"
   #property link      "http://www.adamjowett.com"
   #property strict
   
   // Indicator properties
   #property indicator_chart_window
   #property indicator_buffers 5
   #property indicator_color1 Red
   #property indicator_color2 Gold
   #property indicator_color3 DeepSkyBlue
   #property indicator_color4 Orange
   #property indicator_color5 Orange
   
   // Input options
   extern string           prefix               = "vma_";
   extern ENUM_MA_METHOD   maMode               = MODE_SMA;
   extern int              overrideTimeframe    = 0;
   extern double           verticalShift        = 0;
   extern double           bandMultiple         = 4;
   extern double           distance             = 500;
   extern bool             showParallels       = false;
   extern bool             onlySmaller          = true;
   extern bool             hideAnchor           = false;
   extern bool             hideAll              = false;
   extern bool             showTags             = true;
   extern bool             isBidChart           = true;
   extern int              updateMilliseconds   = 500;
   
   datetime markerPosition = 0;
   double vmaH[], vmaC[], vmaL[], parallelH[], parallelL[], markerPrice = 0;
   int i = 0, markerTime;
   string markerName = "", tagName = "";
   
   int OnInit(void)
   {
   	if (markerName == "") markerName = prefix + "marker_";
   	if (tagName == "") tagName = prefix + "tag_";
   
   	// Only override the timeframe if the timeframe viewed is smaller than custom
   	if (Period() > overrideTimeframe && onlySmaller) overrideTimeframe = 0;
   	
   	// Look for the anchor marker with the same prefix, create if it doesn't exist else
   	// use what is already there
   	if (ObjectFind(markerName) == -1)
   	{
   		drawSymbol(markerName, 110, chartPriceMiddle(), Time[chartTimeMiddle()], Gold, 0, false);
   	}
   
   	// Set an timer to update the indicator every 500ms by default. Useful when draggin the marker around.
   	EventSetMillisecondTimer(updateMilliseconds);
   
   	i = 0;
   
   	SetIndexBuffer(0 ,vmaH);
   	SetIndexBuffer(1, vmaC);
   	SetIndexBuffer(2, vmaL);
   	SetIndexBuffer(3, parallelH);
   	SetIndexBuffer(4, parallelL);
   
   	if (hideAll)
   	{
   		SetIndexStyle(0,DRAW_LINE,2,1,CLR_NONE);
   		SetIndexStyle(1,DRAW_LINE,0,2,CLR_NONE);
   		SetIndexStyle(2,DRAW_LINE,2,1,CLR_NONE);
   		SetIndexStyle(3,DRAW_LINE,2,1,CLR_NONE);
   		SetIndexStyle(4,DRAW_LINE,2,1,CLR_NONE);
   	}
   	else
   	{
   		SetIndexStyle(0,DRAW_LINE,2,1,indicator_color1);
   		SetIndexStyle(1,DRAW_LINE,0,2,indicator_color2);
   		SetIndexStyle(2,DRAW_LINE,2,1,indicator_color3);
   		SetIndexStyle(3,DRAW_LINE,2,1,indicator_color4);
   		SetIndexStyle(4,DRAW_LINE,2,1,indicator_color5);
   	}
   
   	return(0);
   }
   
   void OnDeinit(const int reason)
   {
   	EventKillTimer();
   	clearScreen(prefix, true, prefix + "marker");
   }
   
   void OnTimer(void)
   {
   	double valH, valC, valL, parH, parL;
   	int extension = 0;
   	int max = 0;
   	
   	// Look for the anchor marker with the same prefix, create if it doesn't exist else
   	// use what is already there
   	if (ObjectFind(markerName) == -1)
   	{
   		drawSymbol(markerName, 110, chartPriceMiddle(), Time[chartTimeMiddle()], Gold, 0, false);
   	}
   
   	// Hide the marker, used mainly for screenshotting
   	if (hideAnchor || hideAll) ObjectSet(markerName, OBJPROP_COLOR, CLR_NONE);
   
   	// Record the current market position so we can check next time around to see if calcs need to be done
   	markerPosition = ObjectGet(markerName, OBJPROP_TIME1);
   
   	// Find the position of the marker in current timeframe and custom timeframe
   	int markerShift = iBarShift(NULL, 0, markerPosition);
   	int mShift = iBarShift(NULL, overrideTimeframe, Time[markerShift]);
   
   	// If on a different timeframe than defined in the override
   	if (markerShift != markerTime)
   	{
   		clearBuffers(MathMax(markerTime, markerShift), 0);
   		clearScreen(prefix, true, prefix + "marker");
   		i = markerShift;
   		markerTime = markerShift;
   		markerPrice = ObjectGet(markerName, OBJPROP_PRICE1);
   	}
   
   	if (overrideTimeframe > 0) distance = MathMax(distance, distance *(overrideTimeframe / Period()));
   
   	if (distance > 0)
   	{
   		max = MathMax(markerShift - distance, 0);
   		extension = MathMax((max - distance), max);
   	}
   	else
   	{
   	   return;
   	}
   
   	double tagPriceC;
   	int shift;
   
   	while (i >= extension)
   	{
   		shift = iBarShift(NULL, overrideTimeframe, Time[i]);
   
   		valH = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_HIGH, shift);
   		valC = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_CLOSE, shift);
   		valL = iMA(NULL, overrideTimeframe, mShift - shift, 0, maMode, PRICE_LOW, shift);
   		parH = valH + ((valH - valL) * bandMultiple);
   		parL = valL - ((valH - valL) * bandMultiple);
         
   		if(valH > 0)
   		{
   			if(i > max)
   			{
   				vmaH[i] = valH + (verticalShift * Point);
   				vmaC[i] = valC + (verticalShift * Point);
   				vmaL[i] = valL + (verticalShift * Point);
   				
   				if (showParallels) {
      				parallelH[i] = parH + (verticalShift * Point);
      				parallelL[i] = parL + (verticalShift * Point);
   				}
   			}
   			else
   			{
   				vmaH[i] = vmaH[i + 1] + (vmaH[i + 1] - vmaH[i + 2]);
   				vmaC[i] = vmaC[i + 1] + (vmaC[i + 1] - vmaC[i + 2]);
   				vmaL[i] = vmaL[i + 1] + (vmaL[i + 1] - vmaL[i + 2]);
   				
   				if (showParallels) {
      				parallelH[i] = parallelH[i + 1] + (parallelH[i + 1] - parallelH[i + 2]);
      				parallelL[i] = parallelL[i + 1] + (parallelL[i + 1] - parallelL[i + 2]);
   				}
   			}
   		}
   
   		ObjectSet(markerName, OBJPROP_COLOR, Gold);
   
   		tagPriceC = vmaC[i];
   
   		if(showTags && !hideAll)
   		{
   		   string closeTag = tagName + "C";
   		   
   			if(ObjectFind(closeTag) == -1)
   			{
   				drawSymbol(closeTag, SYMBOL_RIGHTPRICE, tagPriceC, Time[i], Gold, 0, false);
   			}
   			else
   			{
   				ObjectSet(closeTag, OBJPROP_PRICE1, tagPriceC);
   				ObjectSet(closeTag, OBJPROP_TIME1, Time[i]);
   			}
   		}
   
   		i--;
   	}
   }
   
   int OnCalculate (const int rates_total, const int prev_calculated, const int begin, const double& price[])
   {
      return(0);
   }

   void drawSymbol(string name, int code, double price, datetime time, color colour, int window, bool background = false)
   {
   	ObjectCreate(name, OBJ_ARROW, window, time, price);
   	ObjectSet(name, OBJPROP_ARROWCODE, code);
   	ObjectSet(name, OBJPROP_COLOR, colour);
   	ObjectSet(name, OBJPROP_BACK, background);
   }

   int chartTimeMiddle()
   {
   	return(WindowFirstVisibleBar() - (WindowBarsPerChart() / 2));
   }

   double chartPriceMiddle()
   {
   	return(WindowPriceMin() + ((WindowPriceMax() - WindowPriceMin()) / 2));
   }
   
   void clearBuffers(int index, int l)
   {
      while(index > l)
   	{
   		vmaH[index] = EMPTY_VALUE;
   		vmaC[index] = EMPTY_VALUE;
   		vmaL[index] = EMPTY_VALUE;
   		parallelH[index] = EMPTY_VALUE;
   		parallelL[index] = EMPTY_VALUE;
   
   		index--;
   	}
   }

   void clearScreen(string pref, bool clearComments, string exception)
   {
   	if (clearComments) Comment("");
   
   	int index;
   	string name = "";
   
   	for (index = ObjectsTotal(); index >= 0; index--) 
   	{
   		name = ObjectName(index);
   		if (StringFind(name, pref, 0) > -1) 
   		{
   			if (exception == "0" || StringFind(name, exception, 0) == -1) ObjectDelete(name);
   		}
   	}
   }