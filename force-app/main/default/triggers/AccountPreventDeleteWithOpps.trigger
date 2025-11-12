trigger AccountPreventDeleteWithOpps on Account (before delete) {
    Set<Id> acctIds = new Set<Id>();
    for (Account a : Trigger.old) if (a.Id != null) acctIds.add(a.Id);

    if (acctIds.isEmpty()) return;

    List<AggregateResult> agg = [
        SELECT AccountId, COUNT(Id) cnt
        FROM Opportunity
        WHERE AccountId IN :acctIds
        GROUP BY AccountId
    ];

    Map<Id, Integer> oppCountByAcct = new Map<Id, Integer>();
    for (AggregateResult ar : agg) {
        oppCountByAcct.put((Id)ar.get('AccountId'), (Integer)ar.get('cnt'));
    }

    for (Account a : Trigger.old) {
        Integer c = oppCountByAcct.containsKey(a.Id) ? oppCountByAcct.get(a.Id) : 0;
        if (c > 0) {
            a.addError('Cannot delete this Account because it has ' + c + ' related Opportunity(ies).');
        }
    }
}