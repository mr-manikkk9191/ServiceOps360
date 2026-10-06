trigger CaseTrigger on Case(before insert, before update) {
    if (Trigger.isInsert) {
        CaseTriggerHandler.beforeInsert(Trigger.new);
    } else {
        CaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
