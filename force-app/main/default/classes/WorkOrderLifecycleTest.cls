@IsTest
private class WorkOrderLifecycleTest {
    @IsTest static void invalidTransitionIsRejected() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        wo.Status__c = 'COMPLETED';
        Database.SaveResult sr = Database.update(wo, false);
        System.assert(!sr.isSuccess());
        System.assert(sr.getErrors()[0].getMessage().contains('Invalid status change'));
    }
    @IsTest static void completionRequiresResolution() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        TestDataFactory.advance(wo, new List<String>{ 'ACCEPTED', 'EN_ROUTE', 'ON_SITE', 'IN_PROGRESS' });
        wo.Status__c = 'COMPLETED';
        Database.SaveResult sr = Database.update(wo, false);
        System.assert(!sr.isSuccess());
        System.assert(sr.getErrors()[0].getMessage().contains('resolution'));
    }
    @IsTest static void fullLifecycleProducesInvoiceClosesCaseAndRequestsFeedback() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c part = TestDataFactory.part('Capacitor', 'CAP-1', 600, 10, 3);
        TestDataFactory.advance(wo, new List<String>{ 'ACCEPTED', 'EN_ROUTE', 'ON_SITE', 'IN_PROGRESS' });
        System.assertNotEquals(null, [SELECT Start_Time__c FROM Work_Order__c WHERE Id = :wo.Id].Start_Time__c);

        insert new Part_Usage__c(Work_Order__c = wo.Id, Part__c = part.Id, Quantity__c = 2);

        wo.Status__c = 'COMPLETED';
        wo.Resolution__c = 'Replaced capacitor';
        wo.Labour_Charge__c = 800;
        Test.startTest();
        update wo;
        Test.stopTest(); // delivers the Platform Event to JobCompletedTrigger

        Invoice__c inv = [SELECT Labour_Amount__c, Parts_Amount__c, Tax_Amount__c, Total_Amount__c FROM Invoice__c WHERE Work_Order__c = :wo.Id];
        System.assertEquals(800, inv.Labour_Amount__c);
        System.assertEquals(1200, inv.Parts_Amount__c);
        System.assertEquals(360, inv.Tax_Amount__c);
        System.assertEquals(2360, inv.Total_Amount__c);

        Work_Order__c done = [SELECT Case__c, Technician__c FROM Work_Order__c WHERE Id = :wo.Id];
        Case c = [SELECT Status, Resolution_Notes__c, Completion_Date__c FROM Case WHERE Id = :done.Case__c];
        System.assertEquals('Closed', c.Status);
        System.assertEquals('Replaced capacitor', c.Resolution_Notes__c);
        System.assertNotEquals(null, c.Completion_Date__c);

        System.assertEquals(1, [SELECT COUNT() FROM Feedback__c WHERE Work_Order__c = :wo.Id]);
        Technician__c t = [SELECT Current_Workload__c, Status__c FROM Technician__c WHERE Id = :done.Technician__c];
        System.assertEquals(0, t.Current_Workload__c);
        System.assertEquals('AVAILABLE', t.Status__c);
    }
    @IsTest static void caseStaysOpenWhileAnotherWorkOrderIsOpen() {
        Work_Order__c first = TestDataFactory.assignedWorkOrder();
        Work_Order__c second = new Work_Order__c(Case__c = first.Case__c, Technician__c = [SELECT Technician__c FROM Work_Order__c WHERE Id = :first.Id].Technician__c, Status__c = 'ASSIGNED');
        insert second;
        TestDataFactory.advance(first, new List<String>{ 'ACCEPTED', 'EN_ROUTE', 'ON_SITE', 'IN_PROGRESS' });
        first.Status__c = 'COMPLETED';
        first.Resolution__c = 'Done';
        Test.startTest();
        update first;
        Test.stopTest();
        System.assertNotEquals('Closed', [SELECT Status FROM Case WHERE Id = :first.Case__c].Status);
    }
}
