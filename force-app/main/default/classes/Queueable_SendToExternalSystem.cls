public class Queueable_SendToExternalSystem implements Queueable, Database.AllowsCallouts {

    private List<Id> accountIds;

    public Queueable_SendToExternalSystem(List<Id> accIds) {
        this.accountIds = accIds;
    }

    public void execute(QueueableContext context) {
        System.debug('Step 2: Sending these accounts to external API → ' + accountIds);

        System.enqueueJob(new Queueable_NotifyAdmin(accountIds));
    }
}