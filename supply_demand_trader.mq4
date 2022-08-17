//+------------------------------------------------------------------+
//|                                         supply_demand_trader.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input double stop_loss = 10; //stop loss(pip)

input double risk_amount = 10; //risk amount in usd

input double riskreward = 2; //reward to risk ratio

input int candle_to_analyze = 250; //candle to analyze

input double pip_distance_from_current_price = 40; //pip distance from current price

input int move_count_of_nth_candle = 5; //from pivot to nth candle push

input int minimum_left_side_candle = 15; //minimum left side candle from pivot

input double minimum_left_side_distance_pip = 30; //minimum left side pip distance

//input int minimum_right_side_candle = 15; // minimum right side candle from pivot

input bool five_digit_broker = true; //is five digit broker 

input int min_move_distance = 5; //minimum move distance in pips from pivot




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |

//+------------------------------------------------------------------+




void OnTick()
  {
//---

if(upper_dip() != 0 && OrdersTotal() < 2){
      
      double highprice = High[upper_dip()];
      int minimum = upper_dip()- move_count_of_nth_candle;
      Print("min price is finnaly ",minimum);
      double distance = 0;
      if(minimum <=0){
      
       distance = 0;
      
      }
      else{
      double lowprice = Low[minimum];
      
       distance = getPips(highprice,lowprice);
      
      }
       
      double stop_loss_price=High[upper_dip()];
      
      double entry = stop_loss_price - ((stop_loss))*Point*10;
      
      double Tp = entry - ((stop_loss)*riskreward)*Point*10;
      
      
      if(five_digit_broker == false){
      
      entry = stop_loss_price - ((stop_loss))*Point;
      
      Tp = entry - ((stop_loss)*riskreward)*Point;
       
       
      
      }  //end of setting stoploss,entry and tp
      
      //check for pending order opened with exact same entry or not. If opened do not open another again at the same price .
      Print("check roder is ",checkOrder(entry));
      if(checkOrder(entry) != true && min_move_distance < distance){
      
      Print("checking order status ",checkOrder(entry));
      
      //now you can place the pending order here ......
      
        double lot = getLotSize(stop_loss,risk_amount);
       
       int ticket = OrderSend(Symbol(),OP_SELLLIMIT,lot,entry,2,stop_loss_price,Tp,"from EA",9999,TimeCurrent()+86400,Red);
       
       Print("order opened sell limit",ticket);
      
      }



//Comment("the lower dip price is ",Low[lower_dip()]);

}


//open buy limit order here


if(lower_dip() != 0 && OrdersTotal() < 2){


      
      
      //distance calculator
         
      double lowprice = Low[lower_dip()];
      int minimum = lower_dip()- move_count_of_nth_candle;
      Print("min price is finnaly ",minimum);
      double distance = 0;
      if(minimum <=0){
      
       distance = 0;
      
      }
      else{
      double highprice = High[minimum];
      
       distance = getPips(highprice,lowprice);
      
      }
      
      //end of distance calc
      
      
      double stop_loss_price=Low[lower_dip()];
      
      double entry = stop_loss_price + ((stop_loss))*Point*10;
      
      double Tp = entry + ((stop_loss)*riskreward)*Point*10;
      
      
      if(five_digit_broker == false){
      
      entry = stop_loss_price + ((stop_loss))*Point;
      
      Tp = entry + ((stop_loss)*riskreward)*Point;
       
       
      
      }  //end of setting stoploss,entry and tp
      
      //check for pending order opened with exact same entry or not. If opened do not open another again at the same price .
      Print("check roder is ",checkOrder(entry));
      if(checkOrder(entry) != true && min_move_distance < distance ){
      
      //now you can place the pending order here ......
      
      double lot = getLotSize(stop_loss,risk_amount);
       
       int ticket = OrderSend(Symbol(),OP_BUYLIMIT,lot,entry,2,stop_loss_price,Tp,"from EA",9999,TimeCurrent()+86400,Blue);
       
       Print("order opened buy limit",ticket);
      
      }



//Comment("the lower dip price is ",Low[lower_dip()]);

}


   
  }
//+------------------------------------------------------------------+


//function to find the upper supply area

