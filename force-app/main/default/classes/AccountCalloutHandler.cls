public class AccountCalloutHandler {

    @future (callout=true)
    public static void sendAccountData(Set<Id> accountIds) {
        List<Account> accList = [SELECT Id, Name, Industry FROM Account WHERE Id IN :accountIds];

        for (Account acc : accList) {
            System.debug('Sending Account data to external system: ' + acc.Name);
            acc.External_System_Status__c = 'Data Sent Successfully';
        }
        update accList;
    }
}