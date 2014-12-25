global with sharing class FindNearbyController {
    
    public String objName {get; set;}
    public String distance {get; set;}
    public String maptype {get; set;}
    public String searchText {get; set;}
    //public static List<Account> accList {get; set;}
    public static List<sObject> List_Sobj {get; set;}
    
    //public static String queryString;
    
    public FindNearbyController() { }
        
    //public FindNearbyController(ApexPages.StandardSetController controller) { }
    
    public List<SelectOption> getObjNameList() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Account', 'Account'));
        options.add(new SelectOption('Lead', 'Lead'));
        options.add(new SelectOption('Contact', 'Contact'));

        return options;    
    }
    
    @RemoteAction
    // Find Account nearest a geolocation
    global static List<sObject> getNearby(String lat, String lon, String objName) {
        String tempQueryString;
        // SOQL query to get the nearest Account
        if(objName=='Account'){
            tempQueryString = 'BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,Phone FROM Account';
        }
        else if(objName=='Lead' || objName==null ){
        
             tempQueryString = 'Street, City, State, Country, PostalCode,Phone FROM Lead';
             System.debug('@@selected is Lead'+tempQueryString );
             
        } else if(objName== 'Contact'){
        
             tempQueryString = 'MallingStreet, MallingCity, MallingState, Mallingountry, MallingPostalCode,Phone FROM Contact';
        }   
        
            String queryString = 'SELECT Id, Name, Location__Longitude__s, Location__Latitude__s, ' +tempQueryString+ ' '+
            'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 25 ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
            'LIMIT 20';
            system.debug('@@queryString' + queryString);
             
            /*accList = new List<Account>();
            accList = database.Query(queryString);
            system.debug('@@accList' + accList);
            return accList;*/
            List_Sobj= new List<sObject>();
            List_Sobj= database.Query(queryString);
            system.debug('@@accList' + List_Sobj);
            return List_Sobj;

        // Run and return the query results
        //return(database.Query(queryString));
    }
    
    //Auto Complete
    @RemoteAction
    global static List<SObject> getData(String sObjVal,String searchText){
        //param = String.escapeSingleQuotes(param);
        return Database.query('SELECT name FROM '+sObjVal+' WHERE name LIKE \'%'+searchText+'%\'');
    }
    
}