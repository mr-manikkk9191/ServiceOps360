/** Reads Custom Metadata. getInstance/getAll do NOT count against SOQL limits. */
public inherited sharing class ConfigSelector {
    public static Map<String, Decimal> slaHoursByPriority() {
        Map<String, Decimal> result = new Map<String, Decimal>();
        for (SLA_Rule__mdt rule : SLA_Rule__mdt.getAll().values()) {
            result.put(rule.Priority__c, rule.Hours__c);
        }
        return result;
    }
    public static Assignment_Config__mdt assignmentConfig() {
        Assignment_Config__mdt cfg = Assignment_Config__mdt.getInstance('Default');
        if (cfg == null) {
            throw new ServiceOpsException('Assignment_Config__mdt record "Default" is missing.');
        }
        return cfg;
    }
    public static Decimal taxRatePercent() {
        Billing_Config__mdt cfg = Billing_Config__mdt.getInstance('Default');
        return cfg == null ? 0 : cfg.Tax_Rate_Percent__c;
    }
}
