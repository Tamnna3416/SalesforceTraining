@isTest
private class BatchInactiveContactsTest {

    @isTest
    static void testBatchInactiveContacts() {
        Contact oldC = new Contact(LastName = 'Old Contact', Status__c = 'Active');
        insert oldC;

        Test.setCreatedDate(oldC.Id, System.today().addYears(-2));

        Test.startTest();
        Database.executeBatch(new BatchInactiveContacts(), 200);
        Test.stopTest();

        Contact updated = [SELECT Status__c FROM Contact WHERE Id = :oldC.Id];
        System.assertEquals('Inactive', updated.Status__c);
    }
}