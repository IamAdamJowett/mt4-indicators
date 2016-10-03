/*
   ________________________________________________________________________________
   
   NAME: bsetrade.mqh
   
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

#property copyright "Copyright 2016, Adam Jowett (Buy Sell Eat)."
#property link      "http://www.adamjowett.com"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int buyMarket(double tradingLots,double stopLoss,double takeProfit,int expiration=0,color tradeColor=Green)
  {
   int ticket=OrderSend(Symbol(),OP_BUY,tradingLots,Ask,3,stopLoss,takeProfit,"Buy market trade",16384,expiration,tradeColor);
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
         Print("BUY order opened : ",OrderOpenPrice());
        }
      return ticket;
     }
   else
     {
      Print("Error opening BUY order : ",GetLastError());
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int sellMarket(double tradingLots,double stopLoss,double takeProfit,int expiration=0,color tradeColor=Red)
  {
   int ticket=OrderSend(Symbol(),OP_SELL,tradingLots,Bid,3,stopLoss,takeProfit,"Sell market trade",16384,expiration,tradeColor);
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
         Print("SELL order opened : ",OrderOpenPrice());
        }
      return ticket;
     }
   else
     {
      Print("Error opening SELL order : ",GetLastError());
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int closeAllBuys()
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         // could not find the order
         Print("[ERROR] Could not find the order to monitor stop loss");
         continue;
        }

      // if there is an open sell trade of this symbol
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
        {
         int closeID=OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);

         if(!closeID)
           {
            Print("[ERROR] Could not close all buy trades | " + IntegerToString(GetLastError()));
            return -1;
           }
         else
           {
            return closeID;
           }
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int closeAllSells()
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         // could not find the order
         Print("[ERROR] Could not find the order to monitor stop loss");
         continue;
        }

      // if there is an open sell trade of this symbol
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
        {
         int closeID=OrderClose(OrderTicket(),OrderLots(),Ask,3,Blue);

         if(!closeID)
           {
            Print("[ERROR] Could not close all sell trades | " + IntegerToString(GetLastError()));
            return -1;
           }
         else
           {
            return closeID;
           }
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
