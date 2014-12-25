/**
  * @author Original: Kapil Baliyan (502221916) TCS/GEHC, Last Modified: Kapil Baliyan (502221916) TCS/GEHC
  * @date Original: 07 July 2014, Last Modified: 07 July 2014
  * @description Opportunity Forecasting RollUp Page Controller
*/

global with sharing class DepartmentTrackerController {
    
    global class CRUDResponse {
        public Boolean success;
        public String errorMessage;
        public List<SObject> records;
        public Integer total;
        CRUDResponse() {
            records = new List<SObject>();
            success = true;
        }
    }
    
    // a user-defined class that will serialize to the JSON expected by the ExtJS DirectProxy api methods
    global class ListResponse {
        public Boolean success;
        public String errorMessage;
        public List<Map<String,String>> records;
        public Integer total;
        ListResponse() {
            records = new List<Map<String,String>>();
            success = true;
        }
    } 
    
    // Unfortunately JS Remoting member functions must be static, so cannot access non-static class members,
    // which means we cannot cache query results in this controller but must respond to each request anew
    /*global class QueryObj {
        public List<Map<String, String> > filterParams;
        public String filter;
        public Integer start;
        public Integer recordCount;
        public List<Map<String, String> > sortParams;
    }*/
    
    global class QueryObj {
        public List<Map<String, String> > filterParams;
        public List<Map<String, String> > filters;
        public String filter;
        public Integer start;
        public Integer recordCount;
        public List<Map<String, String> > sortParams;
    }

    global class CellEditObj {
        public List<Map<String, String> > records;
    }
    
    global class SearchQueryObj {
        public Integer start;
        public Integer recordCount;
        public String searchStr;
        public String obj;
        public String field;
        public String filter;
        public List<Map<String, String> > filterParams;
        public String query;
        
    }
    
    public static String getUserId(){
        SObject user = [select Id from User where id = :UserInfo.getUserId() LIMIT 1];
        return String.valueOf(user.get('Id'));
    }

    // return account list for filter autocomplete
    @RemoteAction
    global static CRUDResponse getObjAutocomplete(SearchQueryObj sqobj){
        String qstr = 'SELECT id, name from '+ sqobj.obj +' ';
        if(sqobj.searchStr != null && sqobj.searchStr != ''){
            String search = String.escapeSingleQuotes(sqobj.searchStr);
            qstr +=  ' WHERE name LIKE \'%'+search+'%\' ';
            qstr += ' LIMIT 15';
        }else{
            qstr += ' LIMIT 0';
        }       
        List<SObject> results = Database.query(qstr);      
        SObject firstItem = new Account();
        firstItem.put('Name', sqobj.searchStr);
        firstItem.put('Id', sqobj.searchStr);
        results.add(0, firstItem);
        CRUDResponse tmp = new CRUDResponse();
        tmp.records = results;
        //tmp.errorMessage = qstr;
        return tmp;
    }
    
    // Auto Field Complete Method
    @RemoteAction
    global static ListResponse getFieldAutocomplete(SearchQueryObj sqobj){
        system.debug('@@Inside Autocomplete' + sqobj);
        String obj = String.escapeSingleQuotes(sqobj.obj);
        String filter = '';
        if(sqobj.filter != null){
            filter = String.escapeSingleQuotes(sqobj.filter);
        }
        String field = String.escapeSingleQuotes(sqobj.field);
        List<Map<String, String>> results = new List<Map<String, String>>();      
        String query = '';
        

        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sobjToken = objTypeMap.get(obj);
        Map<String, Schema.SObjectField> fieldMap = sobjToken.getDescribe().fields.getMap();
        String search;
        Map<String, String> firstItemresultMap = new Map<String, String>();        
        if(sqobj.searchStr != null && sqobj.searchStr != ''){
            search = String.escapeSingleQuotes(sqobj.searchStr);
            if(search!='' && obj != 'Global_Release_Sprint_Setting__c'){  
                firstItemresultMap.put('id',search);
                firstItemresultMap.put('text',search);
                results.add(firstItemresultMap);
            }             
        }

        if(obj == 'Global_Release_Sprint_Setting__c'){
            query = 'Select '+field+' From '+obj;
            if(filter != ''){
                if(field == 'Sprint__c'){
                    query += ' WHERE ';
                    List<String> parts = filter.split(', ');
                    if(parts.size() > 1){
                        query += field;
                        query += ' IN (';
                        for(string s : filter.split(',')){
                            query += '\''; 
                            query += s.trim(); 
                            query += '\','; 
                        }
                         query = query.subString(0,query.Length()-1);
                        //optyLineItemWhereString += val.split(',');
                        query += ') ';
                    }else{
                        query += 'Release__c = \''+filter+'\' ';
                    }      
                }
            }
            List<SObject> tmpR = Database.query(query);           
            system.debug('@@getAutoComplete' + query);
            for(SObject so:tmpR){   
                String temp = String.valueOf(so.get(field));
                if((temp != null && search == null ) ||(temp != null  && temp.containsIgnoreCase(search))){                   
                    Map<String, String> resultMap = new Map<String, String>();
                    resultMap.put('id',temp);
                    resultMap.put('text',temp);
                    results.add(resultMap);                  
                }
            }

        }else if(obj == 'Development_Tracker__c' && field == 'Component_Name__c'){
            query = 'Select '+field+' From '+obj;
            if(filter != '' && filter == 'ApexClass'){
                field = 'Name';
                query = 'Select Name from ApexClass';
                //query += ' WHERE ';
                //query += 'Release__c = \''+filter+'\' ';
            }else if(filter != '' && filter == 'ApexPage'){
                field = 'Name';
                query = 'Select Name from ApexPage';
                //query += ' WHERE ';
                //query += 'Release__c = \''+filter+'\' ';
            }else if(filter != '' && filter == 'ApexComponent'){
                field = 'Name';
                query = 'Select Name from ApexComponent';
                //query += ' WHERE ';
                //query += 'Release__c = \''+filter+'\' ';
            }
            system.debug('@@ComName query' + query);
            List<SObject> tmpR = Database.query(query);           
            system.debug('@@getAutoComplete' + query);
            for(SObject so:tmpR){   
                String temp = String.valueOf(so.get(field));
                if((temp != null && search == null ) ||(temp != null  && temp.containsIgnoreCase(search))){                   
                    Map<String, String> resultMap = new Map<String, String>();
                    resultMap.put('id',temp);
                    resultMap.put('text',temp);
                    results.add(resultMap);                  
                }
            }

        }else if (field != 'Id' && fieldMap.get(field).getDescribe().getType() == Schema.DisplayType.Picklist) {
            List<Schema.PicklistEntry> r = fieldMap.get(field).getDescribe().getPicklistValues();
            System.debug('***TJ*** Size:'+r.size());
                      
            for(Integer i = 0;i<r.size();i++){
                String temp = r[i].getValue();
                if((temp != null && search == null ) ||(temp != null  && temp.containsIgnoreCase(search))){                   
                    Map<String, String> resultMap = new Map<String, String>();
                    resultMap.put('id',temp);
                    resultMap.put('text',temp);
                    results.add(resultMap);                      
                }
            }
        }else{
        system.debug('@@else' + field);
            query = 'Select '+field+' From '+obj;
            
            query += ' ORDER BY'+' ' + field ;
            query += ' limit 3000' ;
            System.debug('***TJ*** Size:comparison'+ query);
            List<SObject> tmpR = Database.query(query);           
            system.debug('@@PN Comparison '+tmpR);

            for(SObject so:tmpR){   
                String temp = String.valueOf(so.get(field));
                if((temp != null && search == null ) ||(temp != null  && temp.containsIgnoreCase(search))){                   
                    Map<String, String> resultMap = new Map<String, String>();
                    resultMap.put('id',temp);
                    resultMap.put('text',temp);
                    results.add(resultMap);                                     
                }  
            }
        }       
        ListResponse tmp = new ListResponse();
        tmp.records = results; 
        tmp.errorMessage = query;
        system.debug('@@swap' + tmp+'@PN results'+results);    
        return tmp;
    }
    
    
    @ReadOnly
    @RemoteAction
    global static CRUDResponse query(QueryObj qobj) {
        system.debug('@@qobj' + qobj);
        CRUDResponse resp = new CRUDResponse();
        //Object for query
        String obj = 'Development_Tracker__c';    
        //Filter parameterrs from column headers
        List<Map<String, String>> columnFilterParams = null;
        if (qobj.filter != null) {
            //Parse grid column filters from JSON text into objects
            columnFilterParams = parseFilterResponse(qobj.filter);
        }
        System.debug('@@SWAP' + columnFilterParams );
        //Filter parameters from grid store
        List<Map<String, String>> storeFilterParams = qobj.filterParams;
        List<Map<String, String>> extraFilterParams = qobj.filters;
        System.debug('@@SWAP' + storeFilterParams + '3' + extraFilterParams );
        Map<String, String> whereString = generateWhere(storeFilterParams, extraFilterParams);
        system.debug('@@whereString' + whereString);
        //Field String for query
        String fields = 'Id,Component_Name__c, Component_Type__c, Component_Status__c,Release__c, Sprint__c,Owner.Name';
        // construct two queries: 1. Count query  2. Field query
        String countstr = 'SELECT COUNT() FROM ' + obj;
        String  qstr = 'SELECT ' + fields + ' FROM ' + obj;
        
        //List<User> usrList = null;
        //usrList = [select id from User where id=:UserInfo.getUserId() LIMIT 1];
        
        countstr += ' WHERE ';
        countstr += whereString.get('DevTracker');
        System.debug('@@SWAP1' + countstr);
        if(countstr.contains('WHERE  AND'))
           countstr = countstr.replaceFirst('WHERE  AND', 'WHERE '); 
        //countstr += ' AND OwnerId = :usrList';
        System.debug('@@SWAP' + countstr);
        resp.total = Database.countQuery(countstr);   // ExtJS grid needs the true total here
        qstr += ' WHERE ';
        qstr += whereString.get('DevTracker');
        if(qstr.contains('WHERE  AND'))
           qstr = qstr.replaceFirst('WHERE  AND', 'WHERE '); 
        
        if (qobj.sortParams != null) {
            qstr += ' ORDER BY ';          
            qstr += qobj.sortParams[0].get('property');          
            // SOQL only supports a single direction, so ignoring others. Probably should return error instead.
            qstr += ' ' + qobj.sortParams[0].get('direction') + ' NULLS LAST ';
        }else{
            qstr += ' ORDER BY LastModifiedDate DESC NULLS LAST ';
        }
        System.debug('@@QUERY STRING:: '+qstr);
        System.debug('@@countstr '+countstr);      
        // data reduction: LIMIT and OFFSET
        // calculate the index of the first record returned by the query
        // OFFSET has some tricky limitations.  First, the maximum value is 2000, so if the first desired record
        // is beyond that point we will have to access some records we don't want.  Second, the use of OFFSET
        // causes the maximum number of records returned to be 200 - this appears to be undocumented.
        Integer startrec = 0;
        if (qobj.recordCount > 200) {
            // cannot use OFFSET; start at zero and include records before our desired region
            Integer reclimit = qobj.start + qobj.recordCount;
            qstr += ' LIMIT ' + String.valueOf(reclimit);
        } else {
            startrec = Math.min(qobj.start, 2000);
            // record count to get is the sum of the mandatory unwanted records (those over 2000) and those we want
            Integer reclimit = (qobj.start - startrec) + qobj.recordCount;
            qstr += ' LIMIT ' + String.valueOf(reclimit);
            //qstr += ' OFFSET ' + String.valueOf(startrec);
        }      
        Integer current_result = startrec;        // initialize with the true offset

        try {
            for (Development_Tracker__c rlit : Database.query(qstr)) {               
                    system.debug('@@rlit' + rlit);
                    system.debug('@@current_result' + current_result);
                    if ((current_result >= qobj.start) && (current_result < (qobj.start + qobj.recordCount))) {
                        system.debug('@@rlit1' + rlit);
                        resp.records.add(rlit);
                        }
                    }
                    current_result++ ;               
        } catch (Exception e) {
            system.debug('@@Exception' + e);
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage() + '|' + e.getLineNumber();  //debugging - remove before prod
            return resp;
        }
        //resp.errorMessage = '  QUERY:'+qstr;  //debugging - remove before prod
        system.debug('@@resp' + resp);
        return resp;
    }
    // "update" and "delete" are keywords so must pick something else
    // Ken Thompson is supposed to have said that if he could redo anything about Unix,
    // he'd spell "creat" with an extra "e".  So in that spirit:
    
    @RemoteAction
    global static CRUDResponse updat(CellEditObj ceo) {
        CRUDResponse resp = new CRUDResponse();
        Boolean Flag = False ;
        Map<String, String> recmap = ceo.records[0]; // [Id,"10002332222"][Manager_Forecast_Category__c  Upside]
        Set <String> KeySet = recmap.keySet();  
        system.debug('@@recmap' + recmap);
        system.debug('@@KeySet' + KeySet);
        
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sobjToken = objTypeMap.get('Development_Tracker__c');
        SObject sobj = sobjToken.newSObject(recmap.get('Id'));
        system.debug('@@sobj' + sobj);
        Map<String, Schema.SObjectField> fieldMap = sobjToken.getDescribe().fields.getMap();
        for (String k : recmap.keySet()) {
            Boolean emptyValue = (recmap.get(k) == null) || (recmap.get(k) == '') ||
                                 (fieldMap.get(k).getDescribe().getType() != Schema.DisplayType.string) &&
                                 (recmap.get(k) == 'null');

                if (k != 'Id') {
                    if (emptyValue) {
                        sobj.put(k, null);
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.date) {
                        // Date fields appear to need to be set from Date values, not strings, so:
                        sobj.put(k, Date.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.boolean) {
                        sobj.put(k, Boolean.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.integer) {
                        sobj.put(k, Integer.valueOf(recmap.get(k)));
                    } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.double) {
                        sobj.put(k, Double.valueOf(recmap.get(k)));
                    }
                      else
                         sobj.put(k, recmap.get(k));
                     // TODO: handle other types, esp. Currency
                }
        }
        system.debug('@@sobj' + sobj);
        try {
            update sobj;
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'update: failed with error ' + e.getMessage();
            return resp;
        }
        system.debug('@@Updateresp' + resp);
        return resp;
    }
    
    @RemoteAction
    global static CRUDResponse creat(CellEditObj ceo) {
        CRUDResponse resp = new CRUDResponse();
        Boolean Flag = False ;
        Map<String, String> recmap = ceo.records[0];
        /*if(recmap.containsKey('Owner.Name')){
            recmap.remove('Owner.Name');
            recmap.put('OwnerId',getUserId());
        }*/
        Set <String> KeySet = recmap.keySet();  
        system.debug('@@recmapIns' + recmap);
        system.debug('@@KeySetIns' + KeySet);
        
        
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sobjToken = objTypeMap.get('Development_Tracker__c');
        //SObject sobj = sobjToken.newSObject(recmap.get('Id'));
        SObject sobj = sobjToken.newSObject();
        Map<String, Schema.SObjectField> fieldMap = sobjToken.getDescribe().fields.getMap();
        system.debug('@@fieldMap' + fieldMap);
        for (String k : recmap.keySet()) {
            Boolean emptyValue = (recmap.get(k) == null) || (recmap.get(k) == '') ||
                                 (fieldMap.get(k).getDescribe().getType() != Schema.DisplayType.string) &&
                                 (recmap.get(k) == 'null');
                if(k != 'Owner.Name'){
                    if (k != 'Id') {
                        if (emptyValue) {
                            sobj.put(k, null);
                        } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.date) {
                            // Date fields appear to need to be set from Date values, not strings, so:
                            sobj.put(k, Date.valueOf(recmap.get(k)));
                        } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.boolean) {
                            sobj.put(k, Boolean.valueOf(recmap.get(k)));
                        } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.integer) {
                            sobj.put(k, Integer.valueOf(recmap.get(k)));
                        } else if (fieldMap.get(k).getDescribe().getType() == Schema.DisplayType.double) {
                            sobj.put(k, Double.valueOf(recmap.get(k)));
                        }
                          else
                             sobj.put(k, recmap.get(k));
                         // TODO: handle other types, esp. Currency
                    }
                }
        }
        sobj.put('OwnerId', getUserId());
        system.debug('@@sobj' + sobj);
        try {
            insert sobj;
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'update: failed with error ' + e.getMessage();
            return resp;
        }
        system.debug('@@Updateresp' + resp);
        return resp;
    }

    //Generate Where Function
    static Map<String,String> generateWhere(List<Map<String, String> > storeFilters, List<Map<String, String> > gridFilters){
        Map<String, String> whereResponse = new Map<String, String>();
        String devTrWhereString = '';
        system.debug('@@storeFilters' + storeFilters);
                      
        // Process store filters
        
        if (storeFilters != null) {       
            // collect sort fields/directions
            for (Integer i = 0; i < storeFilters.size(); i++) {
                String val = storeFilters[i].get('value');
                String field = storeFilters[i].get('property');
                if(val != null && val != '' && field != null){
                    val = String.escapeSingleQuotes(val);
                    field = String.escapeSingleQuotes(field);
                    devTrWhereString += ' AND ';
                    devTrWhereString += field;
                    devTrWhereString += ' = \'';
                    devTrWhereString += val;
                    devTrWhereString += '\' ';
                    /*devTrWhereString += ' AND ';
                    devTrWhereString += 'Component_Status__c';
                    devTrWhereString += ' = \'';
                    devTrWhereString += 'Checked In';
                    devTrWhereString += '\' ';
                    devTrWhereString += 'AND ';
                    devTrWhereString += 'OwnerId';
                    devTrWhereString += ' = \'';
                    devTrWhereString += getUserId();
                    devTrWhereString += '\' ';*/
                }else {
                    
                }
            }
            devTrWhereString += ' AND ';
            devTrWhereString += 'Component_Status__c';
            devTrWhereString += ' = \'';
            devTrWhereString += 'Checked In';
            devTrWhereString += '\' ';
            devTrWhereString += 'AND ';
            devTrWhereString += 'OwnerId';
            devTrWhereString += ' = \'';
            devTrWhereString += getUserId();
            devTrWhereString += '\' ';
        }else{
            system.debug('@@ On Page Load');
            devTrWhereString += ' AND ';
            devTrWhereString += 'Component_Status__c';
            devTrWhereString += ' = \'';
            devTrWhereString += 'Checked In';
            devTrWhereString += '\' ';
            devTrWhereString += 'AND ';
            devTrWhereString += 'OwnerId';
            devTrWhereString += ' = \'';
            devTrWhereString += getUserId();
            devTrWhereString += '\' ';
            
        }

        whereResponse.put('DevTracker', devTrWhereString);
        return whereResponse;
    }
    
    static List<Map<String, String> > parseFilterResponse(String input) {        
        JSONParser parser = JSON.createParser(input);
        System.debug('**TJ** Entered Parser');
        List<Map<String, String>> rtrn = new List<Map<String, String>>();       
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                Map<String, String> tmap = new Map<String, String>();
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String field = parser.getText();
                        parser.nextToken();
                        String value = '';
                        if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                            System.debug('**TJ** Entered list processer');
                            while (parser.nextToken() != null) {
                                System.debug('**TJ** LIST PROCESSOR LOOP!');
                                if (parser.getCurrentToken() == JSONToken.VALUE_FALSE ||
                                    parser.getCurrentToken() == JSONToken.VALUE_NULL ||
                                    parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT ||
                                    parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT ||
                                    parser.getCurrentToken() == JSONToken.VALUE_STRING ||
                                    parser.getCurrentToken() == JSONToken.VALUE_TRUE
                                    ) {
                                    if(value != ''){
                                        value += ', ';
                                    }
                                    if(parser.getText() == 'null'){
                                        System.debug('**TJ** LIST PROCESSOR FOUND NULL');
                                        value += '\'\'';
                                    }else{
                                        System.debug('**TJ** LIST PROCESSOR FOUND VALUE');
                                        value += '\''+String.escapeSingleQuotes(parser.getText())+'\'';
                                    }
                                    
                                }else if(parser.getCurrentToken() == JSONToken.END_ARRAY){
                                    break;
                                }
                            }
                            value = '('+value+')';
                        }else{
                            value = parser.getText();
                        }
                        tmap.put(field, value);                       
                    }
                    else{
                       rtrn.add(tmap);
                       break;
                    }
                }
                rtrn.add(tmap);
            }
        }
        return rtrn;
    }
}