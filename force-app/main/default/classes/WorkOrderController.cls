public with sharing class WorkOrderController {
    @AuraEnabled(cacheable=true)
    public static List<Work_Order__c> getMyJobs() {
        Id me = UserInfo.getUserId();
        return [
            SELECT Id, Name, Status__c, Scheduled_Date__c, Description__c,
                   Case__r.CaseNumber, Case__r.Subject, Case__r.Priority, Case__r.SLA_Deadline__c
            FROM Work_Order__c
            WHERE Technician__r.User__c = :me AND Status__c NOT IN ('COMPLETED', 'CANCELLED')
            WITH USER_MODE
            ORDER BY Scheduled_Date__c ASC
        ];
    }

    @AuraEnabled
    public static void updateStatus(Id workOrderId, String newStatus, String resolution) {
        try {
            Work_Order__c wo = new Work_Order__c(Id = workOrderId, Status__c = newStatus);
            if (!String.isBlank(resolution)) {
                wo.Resolution__c = resolution;
            }
            update as user wo;
        } catch (DmlException e) {
            throw toAura(e.getDmlMessage(0));
        } catch (Exception e) {
            throw toAura(e.getMessage());
        }
    }

    private static AuraHandledException toAura(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        return ex;
    }
}
