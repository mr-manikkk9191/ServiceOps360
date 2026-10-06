/**
 * Subscriber side of Job_Completed__e. Runs as the Automated Process user, so it is
 * deliberately "without sharing": it must see every work order regardless of owner.
 */
public without sharing class CaseCompletionService {
    public static void handle(List<Job_Completed__e> events) {
        Set<Id> workOrderIds = new Set<Id>();
        for (Job_Completed__e e : events) {
            workOrderIds.add((Id) e.Work_Order_Id__c);
        }
        List<Work_Order__c> orders = WorkOrderSelector.byIds(workOrderIds);
        Set<Id> caseIds = new Set<Id>();
        for (Work_Order__c wo : orders) {
            if (wo.Case__c != null) {
                caseIds.add(wo.Case__c);
            }
        }
        Set<Id> stillOpen = WorkOrderSelector.caseIdsWithOpenWork(caseIds);
        Map<Id, Case> casesToClose = new Map<Id, Case>(); // Map prevents duplicate-Id update errors
        List<Feedback__c> feedbackRequests = new List<Feedback__c>();
        for (Work_Order__c wo : orders) {
            feedbackRequests.add(new Feedback__c(Work_Order__c = wo.Id, Technician__c = wo.Technician__c));
            if (wo.Case__c != null && !stillOpen.contains(wo.Case__c)) {
                casesToClose.put(wo.Case__c, new Case(
                    Id = wo.Case__c, Status = 'Closed',
                    Completion_Date__c = wo.End_Time__c == null ? System.now() : wo.End_Time__c,
                    Resolution_Notes__c = wo.Resolution__c
                ));
            }
        }
        update casesToClose.values();
        insert feedbackRequests;
    }
}
