/** Enforces the Work Order state machine and stamps timestamps. */
public with sharing class WorkOrderStatusService {
    private static final Map<String, Set<String>> ALLOWED = new Map<String, Set<String>>{
        'ASSIGNED' => new Set<String>{ 'ACCEPTED', 'CANCELLED' },
        'ACCEPTED' => new Set<String>{ 'EN_ROUTE', 'CANCELLED' },
        'EN_ROUTE' => new Set<String>{ 'ON_SITE', 'CANCELLED' },
        'ON_SITE' => new Set<String>{ 'IN_PROGRESS', 'CANCELLED' },
        'IN_PROGRESS' => new Set<String>{ 'COMPLETED', 'CANCELLED' }
    };

    public static void validateAndStamp(List<Work_Order__c> newList, Map<Id, Work_Order__c> oldMap) {
        for (Work_Order__c wo : newList) {
            Work_Order__c old = oldMap.get(wo.Id);
            if (wo.Status__c == old.Status__c) {
                continue;
            }
            Set<String> allowed = ALLOWED.get(old.Status__c);
            if (allowed == null || !allowed.contains(wo.Status__c)) {
                wo.addError('Invalid status change from ' + old.Status__c + ' to ' + wo.Status__c + '.');
                continue;
            }
            if (wo.Status__c == 'IN_PROGRESS' && wo.Start_Time__c == null) {
                wo.Start_Time__c = System.now();
            }
            if (wo.Status__c == 'COMPLETED') {
                if (String.isBlank(wo.Resolution__c)) {
                    wo.addError('A resolution is required to complete a job.');
                    continue;
                }
                if (wo.End_Time__c == null) {
                    wo.End_Time__c = System.now();
                }
            }
        }
    }
}
