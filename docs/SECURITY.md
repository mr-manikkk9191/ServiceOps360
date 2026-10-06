# Security
| Layer | Implementation |
|---|---|
| Object/field | 6 permission sets: Admin, Dispatcher, Technician, Manager, Inventory Manager, Service Agent. FLS generated per role. |
| Record | `Work_Order__c` OWD **Private**; the assigned technician's User is set as owner so technicians see only their jobs. Dispatcher/Manager/Admin have View All. |
| Hidden data | Technicians cannot see other technicians' workload/coordinates, part unit cost, or invoices; they can edit only Work Order Status/Resolution and Part Usage part/quantity. |
| Apex | `with sharing` by default; `WITH USER_MODE` / `update as user` in LWC controllers. `without sharing` only in `CaseCompletionService` (Automated Process user) — documented in code. |
| Not yet done | Role hierarchy / sharing rules, permission set groups, assigning permission sets to real users (see DEPLOYMENT.md). |
