public class Queueable_CreateTasks implements Queueable {

    private List<Id> accountIds;

    public Queueable_CreateTasks(List<Id> accIds) {
        this.accountIds = accIds;
    }

    public void execute(QueueableContext context) {
        List<Task> tasks = new List<Task>();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountIds]) {
            tasks.add(new Task(
                Subject = 'Follow up on inactive account: ' + acc.Name,
                WhatId = acc.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }
        if (!tasks.isEmpty()) insert tasks;

        System.debug('Step 1 done: Tasks created. Chaining next job.');

        System.enqueueJob(new Queueable_SendToExternalSystem(accountIds));
    }
}