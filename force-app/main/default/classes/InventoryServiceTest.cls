@IsTest
private class InventoryServiceTest {
    @IsTest static void usageDecrementsStockAndDefaultsPrice() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c p = TestDataFactory.part('Filter', 'F-1', 100, 10, 2);
        insert new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 3);
        System.assertEquals(7, [SELECT Current_Stock__c FROM Part__c WHERE Id = :p.Id].Current_Stock__c);
        System.assertEquals(100, [SELECT Unit_Price__c FROM Part_Usage__c LIMIT 1].Unit_Price__c);
        System.assertEquals(0, [SELECT COUNT() FROM Purchase_Request__c]);
    }
    @IsTest static void reachingReorderLevelCreatesExactlyOnePurchaseRequest() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c p = TestDataFactory.part('Gas', 'G-1', 50, 10, 5);
        insert new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 5); // stock 5 <= reorder 5
        insert new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 1); // stock 4, request already open
        List<Purchase_Request__c> prs = [SELECT Quantity__c, Status__c FROM Purchase_Request__c WHERE Part__c = :p.Id];
        System.assertEquals(1, prs.size());
        System.assertEquals('OPEN', prs[0].Status__c);
        System.assertEquals(5, prs[0].Quantity__c); // reorder*2 - stock = 10 - 5
    }
    @IsTest static void insufficientStockIsBlocked() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c p = TestDataFactory.part('Fan', 'FAN-1', 80, 2, 1);
        Database.SaveResult sr = Database.insert(new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 5), false);
        System.assert(!sr.isSuccess());
        System.assert(sr.getErrors()[0].getMessage().contains('Insufficient stock'));
        System.assertEquals(2, [SELECT Current_Stock__c FROM Part__c WHERE Id = :p.Id].Current_Stock__c);
    }
    @IsTest static void bulkUsagesOfSamePartAreSummedBeforeValidation() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c p = TestDataFactory.part('Bolt', 'B-1', 1, 10, 1);
        List<Part_Usage__c> usages = new List<Part_Usage__c>{
            new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 6),
            new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 6)
        };
        List<Database.SaveResult> results = Database.insert(usages, false);
        System.assert(!results[0].isSuccess() && !results[1].isSuccess(), 'Together they exceed stock of 10');
    }
    @IsTest static void zeroQuantityFailsValidationRule() {
        Work_Order__c wo = TestDataFactory.assignedWorkOrder();
        Part__c p = TestDataFactory.part('Nut', 'N-1', 1, 10, 1);
        System.assert(!Database.insert(new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 0), false).isSuccess());
    }
}
