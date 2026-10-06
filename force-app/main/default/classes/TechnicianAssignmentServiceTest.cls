@IsTest
private class TechnicianAssignmentServiceTest {
    @TestSetup static void setup() {
        Skill__c ac = TestDataFactory.skill('AC Repair');
        Skill__c plumbing = TestDataFactory.skill('Plumbing');
        // Customer at ~(30.7400, 76.7900)
        Technician__c a = TestDataFactory.technician('A', 30.7670, 76.7900, 'AVAILABLE', 1); // ~3 km, load 1
        Technician__c b = TestDataFactory.technician('B', 30.8120, 76.7900, 'AVAILABLE', 4); // ~8 km, load 4
        Technician__c c = TestDataFactory.technician('C', 30.7420, 76.7900, 'AVAILABLE', 0); // ~0.2 km, no skill
        TestDataFactory.link(a, ac);
        TestDataFactory.link(b, ac);
        TestDataFactory.link(c, plumbing);
        TestDataFactory.serviceCase('AC not cooling', 'AC Repair', 'High', 30.7400, 76.7900);
    }
    @IsTest static void closestLeastLoadedSkilledTechnicianWins() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        List<TechnicianAssignmentService.Recommendation> recs = TechnicianAssignmentService.recommend(c.Id);
        System.assertEquals(2, recs.size(), 'Technician C has no matching skill and must be excluded');
        System.assertEquals('A', recs[0].technicianName);
        System.assertEquals('B', recs[1].technicianName);
        System.assert(recs[0].score > recs[1].score);
    }
    @IsTest static void scoreFormulaMatchesDocumentedExample() {
        Assignment_Config__mdt cfg = new Assignment_Config__mdt(Skill_Weight__c = 50, Distance_Weight__c = 30, Workload_Weight__c = 20, Max_Distance_Km__c = 50, Max_Workload__c = 5);
        // 50 + 30*(1-3/50) + 20*(1-1/5) = 50 + 28.2 + 16 = 94.2
        System.assertEquals(94.2, TechnicianAssignmentService.score(3, 1, cfg));
        System.assertEquals(50.0, TechnicianAssignmentService.score(500, 10, cfg), 'Far + overloaded keeps only the skill points');
        System.assertEquals(70.0, TechnicianAssignmentService.score(null, 0, cfg), 'Unknown distance earns no distance points');
    }
    @IsTest static void assignCreatesWorkOrderAndUpdatesWorkload() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Technician__c a = [SELECT Id FROM Technician__c WHERE Name = 'A'];
        Work_Order__c wo = TechnicianAssignmentService.assign(c.Id, a.Id);
        wo = [SELECT Status__c, Case__c FROM Work_Order__c WHERE Id = :wo.Id];
        System.assertEquals('ASSIGNED', wo.Status__c);
        System.assertEquals(c.Id, wo.Case__c);
        a = [SELECT Current_Workload__c, Status__c FROM Technician__c WHERE Id = :a.Id];
        System.assertEquals(1, a.Current_Workload__c);
        System.assertEquals('BUSY', a.Status__c);
        Case reloaded = [SELECT Assigned_Technician__c, Status FROM Case WHERE Id = :c.Id];
        System.assertEquals(a.Id, reloaded.Assigned_Technician__c);
        System.assertEquals('Working', reloaded.Status);
    }
    @IsTest static void offlineTechnicianCannotBeAssigned() {
        Technician__c off = TestDataFactory.technician('Off', 30.7, 76.7, 'OFFLINE', 0);
        Case c = [SELECT Id FROM Case LIMIT 1];
        try {
            TechnicianAssignmentService.assign(c.Id, off.Id);
            System.assert(false, 'Expected exception');
        } catch (ServiceOpsException e) {
            System.assert(e.getMessage().contains('OFFLINE'));
        }
    }
    @IsTest static void recommendRequiresServiceCategory() {
        Case noCategory = TestDataFactory.serviceCase('no category', null, 'Low', null, null);
        try {
            TechnicianAssignmentService.recommend(noCategory.Id);
            System.assert(false, 'Expected exception');
        } catch (ServiceOpsException e) {
            System.assert(e.getMessage().contains('Service Category'));
        }
    }
}
