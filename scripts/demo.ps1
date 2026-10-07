param([string]$Alias = "ServiceOps360-Dev")
sf apex run --file scripts/apex/demo-job2.apex --target-org $Alias
sf data query --query "SELECT Name, Labour_Amount__c, Parts_Amount__c, Tax_Amount__c, Total_Amount__c FROM Invoice__c ORDER BY Name" --target-org $Alias
