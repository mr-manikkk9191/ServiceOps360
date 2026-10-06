/** Single source of truth for Technician workload + status, recomputed from open Work Orders. */
public with sharing class TechnicianWorkloadService {
    public static void recalculate(Set<Id> technicianIds) {
        if (technicianIds == null || technicianIds.isEmpty()) {
            return;
        }
        Map<Id, Integer> counts = new Map<Id, Integer>();
        for (Id techId : technicianIds) {
            counts.put(techId, 0);
        }
        for (AggregateResult ar : WorkOrderSelector.openCountByTechnician(technicianIds)) {
            counts.put((Id) ar.get('techId'), (Integer) ar.get('cnt'));
        }
        List<Technician__c> toUpdate = new List<Technician__c>();
        for (Technician__c t : TechnicianSelector.byIds(technicianIds)) {
            Integer open = counts.get(t.Id);
            t.Current_Workload__c = open;
            if (t.Status__c == 'AVAILABLE' && open > 0) {
                t.Status__c = 'BUSY';
            } else if (t.Status__c == 'BUSY' && open == 0) {
                t.Status__c = 'AVAILABLE';
            }
            toUpdate.add(t);
        }
        update toUpdate;
    }
}
