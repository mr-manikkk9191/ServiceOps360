public with sharing class SlaEscalationService {
    public static void escalate(List<Case> cases) {
        List<Task> tasks = new List<Task>();
        for (Case c : cases) {
            c.Escalated__c = true;
            c.Status = 'Escalated';
            // Tasks can only be owned by users (005...), not queues (00G...)
            if (String.valueOf(c.OwnerId).startsWith('005')) {
                tasks.add(new Task(
                    WhatId = c.Id, OwnerId = c.OwnerId, Priority = 'High', ActivityDate = Date.today(),
                    Subject = 'SLA at risk / breached: case ' + c.CaseNumber
                ));
            }
        }
        update cases;
        insert tasks;
    }
}
