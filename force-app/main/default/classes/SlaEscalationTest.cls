@IsTest
private class SlaEscalationTest {
    @IsTest static void batchEscalatesOnlyOpenCasesNearDeadline() {
        Case atRisk = new Case(Subject = 'at risk', Origin = 'Phone', Priority = 'High', SLA_Deadline__c = System.now().addMinutes(10));
        Case fine = new Case(Subject = 'fine', Origin = 'Phone', Priority = 'High', SLA_Deadline__c = System.now().addHours(5));
        Case closed = new Case(Subject = 'closed', Origin = 'Phone', Priority = 'High', Status = 'Closed', SLA_Deadline__c = System.now().addMinutes(-60));
        insert new List<Case>{ atRisk, fine, closed };

        Test.startTest();
        Database.executeBatch(new SlaEscalationBatch(30));
        Test.stopTest();

        System.assertEquals(true, [SELECT Escalated__c FROM Case WHERE Id = :atRisk.Id].Escalated__c);
        System.assertEquals('Escalated', [SELECT Status FROM Case WHERE Id = :atRisk.Id].Status);
        System.assertEquals(false, [SELECT Escalated__c FROM Case WHERE Id = :fine.Id].Escalated__c);
        System.assertEquals(false, [SELECT Escalated__c FROM Case WHERE Id = :closed.Id].Escalated__c);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :atRisk.Id]);
    }
    @IsTest static void schedulerRegistersJob() {
        Test.startTest();
        Id jobId = System.schedule('test escalation', '0 0 0 1 1 ? 2099', new SlaEscalationScheduler());
        Test.stopTest();
        System.assertEquals('0 0 0 1 1 ? 2099', [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId].CronExpression);
    }
}
