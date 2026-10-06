Case c = [SELECT Assigned_Technician__c FROM Case WHERE Subject = 'AC not cooling' LIMIT 1]; update new Technician__c(Id = c.Assigned_Technician__c, User__c = UserInfo.getUserId());
