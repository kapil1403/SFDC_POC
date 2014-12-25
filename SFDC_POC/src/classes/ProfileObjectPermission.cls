Public with sharing class ProfileObjectPermission{

    //Constructor
    public ProfileObjectPermission(ApexPages.StandardSetController stdController){
    
    }
    
    //Method for retrieveing All Object Settings
    public pageReference retrieveAllSetings(){
        List<ProfileWiseObjectPermission__c> profileObjectSettingList = new List<ProfileWiseObjectPermission__c>();
        Map<Id, PermissionSet> profilePermissionSetMap = new Map<Id, PermissionSet>();
        Set<Id> permissionSetIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        for(Profile profile : [select Id, Profile.Name from Profile]){
            profileIdSet.add(profile.Id);
        }
        for(PermissionSet per : [select Id, Profile.Name, ProfileId from PermissionSet where ProfileId IN :profileIdSet]){
            profilePermissionSetMap.put(per.Id, per);
            permissionSetIdSet.add(per.Id);
        }
        
        //List<ObjectPermissions> objPerList = new List<ObjectPermissions>([select ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsModifyAllRecords, PermissionsViewAllRecords from ObjectPermissions where ParentId IN :permissionSetIdSet]);
        
        //for(ObjectPermissions objPer : objPerList ){
        for(ObjectPermissions objPer : [select ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsModifyAllRecords, PermissionsViewAllRecords from ObjectPermissions where ParentId IN :permissionSetIdSet]){
            ProfileWiseObjectPermission__c proObject = new ProfileWiseObjectPermission__c();
            proObject.Name = profilePermissionSetMap.get(objPer.ParentId).Profile.Name;
            proObject.SObject_Name__c = string.valueOf(objPer.SobjectType);
            proObject.Create__c = objPer.PermissionsCreate;
            proObject.Edit__c = objPer.PermissionsEdit;
            proObject.Read__c = objPer.PermissionsRead;
            proObject.Delete__c = objPer.PermissionsDelete;
            proObject.ModifyAllRecords__c = objPer.PermissionsModifyAllRecords;
            proObject.ViewAllRecords__c = objPer.PermissionsViewAllRecords;
            
            profileObjectSettingList.add(proObject);          
        }
        
        If(profileObjectSettingList.size()>0){
            try{
                insert profileObjectSettingList;
            }catch(Exception ex){
                system.debug('@@Exception' + ex);
            }
        }
        return null;  
    }
}