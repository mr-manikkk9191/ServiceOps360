param([string]$Alias = "ServiceOps360-Dev")
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --wait 20 --target-org $Alias
