public with sharing class PartUsageTriggerHandler {
    public static void beforeInsert(List<Part_Usage__c> newList) {
        InventoryService.validateAndPrice(newList);
    }
    public static void afterInsert(List<Part_Usage__c> newList) {
        InventoryService.consume(newList);
    }
}
