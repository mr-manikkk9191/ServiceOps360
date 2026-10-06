# ServiceOps360 — Intelligent Service & Field Operations Platform

A Salesforce application for field-service companies (AC, electrical, plumbing, appliances, refrigeration, networking).
It manages the full lifecycle: **customer issue → service request → priority & SLA → technician recommendation/assignment → work order → parts used → resolution → invoice → feedback → analytics.**

## What is implemented
| Area | Implementation |
|---|---|
| Service requests | Standard **Case** + custom fields (category, SLA deadline/status, location, escalation) |
| SLA | Deadlines from **Custom Metadata** (`SLA_Rule__mdt`); formula-based SLA status; **Batch + Scheduled Apex** escalation every 15 min |
| Technicians & skills | `Technician__c`, `Skill__c`, junction `Technician_Skill__c` (many-to-many) |
| Assignment engine | Transparent weighted score (skill + distance + workload), weights in `Assignment_Config__mdt` |
| Work orders | `Work_Order__c`, enforced status state machine, timestamps, private sharing (technician sees own jobs) |
| Inventory | `Part__c`, `Part_Usage__c` (stock decrement with row locking), auto `Purchase_Request__c` at reorder level |
| Billing | Draft `Invoice__c` = labour + parts roll-up + tax (`Billing_Config__mdt`) |
| Feedback | `Feedback__c` request created on completion; rating validation |
| Events | `Job_Completed__e` Platform Event → closes Case + creates Feedback request |
| UI | LWC `technicianJobs` (technician app), LWC `dispatcherAssign` (Case quick action) |
| Security | 6 permission sets, FLS, private OWD on Work Orders, `with sharing`, `WITH USER_MODE` |
| Tests | 8 Apex test classes covering positive, negative, bulk, batch, scheduler, event |
| CI/CD | GitHub Actions validate on PR, manual deploy workflow |

**Not implemented (yet):** external maps/distance REST callout (distance uses Haversine on stored coordinates), payment gateway, reports/dashboards.
See `docs/` for architecture, data model, security, testing and deployment.

## Quick start (Windows PowerShell)
```powershell
git clone https://github.com/<you>/ServiceOps360.git
cd ServiceOps360
.\scripts\setup.ps1 -DevHub PropertyManagementOrg   # creates 30-day scratch org, deploys, assigns permission set, seeds data
.\scripts\test.ps1                                   # runs all Apex tests
```
Then open the **ServiceOps360** app from the App Launcher.

## Live demo
GitHub stores the code; the app runs in a Salesforce org. For a permanent demo, deploy this repo into a free Developer Edition org (see `docs/DEPLOYMENT.md`).
