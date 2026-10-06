/** Batch: the set of open cases near their deadline can be large, so we process it in chunks of 200. */
public with sharing class SlaEscalationBatch implements Database.Batchable<SObject> {
    private Integer warningMinutes;
    public SlaEscalationBatch() { this(30); }
    public SlaEscalationBatch(Integer warningMinutes) { this.warningMinutes = warningMinutes; }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return CaseSelector.escalationCandidates(System.now().addMinutes(warningMinutes));
    }
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        SlaEscalationService.escalate(scope);
    }
    public void finish(Database.BatchableContext bc) {}
}
