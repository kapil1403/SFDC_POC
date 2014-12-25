public class AccountLocation {
    
    @future(callout=true)
    static public void insertGeoLocation(Id accId){
        
        Account a = [select id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,Location__Latitude__s, Location__Longitude__s FROM Account WHERE id =:accId];
        
        //Creating Account address string
        string address = '';
        if(a.BillingStreet != null){
            address += a.BillingStreet +', ';
        }
        
        if(a.BillingCity != null){
            address += a.BillingCity +', ';
        }
        
        if(a.BillingState != null){
            address += a.BillingState +', ';
        }
        
        if(a.BillingCountry != null){
            address += a.BillingCountry +', ';
        }
        
        if(a.BillingPostalCode != null){
            address += a.BillingPostalCode;
        }
        
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        
        //build callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
        req.setMethod('GET');
        req.setTimeout(60000);
        
        try{
            //Callout
            HttpResponse res = new HttpResponse();
            res = h.send(req);
            system.debug('@@Response' + res);
            system.debug('@@Response_Boday' + res.getBody());
            
            JSONParser parser = JSON.createParser(res.getBody());
            double latitude = null;
            double longitude = null;
            
            while (parser.nextToken() != null) {
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){
                    parser.nextToken();
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if(txt == 'lat'){
                           latitude=parser.getDoubleValue();
                           system.debug('@@latitude' + latitude);
                        }
                        else if(txt == 'lng'){
                            longitude=parser.getDoubleValue();
                            system.debug('@@longitude' + longitude);
                        }
                    }
                }
            }
            
            if(latitude != null){
                a.Location__Latitude__s = latitude;
                a.Location__Longitude__s = longitude;
                update a;
            }
        
        }catch(Exception ex){
            system.debug('@@Exception' + ex);
        }
        
    }
}