int upper_dip(){

   //loop through all the past candles set by input 
   
            
     double curr_high = 0.0;
     double curr_low = 1000;
      int temp_high_bar = 0;
      int low_bar_count = 0;
      int highest_candle = 0;
      
      int lowest_low_candle_no = 0;
         
     for(int i=1;i<candle_to_analyze;i++){
            Print("curr candle upper dip ",i);
            double candle_high = High[i];
            double candle_low =  Low[i];
            
            if(candle_high > curr_high){
            
                  curr_high = candle_high;
                  temp_high_bar = i;
                  highest_candle = i;
                  low_bar_count = 0;
                  curr_low = candle_low;
            
               }
               
             else{
             
               if(candle_low < curr_low){
               
                  lowest_low_candle_no = i;
                  curr_low = candle_low;
               
               }
             
               low_bar_count = low_bar_count+1;
             
             };
             
             
             //check if the condition has met or not
             
             if(low_bar_count >= minimum_left_side_candle && getPips(High[highest_candle],Bid) >= pip_distance_from_current_price && getPips(High[highest_candle],Low[lowest_low_candle_no]) >= minimum_left_side_distance_pip ){
               
               //Print("pip dist from current price ",getPips(High[highest_candle],Bid));
               //Print("Minumum left side distance pip is",getPips(High[highest_candle],Low[lowest_low_candle_no]));
               return highest_candle;
               
             
             };
            
            
     
     };
     
     return 0;



}



//lower dip    function starts here


int lower_dip(){

   //loop through all the past candles set by input 
   
            
     double curr_low = 100.0;
     double curr_high = 0;
      int temp_low_bar = 0;
      int high_bar_count = 0;
      int lowest_candle = 0;
      
      int highest_high_candle_no = 0;
         
     for(int i=1;i<candle_to_analyze;i++){
     
            Print("current count sell ",i);
     
            double candle_high = High[i];
            double candle_low =  Low[i];
            
            if(candle_low < curr_low){
            
                  curr_low = candle_low;
                  temp_low_bar = i;
                  lowest_candle = i;
                  high_bar_count = 0;
                  curr_high = candle_high;
            
               }
               
             else{
             
               if(candle_high > curr_high){
               
                  highest_high_candle_no = i;
                  curr_high = candle_high;
               
               }
             
               high_bar_count = high_bar_count+1;
             
             };
             
             
             //check if the condition has met or not
             
             if(high_bar_count >= minimum_left_side_candle && getPips(Ask,curr_low) >= pip_distance_from_current_price && getPips(curr_low,curr_high) >= minimum_left_side_distance_pip ){
               return lowest_candle;
               
             
             };
            
            
     
     };
     
     return 0;


}





//get pips function

double getPips(double price1,double price2)
  {

   if(MarketInfo(Symbol(),MODE_DIGITS)==5)
     {
     
     Print("price 1 is ",price1," and price 2 is ",price2);

      double pipDiff = (MathAbs(price1 - price2)*10000);
      
      Print("pip diff is ",pipDiff);

      return pipDiff;

     }


   else
      if(MarketInfo(Symbol(),MODE_DIGITS)==3)
        {

         double pipDiff = (MathAbs(price1 - price2)*100);

         return pipDiff;
        }





      else
        {

         return 0.00;


        }



  }
  
  
  double getLotSize(double pips,double amount)
  {

   //double riskamount = (AccountBalance()*0.01*risk_percentage);
   
   double riskamount = amount;

   double lot = 0.00;

   if(five_digit_broker == true)
     {
      lot = (riskamount/pips)/(MarketInfo(Symbol(),MODE_TICKVALUE)*10);

      return lot;

     }


   else
     {

      lot = (riskamount/pips)/(MarketInfo(Symbol(),MODE_TICKVALUE));

      return lot;

     }

  }
  
  
  
  //browse all the opened position and check for is order at the same price alraedy opened or not. If it returns false - that means there is no order opened at that price
  
  bool checkOrder(double entry_price){
  
  for(int i = 0 ; i < OrdersTotal() ; i++ ) { 
                // We select the order of index i selecting by position and from the pool of market/pending trades.
                OrderSelect( i, SELECT_BY_POS, MODE_TRADES ); 
                double open_price = OrderOpenPrice();
                Print("order open price is ",open_price);
                // If the pair of the order is equal to the pair where the EA is running.
                if (OrderSymbol() == Symbol() && open_price == entry_price ){
                
                  Print("match found ",open_price);
                  return true;
                
                } 
                
                
        } 
        
      return false;
  
  }