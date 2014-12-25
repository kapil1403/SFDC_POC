Public without sharing class RevenueMassEditExtension{
    
    public List<Revenue_Forecasting__c> revenueForList{get;set;}
    public List<Revenue_Forecasting__c> notSelectedRevenueList;
    public Decimal opptyTermAmount{get;set;}
    public Decimal revenueAmount{get;set;}
    public boolean updateVFPagesuccessfully{get;set;}
    public boolean noRecordSelected{get;set;}
    
    //Constructor
    public RevenueMassEditExtension(ApexPages.StandardSetController stdController){
        
        try{
            updateVFPagesuccessfully=false;
            noRecordSelected=false;
            revenueForList=stdController.getSelected();
            
            if(revenueForList.size()==0){
                noRecordSelected=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Revenue_Mass_Edit_No_Record_Selected));
            }
            else{
                notSelectedRevenueList=[select Id,Opportunity_Name__c,Revenue_Month__c,Revenue_Amount__c,Product_Name__c,Opportunity_Name__r.Amount_Per_Term__c from Revenue_Forecasting__c where Opportunity_Name__c=:revenueForList[0].Opportunity_Name__c and Id NOT IN :revenueForList];
                opptyTermAmount=revenueForList[0].Opportunity_Name__r.Amount_Per_Term__c;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getLineNumber()));
        }
    }
    
    //Method for checking Amount
    public pageReference checkRevenueAmount(){
        
        boolean updateSuccessfully = true;
        
        Decimal revenueAmount=0;
        
        for(Revenue_Forecasting__c rev : revenueForList){
            if(rev.Revenue_Amount__c==NULL)rev.Revenue_Amount__c=0;
            revenueAmount=rev.Revenue_Amount__c+revenueAmount;
        }
        
        if(notSelectedRevenueList.size()>0){
        
            for(Revenue_Forecasting__c revNotSelected : notSelectedRevenueList){
                if(revNotSelected.Revenue_Amount__c==NULL)revNotSelected.Revenue_Amount__c=0;
                revenueAmount=revNotSelected.Revenue_Amount__c+revenueAmount;
            }
        }
        
        //Checking Oppty Term Amount is equal to opptyTermAmount
        if(revenueAmount!=opptyTermAmount){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please correct the entered Revenue Amount. The Difference is '+(revenueAmount-opptyTermAmount)));
        }
        else{
            try{
                update revenueForList;
            }catch (Exception e){
                updateSuccessfully=false;
                system.debug('@@Update Revenue xception' + e);
            }
            if(updateSuccessfully){
                updateVFPagesuccessfully=true;
            }
        }
        
        return null;
    }
    
    //click on the return button 
    public pageReference ReturnOpp(){
        PageReference pageRef = new PageReference('/'+revenueForList[0].Opportunity_Name__c);
        return pageRef;
    }
}