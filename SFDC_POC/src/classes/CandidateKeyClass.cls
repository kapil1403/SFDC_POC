Public Class CandidateKeyClass{
    public static void hasCandidateDuplicates(List<Candidate__c> candidate){
        for(Integer i=0;i<candidate.size();i++){
        Map<String, Candidate__c> candidateMap=new Map<String, Candidate__c>();
            if(candidateMap.containsKey(candidate[i].Unique_Key__c))
                candidate[i].addError('Duplicate Last Name and Email found');
            else
                candidateMap.put(candidate[i].Unique_Key__c,candidate[i]);
        }
    }
}