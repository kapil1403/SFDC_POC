global with sharing class FindNearbyAccount {

    public FindNearbyAccount(ApexPages.StandardSetController controller) { }

    @RemoteAction
    // Find Account nearest a geolocation
    global static List<Account> getNearby(String lat, String lon) {

        // SOQL query to get the nearest Account
        String queryString = 'SELECT Id, Name, Location__Longitude__s, Location__Latitude__s, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,Phone FROM Account ' +
            'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
            'LIMIT 20';

        // Run and return the query results
        return(database.Query(queryString));
    }
}