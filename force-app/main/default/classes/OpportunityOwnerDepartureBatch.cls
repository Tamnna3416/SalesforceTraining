public class OpportunityOwnerDepartureBatch implements Database.Batchable<SObject> {

    private static final Integer DAYS_NOTIFY = 7;   
    private static final Integer DAYS_REASSIGN = 2; 

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = Date.today();
        Date date7 = today.addDays(DAYS_NOTIFY);
        Date date2 = today.addDays(DAYS_REASSIGN);

        return Database.getQueryLocator([
            SELECT Id, Name, StageName,
                   Owner.Id,
                   Owner.Name,
                   Owner.Email,
                   Owner.ManagerId,
                   Owner.Manager.Name,
                   Owner.Manager.Email,
                   Owner.Termination_Date__c
            FROM Opportunity
            WHERE StageName NOT IN ('Closed Won', 'Closed Lost')
              AND Owner.IsActive = true
              AND Owner.Termination_Date__c IN :new List<Date>{ date7, date2 }
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        List<Opportunity> oppsToReassign = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Date today = Date.today();
        Date date7 = today.addDays(DAYS_NOTIFY);
        Date date2 = today.addDays(DAYS_REASSIGN);

        for (Opportunity opp : scope) {
            User owner = opp.Owner;
            User manager = owner.Manager;
            Date termDate = owner.Termination_Date__c;

            if (manager == null || manager.Email == null) {
                continue; 
            }

            if (termDate == date7) {
                 emails.add(
                     OpportunityOwnerEmailService.buildEmail(manager.Email, 'Upcoming Departure Notice: ' + owner.Name, 
                           OpportunityOwnerEmailService.emailReminderBody(manager.Name, owner.Name, opp, termDate)));
            }
           
            if (termDate == date2 && manager.Id != null) {
                opp.OwnerId = manager.Id;
                oppsToReassign.add(opp);
                
                emails.add(
                    OpportunityOwnerEmailService.buildEmail(manager.Email, 'Opportunity Reassigned to You: ' + opp.Name,
                           OpportunityOwnerEmailService.emailReassignBody(manager.Name, owner.Name, opp, termDate)));
            }
        }

        
        if (!oppsToReassign.isEmpty()) {
            update oppsToReassign;
        }

        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('OpportunityOwnerDepartureBatch execution completed.');
    }
    
 

}