public class ProductUsageBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,
                   Usage_Units__c,
                   Usage_Date__c,
                   Account__c,
                   Account__r.Id,
                   Account__r.Name,
                   Account__r.Allowed_Usage__c,
                   Account__r.Daily_Usage__c,
                   Account__r.Times_Exceeded_This_Month__c,
                   Account__r.Risk_Level__c,
                   Account__r.Owner.Email,
                   Account__r.Owner.Name
            FROM Usage_Log__c
            WHERE Usage_Date__c = :Date.today()
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Usage_Log__c> scope) {

        Map<Id, Decimal> usageAgg = new Map<Id, Decimal>();
        Map<Id, Account> accountDataMap = new Map<Id, Account>();

        for (Usage_Log__c log : scope) {

            if (log.Account__c == null) continue;

            accountDataMap.put(log.Account__c, log.Account__r);

            usageAgg.put(
                log.Account__c,
                (usageAgg.containsKey(log.Account__c) ? usageAgg.get(log.Account__c) : 0)
                + log.Usage_Units__c
            );
            
            System.Debug('Account Id ' +  log.Account__c + ' Usage_Units ' + log.Usage_Units__c);
        }

        
        List<Account> updateList = new List<Account>();
        List<Task> taskList = new List<Task>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> oppList = new List<Opportunity>();

        
        for (Id accId : usageAgg.keySet()) {

            Account acc = accountDataMap.get(accId);
            if (acc == null) continue;

            Decimal todayUsage = usageAgg.get(accId);

            Account accToUpdate = new Account(
                Id = accId,
                Daily_Usage__c = todayUsage
            );

            if (todayUsage > acc.Allowed_Usage__c) {

                taskList.add(new Task(
                    Subject = 'Usage exceeded allowed limit',
                    WhatId = accId,
                    Status = 'Open',
                    Priority = 'High'
                ));

                accToUpdate.Risk_Level__c = 'High';

                if (acc.Owner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId('0D2dL00000033hJ');
                    email.setToAddresses(new String[]{ acc.Owner.Email });
                    email.setSubject('Usage Limit Exceeded for Account ' + acc.Name);
                    email.setPlainTextBody(
                        'Hi ' + acc.Owner.Name + ',\n\n' +
                        'Account "' + acc.Name + '" exceeded its allowed usage today.\n\n' +
                        'Usage Today: ' + todayUsage + '\n' +
                        'Allowed: ' + acc.Allowed_Usage__c + '\n\n' +
                        'A task has been created.\n\n' +
                        'Regards,\nSystem'
                    );
                    emailList.add(email);
                }

                Decimal count = acc.Times_Exceeded_This_Month__c == null ? 1 :
                                acc.Times_Exceeded_This_Month__c + 1;

                accToUpdate.Times_Exceeded_This_Month__c = count;

                if (count == 3) {
                    oppList.add(new Opportunity(
                        AccountId = accId,
                        Name = 'Auto-Upsell - ' + Date.today().format(), 
                        StageName = 'Upsell Recommended',
                        CloseDate = Date.today().addDays(30)
                    ));
                }
            }

            updateList.add(accToUpdate);
        }

        
        if (!updateList.isEmpty()) update updateList;
        if (!taskList.isEmpty()) insert taskList;
        if (!oppList.isEmpty()) insert oppList;
        if (!emailList.isEmpty()) Messaging.sendEmail(emailList);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Completed Product Usage Batch');
    }
}