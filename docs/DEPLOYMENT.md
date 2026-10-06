# Deployment

## Scratch org (development)
```powershell
.\scripts\setup.ps1 -DevHub PropertyManagementOrg
```

## Permanent live demo (free Developer Edition org)
1. Sign up at https://developer.salesforce.com/signup (separate from your Dev Hub).
2. `sf org login web --alias demo`
3. `sf project deploy start --source-dir force-app --target-org demo --test-level RunLocalTests`
4. `sf org assign permset --name ServiceOps_Admin --target-org demo`
5. `sf apex run --file scripts/apex/seed-data.apex --target-org demo`
6. `sf apex run --file scripts/apex/schedule-jobs.apex --target-org demo`
Record a short screen-capture or add screenshots to the README; share the org only via a read-only demo user if needed.

## Giving users access
Assign `ServiceOps_Technician` etc. to users. Link each technician's `Technician__c.User__c` to their User so they own their work orders.

## CI/CD (GitHub Actions)
1. Locally: `sf org display --verbose --target-org <org>` and copy the **Sfdx Auth Url**.
2. GitHub repo → Settings → Secrets → add `SFDX_AUTH_URL` (validation org) and, in an Environment named `demo`, `DEMO_SFDX_AUTH_URL`.
3. PRs to `main` run `validate.yml`; `deploy.yml` is run manually. Never commit auth URLs.
