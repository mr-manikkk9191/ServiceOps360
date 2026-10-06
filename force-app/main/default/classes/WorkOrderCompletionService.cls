/** Publishes Job_Completed__e so other processes react without this code knowing about them. */
public with sharing class WorkOrderCompletionService {
    public static void publishCompletion(Set<Id> workOrderIds) {
        List<Job_Completed__e> events = new List<Job_Completed__e>();
        for (Work_Order__c wo : WorkOrderSelector.byIds(workOrderIds)) {
            events.add(new Job_Completed__e(Work_Order_Id__c = wo.Id, Case_Id__c = wo.Case__c));
        }
        for (Database.SaveResult sr : EventBus.publish(events)) {
            if (!sr.isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'Event publish failed: ' + sr.getErrors());
            }
        }
    }
}
