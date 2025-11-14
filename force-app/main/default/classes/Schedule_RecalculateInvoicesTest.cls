@isTest
public class Schedule_RecalculateInvoicesTest {

    @isTest
    static void testScheduleRecalculateInvoices() {
        Account acc1 = new Account(Name = 'Account A');
        Account acc2 = new Account(Name = 'Account B');
        insert new List<Account>{ acc1, acc2 };

        insert new List<Invoice__c>{
            new Invoice__c(Name = 'Inv-1', Account__c = acc1.Id, Amount__c = 200),
            new Invoice__c(Name = 'Inv-2', Account__c = acc1.Id, Amount__c = 300),
            new Invoice__c(Name = 'Inv-3', Account__c = acc2.Id, Amount__c = 400)
        };

        Test.startTest();

        Schedule_RecalculateInvoices job = new Schedule_RecalculateInvoices();
        job.execute(null); 

        Test.stopTest();

        List<Account> updatedAccounts = [
            SELECT Id, Custom_Total__c FROM Account WHERE Id IN :new List<Id>{acc1.Id, acc2.Id}
        ];

        System.assertEquals(500, updatedAccounts[0].Custom_Total__c,
            'Account A should have total 200 + 300 = 500');
        System.assertEquals(400, updatedAccounts[1].Custom_Total__c,
            'Account B should have total 400');
    }

    @isTest
    static void testScheduleInvocationUsingSystemSchedule() {
        String cron = '0 0 2 * * ?'; 
        Test.startTest();
        String jobId = System.schedule('Test Recalc Job', cron, new Schedule_RecalculateInvoices());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
}