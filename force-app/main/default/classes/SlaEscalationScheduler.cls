/** Scheduled Apex: runs the batch every 15 minutes. Start it with SlaEscalationScheduler.schedule(); */
public with sharing class SlaEscalationScheduler implements Schedulable {
    public static final String CRON = '0 0,15,30,45 * * * ?';
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SlaEscalationBatch(), 200);
    }
    public static Id schedule() {
        return System.schedule('ServiceOps360 SLA Escalation', CRON, new SlaEscalationScheduler());
    }
}
