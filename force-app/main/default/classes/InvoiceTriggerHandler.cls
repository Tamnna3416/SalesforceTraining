public class InvoiceTriggerHandler {
    public static void recalculateAccountTotals(List<Invoice__c> newList, List<Invoice__c> oldList) {
        Set<Id> acctIds = new Set<Id>();
        if (newList != null) {
            for (Invoice__c inv : newList) {
                if (inv.Account__c != null) acctIds.add(inv.Account__c);
            }
        }
        if (oldList != null) {
            for (Invoice__c inv : oldList) {
                if (inv.Account__c != null) acctIds.add(inv.Account__c);
            }
        }

        if (acctIds.isEmpty()) return;

        List<AggregateResult> aggr = [
            SELECT Account__c acctId, SUM(Amount__c) total
            FROM Invoice__c
            WHERE Account__c IN :acctIds
            GROUP BY Account__c
        ];

        Map<Id, Decimal> sumByAccount = new Map<Id, Decimal>();
        for (AggregateResult r : aggr) {
            Id aId = (Id) r.get('acctId');
            Decimal total = (Decimal) r.get('total');
            sumByAccount.put(aId, total);
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id aId : acctIds) {
            Decimal total = sumByAccount.containsKey(aId) ? sumByAccount.get(aId) : 0;
            accountsToUpdate.add(new Account(Id = aId, Custom_Total__c = total));
        }

        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            } catch (DmlException e) {
                throw e;
            }
        }
    }
}