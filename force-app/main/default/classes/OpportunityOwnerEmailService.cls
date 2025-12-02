public class OpportunityOwnerEmailService {

        public static Messaging.SingleEmailMessage buildEmail(String toAddress, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId('0D2dL00000033hJ');  
        mail.setToAddresses(new String[]{ toAddress });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        return mail;
    }
    
      public static String emailReminderBody(String managerName, String ownerName, Opportunity opp, Date termDate) {
        return 
            'Hello ' + managerName + ',\n\n' +
            'This is a reminder that your team member **' + ownerName + '** is scheduled to exit the organization on **' +
            termDate.format() + '**.\n\n' +
            'They currently own the following opportunity:\n' +
            '• Opportunity: ' + opp.Name + '\n' +
            '• Stage: ' + opp.StageName + '\n' +
            '• Id: ' + opp.Id + '\n\n' +
            'Please review and assign a replacement owner in advance.\n\n' +
            'Regards,\nSalesforce Automation';
    }

     public static String emailReassignBody(String managerName, String ownerName, Opportunity opp, Date termDate) {
        return 
            'Hello ' + managerName + ',\n\n' +
            'As part of the departure workflow for **' + ownerName + '** (leaving on ' + termDate.format() + '), ' +
            'the following opportunity has been automatically reassigned to you:\n\n' +
            '• Opportunity: ' + opp.Name + '\n' +
            '• Previous Owner: ' + ownerName + '\n' +
            '• Stage: ' + opp.StageName + '\n' +
            '• Id: ' + opp.Id + '\n\n' +
            'Please review and continue follow-up.\n\n' +
            'Regards,\nSalesforce Automation';
    }
}