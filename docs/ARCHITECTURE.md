# Architecture

```
LWC (technicianJobs, dispatcherAssign)
        │ @AuraEnabled
Controllers (WorkOrderController, DispatcherController)      <- thin, security-aware
        │
Triggers → Handlers → Services (SLA, Assignment, Workload, Status, Invoice, Inventory, Completion)
                                   │
                              Selectors (all SOQL)  →  Objects
Platform Event Job_Completed__e → JobCompletedTrigger → CaseCompletionService
Scheduled Apex → Batch Apex → SlaEscalationService
Custom Metadata: SLA_Rule__mdt, Assignment_Config__mdt, Billing_Config__mdt
```

## Key decisions (interview answers)
| Decision | Why |
|---|---|
| **Case** = service request | Case gives status, owners/queues, escalation fields, reporting for free. |
| Separate **Work_Order__c** | One request can need several visits; the visit has its own lifecycle (technician, times, parts). Case statuses (New/Working/Escalated/Closed) track the *customer's* request; EN_ROUTE/ON_SITE/IN_PROGRESS belong to the *visit*. |
| **Technician__c** custom object linked to User | A technician needs data (skills, location, workload) a User/Contact can't hold cleanly; optional `User__c` lets the technician log in and own their work orders. |
| **Junction** `Technician_Skill__c` (2 master-detail) | Many-to-many: a technician has many skills; a skill belongs to many technicians. |
| `Part_Usage__c` master-detail to Work Order | Needed for a **roll-up summary** (`Parts_Total__c`) and cascade delete. Lookup to Part (Restrict delete) so history can't lose a part. |
| Lookups for Case→Technician, Invoice→Work Order | Independent lifecycles; no roll-up needed. |
| Custom Metadata for SLA/weights/tax | Admins change rules without code deploys; readable in Apex without SOQL limits. |
| Apex triggers (not Flow) for work-order logic | State machine, bulk aggregates, row locking and cross-object consistency are safer and testable in Apex. Simple notifications/screens would be Flow candidates. |
| **Batch + Scheduled Apex** for SLA | Needs a time-based scan of potentially many cases, chunked. (A Scheduled Flow could do small volumes; Batch scales.) |
| **Platform Event** on completion | Decouples "job completed" from what reacts (close case, create feedback). New subscribers (notifications, analytics) need no change to the publisher. |
| No Queueable | Nothing here needs it yet (no callout/chaining). It arrives with the REST integration. |
