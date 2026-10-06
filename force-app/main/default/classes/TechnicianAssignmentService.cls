/**
 * Transparent assignment scoring (weights come from Assignment_Config__mdt):
 *   score = SkillWeight                                   (skill match is mandatory, so always earned)
 *         + DistanceWeight * max(0, 1 - distance/MaxDistance)
 *         + WorkloadWeight * max(0, 1 - workload/MaxWorkload)
 * Technicians without the required skill are never returned.
 */
public with sharing class TechnicianAssignmentService {

    public class Recommendation implements Comparable {
        @AuraEnabled public Id technicianId;
        @AuraEnabled public String technicianName;
        @AuraEnabled public Decimal score;
        @AuraEnabled public Decimal distanceKm;
        @AuraEnabled public Decimal workload;
        public Integer compareTo(Object other) {
            Recommendation o = (Recommendation) other;
            if (score == o.score) {
                return 0;
            }
            return score > o.score ? -1 : 1; // highest score first
        }
    }

    public static List<Recommendation> recommend(Id caseId) {
        Case c = CaseSelector.byId(caseId);
        if (c == null) {
            throw new ServiceOpsException('Service request not found.');
        }
        if (String.isBlank(c.Service_Category__c)) {
            throw new ServiceOpsException('Set a Service Category on the request before assigning.');
        }
        Assignment_Config__mdt cfg = ConfigSelector.assignmentConfig();
        List<Recommendation> results = new List<Recommendation>();
        for (Technician__c t : TechnicianSelector.availableWithSkill(c.Service_Category__c)) {
            Double dist = GeoUtil.distanceKm(c.Location_Latitude__c, c.Location_Longitude__c, t.Latitude__c, t.Longitude__c);
            Recommendation r = new Recommendation();
            r.technicianId = t.Id;
            r.technicianName = t.Name;
            r.workload = t.Current_Workload__c == null ? 0 : t.Current_Workload__c;
            r.distanceKm = dist == null ? null : Decimal.valueOf(dist).setScale(1);
            r.score = score(r.distanceKm, r.workload, cfg);
            results.add(r);
        }
        results.sort();
        return results;
    }

    /** Pure function so the algorithm can be unit tested without any database. */
    public static Decimal score(Decimal distanceKm, Decimal workload, Assignment_Config__mdt cfg) {
        Decimal distFactor = distanceKm == null ? 0 : Math.max(0, 1 - distanceKm / cfg.Max_Distance_Km__c);
        Decimal loadFactor = Math.max(0, 1 - (workload == null ? 0 : workload) / cfg.Max_Workload__c);
        return (cfg.Skill_Weight__c + cfg.Distance_Weight__c * distFactor + cfg.Workload_Weight__c * loadFactor).setScale(1);
    }

    public static Work_Order__c assign(Id caseId, Id technicianId) {
        Case c = CaseSelector.byId(caseId);
        if (c == null) {
            throw new ServiceOpsException('Service request not found.');
        }
        List<Technician__c> techs = TechnicianSelector.byIds(new Set<Id>{ technicianId });
        if (techs.isEmpty()) {
            throw new ServiceOpsException('Technician not found.');
        }
        Technician__c tech = techs[0];
        if (tech.Status__c == 'OFFLINE' || tech.Status__c == 'ON_LEAVE') {
            throw new ServiceOpsException(tech.Name + ' is ' + tech.Status__c + ' and cannot take jobs.');
        }
        Work_Order__c wo = new Work_Order__c(
            Case__c = c.Id, Technician__c = tech.Id, Status__c = 'ASSIGNED',
            Scheduled_Date__c = System.now(), Description__c = c.Subject
        );
        if (tech.User__c != null) {
            wo.OwnerId = tech.User__c; // record-level security: the technician owns (and only sees) their jobs
        }
        insert wo;
        update new Case(Id = c.Id, Assigned_Technician__c = tech.Id, Status = 'Working');
        return wo;
    }
}
