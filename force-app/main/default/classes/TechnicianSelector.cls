public inherited sharing class TechnicianSelector {
    public static List<Technician__c> byIds(Set<Id> ids) {
        return [
            SELECT Id, Name, Status__c, Current_Workload__c, Latitude__c, Longitude__c, User__c
            FROM Technician__c WHERE Id IN :ids
        ];
    }
    /** Technicians who are AVAILABLE/BUSY and own a Skill whose name equals the requested skill. */
    public static List<Technician__c> availableWithSkill(String skillName) {
        return [
            SELECT Id, Name, Status__c, Current_Workload__c, Latitude__c, Longitude__c, User__c
            FROM Technician__c
            WHERE Status__c IN ('AVAILABLE', 'BUSY')
              AND Id IN (SELECT Technician__c FROM Technician_Skill__c WHERE Skill__r.Name = :skillName)
        ];
    }
}
