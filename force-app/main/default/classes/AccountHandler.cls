public class AccountHandler {
    
    public static void updateAccountRollups(List<Opportunity> newList) {
        
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : newList) {
        if (opp.AccountId != null) {
            accountIds.add(opp.AccountId);
        }
    }
    if (accountIds.isEmpty()) return;

    List<Account> accountsToUpdate = new List<Account>();

    for (Account acc : [
        SELECT Id,
               (SELECT Id, Amount 
                FROM Opportunities 
                WHERE StageName = 'Closed Won')
        FROM Account
        WHERE Id IN :accountIds
    ]) {
        Decimal totalWonAmount = 0;
        for (Opportunity wonOpp : acc.Opportunities) {
            if (wonOpp.Amount != null) {
                totalWonAmount += wonOpp.Amount;
            }
        }
        acc.Status__c = (totalWonAmount > 5000000) ? 'Strategic Partner' : 'Standard';
        accountsToUpdate.add(acc);
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}


}