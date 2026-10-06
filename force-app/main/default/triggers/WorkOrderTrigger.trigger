trigger WorkOrderTrigger on Work_Order__c(before update, after insert, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        WorkOrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        WorkOrderTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        WorkOrderTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
