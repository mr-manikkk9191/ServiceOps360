public with sharing class WorkOrderTriggerHandler {
    public static void beforeUpdate(List<Work_Order__c> newList, Map<Id, Work_Order__c> oldMap) {
        WorkOrderStatusService.validateAndStamp(newList, oldMap);
    }
    public static void afterInsert(List<Work_Order__c> newList) {
        Set<Id> techIds = new Set<Id>();
        for (Work_Order__c wo : newList) {
            if (wo.Technician__c != null) {
                techIds.add(wo.Technician__c);
            }
        }
        TechnicianWorkloadService.recalculate(techIds);
    }
    public static void afterUpdate(List<Work_Order__c> newList, Map<Id, Work_Order__c> oldMap) {
        Set<Id> techIds = new Set<Id>();
        Set<Id> completed = new Set<Id>();
        for (Work_Order__c wo : newList) {
            Work_Order__c old = oldMap.get(wo.Id);
            if (wo.Technician__c != old.Technician__c || wo.Status__c != old.Status__c) {
                if (wo.Technician__c != null) { techIds.add(wo.Technician__c); }
                if (old.Technician__c != null) { techIds.add(old.Technician__c); }
            }
            if (wo.Status__c == 'COMPLETED' && old.Status__c != 'COMPLETED') {
                completed.add(wo.Id);
            }
        }
        TechnicianWorkloadService.recalculate(techIds);
        if (!completed.isEmpty()) {
            InvoiceService.createForCompleted(completed);
            WorkOrderCompletionService.publishCompletion(completed);
        }
    }
}
