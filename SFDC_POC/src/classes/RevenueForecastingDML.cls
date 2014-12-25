Public Class RevenueForecastingDML {

    Public void InsertUpdateRevenue(Map<Id, Opportunity> oldOpptyMap, Map<Id, Opportunity> newOpptyMap) {
        List<Revenue_Forecasting__c> revenueForList = new List<Revenue_Forecasting__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, List<OpportunityLineItem>> oliTempMap = new Map<Id, List<OpportunityLineItem>>();
        decimal differenceAmount=0;
        
        //Checking Opportunities for which No of Term, Amount Per Term, Revenue Start Date is changed
        for(Opportunity oppTemp : newOpptyMap.Values()) {
            if(oppTemp.No_of_Terms__c!=oldOpptyMap.get(oppTemp.Id).No_of_Terms__c || oppTemp.Amount_Per_Term__c!=oldOpptyMap.get(oppTemp.Id).Amount_Per_Term__c || oppTemp.Revenue_Start_Date__c!=oldOpptyMap.get(oppTemp.Id).Revenue_Start_Date__c){
                oppList.add(oppTemp);
            }
        }
        
        if(oppList.size()>0){
            
            //Retrieveing Revenue Forecatsing List
            revenueForList = [Select Opportunity_Name__c, Id, Name from Revenue_Forecasting__c where Opportunity_Name__c IN :oppList ORDER BY Opportunity_Name__c];
            
            //Delete Existing RevenueForecasting Record
            if(revenueForList.size()>0){
                try{
                    delete revenueForList;
                }catch (Exception e){
                    system.debug('@@Exception' + e);
                }
            }
            
            //Clearing Revenue Forecasting List for reusing
            revenueForList.clear();
            
            //Fetching Opportunity Line Item where TotalPrice not equal to zero
            for(OpportunityLineItem oli : [select Id, PricebookEntryId, PricebookEntry.Product2Id, TotalPrice, ListPrice, UnitPrice, OpportunityId, Product_Name__c from OpportunityLineItem where OpportunityId IN :oppList and TotalPrice!=0]){
                List<OpportunityLineItem> opptyLineItemList = oliTempMap.get(oli.OpportunityId);
                if(opptyLineItemList==NULL){
                    opptyLineItemList = new List<OpportunityLineItem>();
                    oliTempMap.put(oli.OpportunityId, opptyLineItemList);
                }
                opptyLineItemList.add(oli);
                system.debug('@@OpptyLineItemList' + opptyLineItemList);
            }
            system.debug('@@OpptyLineItemMap' + oliTempMap);
            
            //Checking if opportunity line item exists then only create revenue records
            if(oliTempMap.size()>0){
                //Creating Revenue Forecast for Opportunity per Opportunity Line Item
                for(Opportunity opp : oppList){
                  if(opp.No_of_Terms__c!=NULL && opp.Amount_Per_Term__c!=NULL && opp.Revenue_Start_Date__c!=NULL){  
                    
                    differenceAmount =0;
                    
                    //Decimal dayInt = (date.daysInMonth((ConvertDateToDateTime(opp.Revenue_Start_Date__c).year()),(ConvertDateToDateTime(opp.Revenue_Start_Date__c)).month())-(ConvertDateToDateTime(opp.Revenue_Start_Date__c).day()));
                    
                    //Calculating Number of Days for first Month for which Revenue generates
                    Decimal firstMonthDays = (date.daysInMonth((ConvertDateToDateTime(opp.Revenue_Start_Date__c).year()),(ConvertDateToDateTime(opp.Revenue_Start_Date__c)).month())) - (ConvertDateToDateTime(opp.Revenue_Start_Date__c).day())+1;
                    
                    //Calculating Number of Days for Last Month for which Revenue generates
                    Decimal lastMonthDays = (date.daysInMonth((ConvertDateToDateTime(opp.Revenue_Start_Date__c).year()),(ConvertDateToDateTime(opp.Revenue_Start_Date__c)).month())) - firstMonthDays;
                    //Getting Total of Days for Opportunity
                    Decimal totalNoOfDays = 0;
                    
                    for(integer i=0; i<opp.No_of_Terms__c; i++){
                        totalNoOfDays = date.daysInMonth((ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i).year()),(ConvertDateToDateTime(opp.Revenue_Start_Date__c)).addMonths(i).month()) + totalNoOfDays;
                    }
                    
                    //Amount per Day
                    Decimal amountPerDay = opp.Amount_Per_Term__c/totalNoOfDays;
                    
                    //Calculating Revenue per Term per Opportunity Line Item
                    for(integer i=0; i<=opp.No_of_Terms__c; i++){
                        
                        //For 1st Month
                        if(i==0){
                            differenceAmount = differenceAmount+(firstMonthDays*amountPerDay).SetScale(2);
                            for(OpportunityLineItem oli : oliTempMap.get(opp.Id)){
                                Revenue_Forecasting__c rev = new Revenue_Forecasting__c();
                                
                                //Assigning Values to Revenue Fields
                                rev.Opportunity_Name__c = opp.Id;
                                rev.Revenue_Start_Date__c = opp.Revenue_Start_Date__c;
                                rev.Revenue_Month__c = ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i).format('MMMMM');      
                                rev.Revenue_Amount__c = (oli.TotalPrice*(firstMonthDays*amountPerDay)/opp.Amount).SetScale(2);
                                rev.Product_Name__c = oli.Product_Name__c;
                                
                                revenueForList.add(rev);
                            }
                        }
                        //For Last Record
                        else if(i==opp.No_of_Terms__c){
                            
                            //To check if Revenue Start date is started from 1st of Month
                            if(lastMonthDays == 0) {
                                break;
                            }
                            else {
                                for(opportunityLineItem oli : oliTempMap.get(opp.Id)){
                                    Revenue_Forecasting__c rev = new Revenue_Forecasting__c();
                                    //Assigning Values to Revenue Fields
                                    rev.Opportunity_Name__c = opp.Id;
                                    //rev.Revenue_Start_Date__c = ConvertDateTimeToDate((ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i-1)));
                                    rev.Revenue_Start_Date__c = opp.Revenue_Start_Date__c.addMonths(i);
                                    rev.Revenue_Month__c = ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i).format('MMMMM');
                                    rev.Revenue_Amount__c = (oli.TotalPrice*(lastMonthDays*amountPerDay)/opp.Amount).SetScale(2);
                                    rev.Product_Name__c = oli.Product_Name__c;

                                    revenueForList.add(rev);
                                }
                            }
                        }
                        
                        else {
                            for(opportunityLineItem oli : oliTempMap.get(opp.Id)){
                                Revenue_Forecasting__c rev = new Revenue_Forecasting__c();
                                //Assigning Values to Revenue Fields
                                rev.Opportunity_Name__c = opp.Id;
                                //rev.Revenue_Start_Date__c = ConvertDateTimeToDate((ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i-1)));
                                rev.Revenue_Start_Date__c = opp.Revenue_Start_Date__c.addMonths(i);
                                rev.Revenue_Month__c = ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i).format('MMMMM');
                                rev.Revenue_Amount__c = (oli.TotalPrice*(date.daysInMonth((ConvertDateToDateTime(opp.Revenue_Start_Date__c).addMonths(i).year()),(ConvertDateToDateTime(opp.Revenue_Start_Date__c)).addMonths(i).month())*amountPerDay)/opp.Amount).SetScale(2);
                                rev.Product_Name__c = oli.Product_Name__c;
                                
                                revenueForList.add(rev);
                            }
                        }
                    }
                }
                
                //Insert Revenue List
                if(revenueForList.size()>0){
                    try {
                        insert revenueForList;
                    }catch (Exception ex){
                        system.debug('@@RevenueList' + ex);
                    }
                }
              }  
            }
        }
    }
    
     /**
     * @description This method converts DateTime value to Date value
     */
    public date ConvertDateTimeToDate(datetime dt){
        Date d = Date.newInstance(dt.year(),dt.Month(),dt.day());
        return d;
    }
    
    /**
     * @description This method converts Date value to DateTime value
     */
    public datetime ConvertDateToDateTime(date d){
        DateTime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        return dt;
    }
}