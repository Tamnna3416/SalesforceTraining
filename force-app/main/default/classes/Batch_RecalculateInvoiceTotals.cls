public class Batch_RecalculateInvoiceTotals implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Account> accToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            Decimal total = 0;
            for (Invoice__c inv : [SELECT Amount__c FROM Invoice__c WHERE Account__c = :acc.Id]) {
                total += inv.Amount__c;
            }
            acc.Custom_Total__c = total;
            accToUpdate.add(acc);
        }
        
        if (!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Finished recalculating invoice totals for ' + bc);
    }
}