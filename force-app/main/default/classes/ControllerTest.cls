@IsTest
private class ControllerTest {
    private static User technicianUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String uniq = String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        User u = new User(Alias = 'tech1', Email = 'tech' + uniq + '@example.com', EmailEncodingKey = 'UTF-8', LastName = 'Tester',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'tech' + uniq + '@serviceops360.test');
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ServiceOps_Technician'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        return u;
    }
    @IsTest static void technicianSeesOwnJobsAndCanProgressThem() {
        User u = technicianUser(); // User is a setup object, so the rest runs inside runAs (avoids mixed-DML error)
        System.runAs(u) {
            Skill__c s = TestDataFactory.skill('AC Repair');
            Technician__c t = TestDataFactory.technician('Me', 30.7, 76.7, 'AVAILABLE', 0);
            t.User__c = u.Id;
            update t;
            TestDataFactory.link(t, s);
            Case c = TestDataFactory.serviceCase('AC down', 'AC Repair', 'High', 30.7, 76.7);
            Work_Order__c wo = TechnicianAssignmentService.assign(c.Id, t.Id);

            List<Work_Order__c> jobs = WorkOrderController.getMyJobs();
            System.assertEquals(1, jobs.size());
            System.assertEquals('AC down', jobs[0].Case__r.Subject);

            WorkOrderController.updateStatus(wo.Id, 'ACCEPTED', null);
            System.assertEquals('ACCEPTED', [SELECT Status__c FROM Work_Order__c WHERE Id = :wo.Id].Status__c);

            try {
                WorkOrderController.updateStatus(wo.Id, 'COMPLETED', 'skipped steps');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Invalid status change'), e.getMessage());
            }
        }
    }
    @IsTest static void dispatcherControllerReturnsRecommendationsAndAssigns() {
        Skill__c s = TestDataFactory.skill('Plumbing');
        Technician__c t = TestDataFactory.technician('P1', 30.7, 76.7, 'AVAILABLE', 0);
        TestDataFactory.link(t, s);
        Case c = TestDataFactory.serviceCase('Leak', 'Plumbing', 'Medium', 30.71, 76.7);
        System.assertEquals(1, DispatcherController.getRecommendations(c.Id).size());
        Id woId = DispatcherController.assignTechnician(c.Id, t.Id);
        System.assertNotEquals(null, woId);
        try {
            DispatcherController.getRecommendations(null);
            System.assert(false, 'Expected exception');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }
}

