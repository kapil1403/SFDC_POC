Public with sharing Class ProfilewiseObjectPermissionController{
    //public List<ObjectPermissions> objPermission {get; set;}
    //public Map<String, String> objPermission {get; set;}
    //public Map<String, List<ObjectPermissions>> profileObjectPerMap {get; set;}
    public Map<String, List<String>> profileObjectPerMap {get; set;}
    
    //Constructor
    Public ProfilewiseObjectPermissionController(){
        
        //Declare Variables
        Map<Id, PermissionSet> profilePermissionSetMap = new Map<Id, PermissionSet>();
        //profileObjectPerMap = new Map<String, List<ObjectPermissions>>();
        profileObjectPerMap = new Map<String, List<String>>();
        Set<Id> permissionSetIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        //objPermission = new Map<String, String>();
        //String Permission;
        
        //Retrieveing All Profiles
        for(Profile profile : [select Id, Profile.Name from Profile]){
            profileIdSet.add(profile.Id);
        }
        
        //
        for(PermissionSet per : [select Id, Profile.Name, ProfileId from PermissionSet where ProfileId IN :profileIdSet]){
            profilePermissionSetMap.put(per.Id, per);
            permissionSetIdSet.add(per.Id);
        }
        
        for(ObjectPermissions objPer : [select ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsModifyAllRecords, PermissionsViewAllRecords from ObjectPermissions where ParentId IN :permissionSetIdSet order by ParentId]){
           
           if(profileObjectPerMap.containskey(profilePermissionSetMap.get(objPer.ParentId).Profile.Name)){
               //List<ObjectPermissions> objPerTempList = profileObjectPerMap.get(profilePermissionSetMap.get(objPer.ParentId).Profile.Name);
               List<String> objPerTempList = profileObjectPerMap.get(profilePermissionSetMap.get(objPer.ParentId).Profile.Name);
               //objPerTempList.add(objPer);
               String permissionStr='';
           
               if(objPer.PermissionsCreate){
                   permissionStr='C ';
               }
               if(objPer.PermissionsRead){
                   permissionStr+='R ';
               }
               if(objPer.PermissionsEdit){
                   permissionStr+='U ';
               }
               if(objPer.PermissionsDelete){
                   permissionStr+='D ';
               }
               if(objPer.PermissionsModifyAllRecords){
                   permissionStr+='MAll ';
               }
               if(objPer.PermissionsViewAllRecords){
                   permissionStr+='VAll';
               }
               permissionStr=permissionStr.trim();
               
               objPerTempList.add(permissionStr);
               profileObjectPerMap.put(profilePermissionSetMap.get(objPer.ParentId).Profile.Name, objPerTempList);
           }else{
              //List<ObjectPermissions> objPerTempList = new List<ObjectPermissions>();
              //objPerTempList.add(objPer);
              List<String> objPerTempList = new List<String>();
              String permissionStr='';
           
               if(objPer.PermissionsCreate){
                   permissionStr='C ';
               }
               if(objPer.PermissionsRead){
                   permissionStr+='R ';
               }
               if(objPer.PermissionsEdit){
                   permissionStr+='U ';
               }
               if(objPer.PermissionsDelete){
                   permissionStr+='D ';
               }
               if(objPer.PermissionsModifyAllRecords){
                   permissionStr+='MAll ';
               }
               if(objPer.PermissionsViewAllRecords){
                   permissionStr+='VAll';
               }
               permissionStr=permissionStr.trim();
                              
               objPerTempList.add(permissionStr);
               profileObjectPerMap.put(profilePermissionSetMap.get(objPer.ParentId).Profile.Name, objPerTempList);
           }   
        }
        system.debug('@@profileObjectPerMap' + profileObjectPerMap);    
    }
        
}