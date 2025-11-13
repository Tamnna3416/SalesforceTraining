public class BatchInactiveContacts implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date oneYearAgo = System.today().addYears(-1);
        //Uncomment below line for testing purpose
        //Date oneYearAgo = System.today().addDays(-1);
        return Database.getQueryLocator([
            SELECT Id, LastModifiedDate, Status__c 
            FROM Contact
            WHERE LastModifiedDate < :oneYearAgo 
            AND (Status__c = 'Active' OR Status__c = null)
        ]);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for(Contact c : scope){
            c.Status__c = 'Inactive';
        }
        update scope;
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('All contacts older than 1 year marked Inactive.');
    }
}