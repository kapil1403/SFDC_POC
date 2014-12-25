Public class HelloWorldPositionClass{
    Public static void HelloWorld(List<Position__c> p){
        // List<Position__c> p=new List<Position__c>();
        for(Integer i=0; i<p.size(); i++){
            p[i].Hello__c='World'; 
        }
    }
}