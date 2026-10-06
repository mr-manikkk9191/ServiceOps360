/** Draft invoice = labour + parts + tax (tax rate from Billing_Config__mdt). Idempotent per work order. */
public with sharing class InvoiceService {
    public static List<Invoice__c> createForCompleted(Set<Id> workOrderIds) {
        Decimal taxRate = ConfigSelector.taxRatePercent();
        Set<Id> alreadyInvoiced = InvoiceSelector.invoicedWorkOrderIds(workOrderIds);
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Work_Order__c wo : WorkOrderSelector.byIds(workOrderIds)) {
            if (alreadyInvoiced.contains(wo.Id)) {
                continue;
            }
            Decimal labour = wo.Labour_Charge__c == null ? 0 : wo.Labour_Charge__c;
            Decimal parts = wo.Parts_Total__c == null ? 0 : wo.Parts_Total__c;
            invoices.add(new Invoice__c(
                Work_Order__c = wo.Id, Labour_Amount__c = labour, Parts_Amount__c = parts,
                Tax_Amount__c = ((labour + parts) * taxRate / 100).setScale(2), Status__c = 'DRAFT'
            ));
        }
        insert invoices;
        return invoices;
    }
}
