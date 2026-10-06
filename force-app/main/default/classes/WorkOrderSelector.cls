public inherited sharing class WorkOrderSelector {
    public static List<Work_Order__c> byIds(Set<Id> ids) {
        return [
            SELECT Id, Name, Status__c, Case__c, Technician__c, Resolution__c, End_Time__c,
                   Labour_Charge__c, Parts_Total__c
            FROM Work_Order__c WHERE Id IN :ids
        ];
    }
    /** Aggregate query: open work orders per technician, computed in the database. */
    public static List<AggregateResult> openCountByTechnician(Set<Id> technicianIds) {
        return [
            SELECT Technician__c techId, COUNT(Id) cnt
            FROM Work_Order__c
            WHERE Technician__c IN :technicianIds AND Status__c NOT IN ('COMPLETED', 'CANCELLED')
            GROUP BY Technician__c
        ];
    }
    public static Set<Id> caseIdsWithOpenWork(Set<Id> caseIds) {
        Set<Id> result = new Set<Id>();
        for (Work_Order__c wo : [
            SELECT Case__c FROM Work_Order__c
            WHERE Case__c IN :caseIds AND Status__c NOT IN ('COMPLETED', 'CANCELLED')
        ]) {
            result.add(wo.Case__c);
        }
        return result;
    }
}
