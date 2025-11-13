public class Schedule_RecalculateInvoices implements Schedulable {
    public void execute(SchedulableContext sc) {
        Batch_RecalculateInvoiceTotals batch = new Batch_RecalculateInvoiceTotals();
        Database.executeBatch(batch, 200);
    }
}