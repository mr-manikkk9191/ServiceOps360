Case c = new Case(Subject='Refrigerator not cooling', Origin='Phone', Priority='High', Service_Category__c='Refrigeration', Location_Latitude__c=30.70, Location_Longitude__c=76.72);
insert c;
Technician__c t = [SELECT Id FROM Technician__c WHERE Name = 'Aman Sharma' LIMIT 1];
Work_Order__c wo = TechnicianAssignmentService.assign(c.Id, t.Id);
for (String s : new List<String>{'ACCEPTED','EN_ROUTE','ON_SITE','IN_PROGRESS'}) { wo.Status__c = s; update wo; }
Part__c p = [SELECT Id FROM Part__c WHERE SKU__c = 'GAS-R32-1'];
insert new Part_Usage__c(Work_Order__c = wo.Id, Part__c = p.Id, Quantity__c = 1);
wo.Status__c = 'COMPLETED'; wo.Resolution__c = 'Refilled R32 gas'; wo.Labour_Charge__c = 800;
update wo;
System.debug('Done: ' + wo.Id);
