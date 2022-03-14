//+------------------------------------------------------------------+
//|                                Autonomiczny Moduł Stochastyczny  |
//|                                Copyright 2022, Marcin Zubrzycki  |
//|                                                      Mastermind  |
//+------------------------------------------------------------------+


#include<Trade\Trade.mqh>
CTrade trade;

string KierunekPozycji="BEZ POZYCJI";
input int mnoznik = 1;
string stoch_signal="";
double CenaKupnaBID,CenaSprzedazyASK,CenaOstatnia,WielkoscPozycji;

input double wartoscK = 15;
input double wartoscD = 13;
input double stoplos=0.010;

void OnTick(){

CenaSprzedazyASK=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
CenaKupnaBID=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
CenaOstatnia=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);
WielkoscPozycji = NormalizeDouble((AccountInfoDouble(ACCOUNT_BALANCE))/(0.0001*CenaOstatnia*0.05),4); 

 MqlRates TablicaSwiec[];                                   
   ArraySetAsSeries(TablicaSwiec,true);  
   int Data=CopyRates(Symbol(),Period(),0,3,TablicaSwiec);

double OkresK[];
double OkresD[];

ArraySetAsSeries(OkresK,true);
ArraySetAsSeries(OkresD,true);

int Stoch = iStochastic(_Symbol,_Period,wartoscK,wartoscD,3,MODE_SMA,STO_LOWHIGH);

CopyBuffer(Stoch,0,0,3,OkresK);
CopyBuffer(Stoch,1,0,3,OkresD);

double aktualna_wartoscK=OkresK[0];
double aktualna_wartoscD=OkresD[0];

double poprzednia_wartoscK=OkresK[1];
double poprzednia_wartoscD=OkresD[1];

if((aktualna_wartoscK<20)&&(aktualna_wartoscD<20)){

 if((aktualna_wartoscK>aktualna_wartoscD)&&(poprzednia_wartoscK<poprzednia_wartoscD)){
 stoch_signal="buy";
 }
}

if((aktualna_wartoscK>80)&&(aktualna_wartoscD>80)){

 if((aktualna_wartoscK<aktualna_wartoscD)&&(poprzednia_wartoscK>poprzednia_wartoscD)){
 stoch_signal="sell";
 }
}


if(stoch_signal=="buy"){

if(KierunekPozycji=="SHORT"){
trade.PositionClose(PositionGetTicket(0));
for(int i=OrdersTotal()-1;i>=0;i--){trade.OrderDelete(OrderGetTicket(i));}
KierunekPozycji="BEZ POZYCJI";
}

if(PositionsTotal()==0){
if(CenaOstatnia>TablicaSwiec[1].close){ 
trade.Buy(NormalizeDouble((WielkoscPozycji/20)*mnoznik,4),NULL,CenaKupnaBID,0,0,NULL);
KierunekPozycji="LONG";}
}
}

if(stoch_signal=="sell"){

if(KierunekPozycji=="LONG"){
trade.PositionClose(PositionGetTicket(0));
for(int i=OrdersTotal()-1;i>=0;i--){trade.OrderDelete(OrderGetTicket(i));}
KierunekPozycji="BEZ POZYCJI";
}

if(PositionsTotal()==0){
if(CenaOstatnia<TablicaSwiec[1].close){
 trade.Sell(NormalizeDouble((WielkoscPozycji/20)*mnoznik,4),NULL,CenaSprzedazyASK,0,0,NULL);
KierunekPozycji="SHORT";}
}
}


Comment(stoch_signal);


if(PositionsTotal()!=0){
    Symbol()==PositionGetSymbol(0);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){KierunekPozycji="LONG";}
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){KierunekPozycji="SHORT";}
   
 if(OrdersTotal()==0){
   if(Symbol()==PositionGetSymbol(0)){
      
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
        trade.SellStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1-stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
        }
      
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
        trade.BuyStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1+stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
        }
   }}}

}


