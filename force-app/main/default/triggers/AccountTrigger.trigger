trigger AccountTrigger on Account (after insert) {
    Set<Id> accIds = new Set<Id>();
    for (Account acc : Trigger.new) {
        accIds.add(acc.Id);
    }

    AccountCalloutHandler.sendAccountData(accIds);
}