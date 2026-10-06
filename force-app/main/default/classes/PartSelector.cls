public inherited sharing class PartSelector {
    public static List<Part__c> byIds(Set<Id> ids) {
        return [SELECT Id, Name, Current_Stock__c, Reorder_Level__c, Unit_Cost__c FROM Part__c WHERE Id IN :ids];
    }
    /** FOR UPDATE locks the rows so two technicians cannot consume the same stock simultaneously. */
    public static List<Part__c> byIdsForUpdate(Set<Id> ids) {
        return [SELECT Id, Name, Current_Stock__c, Reorder_Level__c, Unit_Cost__c FROM Part__c WHERE Id IN :ids FOR UPDATE];
    }
    public static Set<Id> partIdsWithOpenRequest(Set<Id> partIds) {
        Set<Id> result = new Set<Id>();
        for (Purchase_Request__c pr : [SELECT Part__c FROM Purchase_Request__c WHERE Part__c IN :partIds AND Status__c IN ('OPEN', 'ORDERED')]) {
            result.add(pr.Part__c);
        }
        return result;
    }
}
