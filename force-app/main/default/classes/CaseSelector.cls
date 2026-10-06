public inherited sharing class CaseSelector {
    public static Case byId(Id caseId) {
        List<Case> rows = [
            SELECT Id, CaseNumber, Subject, Priority, Status, OwnerId, Service_Category__c,
                   Location_Latitude__c, Location_Longitude__c, Assigned_Technician__c
            FROM Case WHERE Id = :caseId LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }
    /** QueryLocator so a Batch job can page through any number of rows. */
    public static Database.QueryLocator escalationCandidates(Datetime cutoff) {
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, OwnerId, Status, SLA_Deadline__c
            FROM Case
            WHERE IsClosed = false AND Escalated__c = false
              AND SLA_Deadline__c != null AND SLA_Deadline__c <= :cutoff
        ]);
    }
}
