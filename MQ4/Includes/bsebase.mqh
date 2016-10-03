/*
   ________________________________________________________________________________
   
   NAME: bsebase.mqh
   
   AUTHOR: Adam Jowett
   VERSION: 1.0.0
   DATE: 26 Mar 2016
   METAQUOTES LANGUAGE VERSION: 4.0
   UPDATES & MORE DETAILED DOCUMENTATION AT: 
   http://adamjowett.com/category/trading/downloads/
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

#property copyright "Copyright 2016, Buy Sell Eat and Adam Jowett."
#property link      "https://www.buyselleat.com"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool hasBars(int minBars)
  {
   return (Bars > minBars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool canTrade(double maxOrders)
  {
   return (OrdersTotal()<maxOrders);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintM(string msg)
  {
   Print("[LOG] "+msg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintW(string msg)
  {
   Print("[WARNING] "+msg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintE(string msg)
  {
   Print("[ERROR] "+msg);
  }
//+------------------------------------------------------------------+
