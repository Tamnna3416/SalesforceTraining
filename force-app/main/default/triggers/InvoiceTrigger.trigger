trigger InvoiceTrigger on Invoice__c (
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isAfter) {
        InvoiceTriggerHandler.recalculateAccountTotals(
            Trigger.new, 
            Trigger.old
        );
    }
}