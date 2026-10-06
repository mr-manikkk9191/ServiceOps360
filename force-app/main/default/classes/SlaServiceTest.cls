@IsTest
private class SlaServiceTest {
    private static Decimal minutesFromNow(Datetime dt) {
        return (dt.getTime() - System.now().getTime()) / 60000.0;
    }
    @IsTest static void highPriorityGetsFourHours() {
        Case c = TestDataFactory.serviceCase('x', null, 'High', null, null);
        c = [SELECT SLA_Deadline__c FROM Case WHERE Id = :c.Id];
        Decimal m = minutesFromNow(c.SLA_Deadline__c);
        System.assert(m > 238 && m <= 240, 'High = 4h, got minutes: ' + m);
    }
    @IsTest static void criticalGetsOneHour() {
        Case c = TestDataFactory.serviceCase('x', null, 'Critical', null, null);
        c = [SELECT SLA_Deadline__c FROM Case WHERE Id = :c.Id];
        Decimal m = minutesFromNow(c.SLA_Deadline__c);
        System.assert(m > 58 && m <= 60, 'Critical = 1h, got minutes: ' + m);
    }
    @IsTest static void missingPriorityDefaultsToMedium() {
        Case c = new Case(Subject = 'x', Origin = 'Phone');
        insert c;
        c = [SELECT Priority, SLA_Deadline__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Medium', c.Priority);
        System.assert(minutesFromNow(c.SLA_Deadline__c) > 478);
    }
    @IsTest static void changingPriorityRecalculatesFromCreatedDate() {
        Case c = TestDataFactory.serviceCase('x', null, 'High', null, null);
        c.Priority = 'Low';
        update c;
        c = [SELECT CreatedDate, SLA_Deadline__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(c.CreatedDate.addMinutes(24 * 60), c.SLA_Deadline__c);
    }
    @IsTest static void explicitDeadlineIsNotOverwrittenOnInsert() {
        Datetime custom = System.now().addDays(10);
        Case c = new Case(Subject = 'x', Origin = 'Phone', Priority = 'High', SLA_Deadline__c = custom);
        insert c;
        System.assertEquals(custom, [SELECT SLA_Deadline__c FROM Case WHERE Id = :c.Id].SLA_Deadline__c);
    }
    @IsTest static void bulkInsert200Cases() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            cases.add(new Case(Subject = 'bulk ' + i, Origin = 'Phone', Priority = 'Low'));
        }
        insert cases;
        System.assertEquals(200, [SELECT COUNT() FROM Case WHERE SLA_Deadline__c != null AND Subject LIKE 'bulk%']);
    }
}
