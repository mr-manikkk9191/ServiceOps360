# Data Model

```
Account/Contact ─ Case ──< Work_Order__c ──< Part_Usage__c >── Part__c ──< Purchase_Request__c
                    │            │   │
                    │            │   └──< Invoice__c        Work_Order__c ──< Feedback__c >── Technician__c
                    ▼            ▼
              Technician__c (lookup from Case and Work_Order__c)
              Technician__c ──< Technician_Skill__c >── Skill__c
```
| Object | Notes |
|---|---|
| Case (std) | + Service_Category__c, SLA_Deadline__c, SLA_Status__c (formula), Assigned_Technician__c, Location lat/long, Resolution_Notes__c, Completion_Date__c, Escalated__c. Priority gets **Critical**. |
| Technician__c | Status (AVAILABLE/BUSY/OFFLINE/ON_LEAVE), lat/long, Current_Workload__c (maintained by Apex), User__c |
| Skill__c / Technician_Skill__c | Many-to-many junction |
| Work_Order__c | Status ASSIGNED→ACCEPTED→EN_ROUTE→ON_SITE→IN_PROGRESS→COMPLETED/CANCELLED; Parts_Total__c roll-up; OWD Private |
| Part__c / Part_Usage__c | Stock, reorder level; usage line total (formula) |
| Purchase_Request__c | Auto-created when stock ≤ reorder level |
| Invoice__c | Labour + Parts + Tax = Total (formula) |
| Feedback__c | Rating 1–5 validation |
| Job_Completed__e | Platform Event |
