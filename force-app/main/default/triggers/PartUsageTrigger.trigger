trigger PartUsageTrigger on Part_Usage__c(before insert, after insert) {
    if (Trigger.isBefore) {
        PartUsageTriggerHandler.beforeInsert(Trigger.new);
    } else {
        PartUsageTriggerHandler.afterInsert(Trigger.new);
    }
}
