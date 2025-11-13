public class Queueable_NotifyAdmin implements Queueable {

    private List<Id> accountIds;

    public Queueable_NotifyAdmin(List<Id> accIds) {
        this.accountIds = accIds;
    }

    public void execute(QueueableContext context) {
       
       System.debug('Step 3: Notification sent to Admin for accounts → ' + accountIds);
    }
}