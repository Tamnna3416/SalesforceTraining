@isTest
private class AccountCalloutHandlerTest {

    @isTest
    static void testSendAccountData() {
        Account acc = new Account(Name = 'Test Future Account', Industry = 'Technology');
        insert acc;
        
        Test.startTest();
        Test.stopTest();

        Account updatedAcc = [SELECT Id, External_System_Status__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(
            'Data Sent Successfully',
            updatedAcc.External_System_Status__c,
            'The External System Status should be updated after future callout'
        );
    }
}