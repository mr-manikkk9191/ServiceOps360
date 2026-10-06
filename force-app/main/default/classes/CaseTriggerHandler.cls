public with sharing class CaseTriggerHandler {
    public static void beforeInsert(List<Case> newList) {
        SlaService.applySla(newList, null);
    }
    public static void beforeUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        SlaService.applySla(newList, oldMap);
    }
}
