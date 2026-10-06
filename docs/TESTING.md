# Testing
Run: `.\scripts\test.ps1` (or `sf apex run test --test-level RunLocalTests --code-coverage`).

| Test class | Verifies |
|---|---|
| SlaServiceTest | Critical/High/Medium/Low deadlines from metadata, default priority, priority change, no overwrite, 200-record bulk |
| TechnicianAssignmentServiceTest | A beats B, C excluded (no skill), score formula, assignment side-effects, offline & missing category errors |
| WorkOrderLifecycleTest | Invalid transition, resolution required, full lifecycle → invoice ₹2,360, case closed via Platform Event, feedback created, case stays open if other work is open |
| InventoryServiceTest | Stock decrement, single purchase request, insufficient stock, bulk summing, validation rule |
| SlaEscalationTest | Batch escalates only open at-risk cases; scheduler registers |
| ControllerTest | Technician sees own jobs, status updates, error surfaced to LWC; dispatcher flow |
| GeoUtilTest | Haversine accuracy and null handling |

`Test.startTest()/stopTest()` gives a fresh set of governor limits and forces async work (batch, Platform Event delivery) to finish before assertions.
