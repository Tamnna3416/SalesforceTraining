public with sharing class AccountOpportunityController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [
            SELECT Id, Name, Industry, Phone,
                (SELECT Id, Name, StageName, Amount, CloseDate 
                 FROM Opportunities ORDER BY CloseDate DESC) 
            FROM Account
            LIMIT 20
        ];
    }
}
