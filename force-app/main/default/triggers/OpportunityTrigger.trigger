trigger OpportunityTrigger on Opportunity (before insert, before update,
    after insert, after update
) {
    if (Trigger.isBefore) {
        OpportunityHandler.applyHighValueValidations(Trigger.new, Trigger.oldMap);
    }
   
    if (Trigger.isAfter) {
        AssignOpportunityTeamMembers.assignHighValueTeamMembers(Trigger.new, Trigger.oldMap);
        AccountHandler.updateAccountRollups(Trigger.new);
    }
}