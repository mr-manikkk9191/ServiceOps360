/** Calculates SLA deadlines from Custom Metadata (no hard-coded hours). Bulk-safe: zero SOQL/DML. */
public with sharing class SlaService {
    public static void applySla(List<Case> cases, Map<Id, Case> oldMap) {
        Map<String, Decimal> hoursByPriority = ConfigSelector.slaHoursByPriority();
        for (Case c : cases) {
            Boolean isNew = (oldMap == null);
            if (isNew && c.Priority == null) {
                c.Priority = 'Medium';
            }
            Boolean needsSla = isNew ? (c.SLA_Deadline__c == null) : (c.Priority != oldMap.get(c.Id).Priority);
            if (!needsSla) {
                continue;
            }
            Decimal hours = hoursByPriority.get(c.Priority);
            if (hours == null) {
                continue;
            }
            Datetime base = isNew ? System.now() : c.CreatedDate;
            c.SLA_Deadline__c = base.addMinutes((hours * 60).intValue());
        }
    }
}
