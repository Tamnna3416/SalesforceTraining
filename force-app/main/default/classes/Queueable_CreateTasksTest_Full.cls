@isTest
public class Queueable_CreateTasksTest_Full {

    @isTest
    static void testFullQueueableChain() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'ChainTest A'),
            new Account(Name = 'ChainTest B')
        };
        insert accs;

        Test.startTest();

        Queueable_CreateTasks job1 = new Queueable_CreateTasks(new List<Id>{accs[0].Id, accs[1].Id});
        job1.execute(null); 

        Queueable_SendToExternalSystem job2 = new Queueable_SendToExternalSystem(new List<Id>{accs[0].Id, accs[1].Id});
        job2.execute(null);

        Queueable_NotifyAdmin job3 = new Queueable_NotifyAdmin(new List<Id>{accs[0].Id, accs[1].Id});
        job3.execute(null);

        Test.stopTest();

        List<Task> createdTasks = [
            SELECT Id, Subject, WhatId, Status, Priority
            FROM Task
        ];

        System.assertEquals(2, createdTasks.size(), 'Two follow-up tasks must be created.');
        System.assert(createdTasks[0].Subject.contains('inactive account'), 'Task subject must mention account.');
        System.assertEquals('Not Started', createdTasks[0].Status);
        System.assertEquals('Normal', createdTasks[0].Priority);
    }
}