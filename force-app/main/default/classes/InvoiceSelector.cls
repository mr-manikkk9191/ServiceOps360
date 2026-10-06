public inherited sharing class InvoiceSelector {
    public static Set<Id> invoicedWorkOrderIds(Set<Id> workOrderIds) {
        Set<Id> result = new Set<Id>();
        for (Invoice__c i : [SELECT Work_Order__c FROM Invoice__c WHERE Work_Order__c IN :workOrderIds]) {
            result.add(i.Work_Order__c);
        }
        return result;
    }
}
