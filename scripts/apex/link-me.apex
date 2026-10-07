// Links the running user to the technician assigned to the "AC not cooling" case,
// so the My Jobs screen shows that technician's jobs. Demo helper only.
Case c = [SELECT Assigned_Technician__c FROM Case WHERE Subject = 'AC not cooling' LIMIT 1];
update new Technician__c(Id = c.Assigned_Technician__c, User__c = UserInfo.getUserId());
