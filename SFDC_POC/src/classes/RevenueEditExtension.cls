public with sharing class RevenueEditExtension {
    
    
    public Id revenueID;
    public String profileStr  ;
    
    //Constructor

    public RevenueEditExtension (ApexPages.StandardController stdController){
        try{
        
           revenueID = stdController.getId();
           User usr = [select Id, Profile.Name from User where Id=:userInfo.getUserId()];
           profileStr = usr.Profile.Name;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getLineNumber()));
        }
    }
    
        
    public PageReference RevenueUpdate (){
    
        PageReference pRef = null;
        String urlStr;
        
        //Checking if the profile is not System Admin , don't allow the user to update records  
        if(profileStr!='System Administrator'){
           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Revenue_Edit_Not_Editable)); 
        
        //Redirect the system admin to standard editable record
        }else{
        
            urlStr= '/'+revenueID+'/e?nooverride=1&retURL='+revenueID;
            pRef = new PageReference(urlStr);
        }
       
        return pRef;
    }
}