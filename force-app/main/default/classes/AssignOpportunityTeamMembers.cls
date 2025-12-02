public class AssignOpportunityTeamMembers {
    public static void assignHighValueTeamMembers(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : newList) {
            if (opp.Amount >= 1000000) {
                oppIds.add(opp.Id);
            }
        }
        
        User dstUser = [
            SELECT Id FROM User WHERE Alias = 'DST' LIMIT 1
        ];
   
        List<OpportunityTeamMember> teamMembersToInsert = new List<OpportunityTeamMember>();
        
        for (Opportunity opp : [SELECT Id,
           (SELECT Id, UserId FROM OpportunityTeamMembers)
    FROM Opportunity
    WHERE Id IN :oppIds] ){
        
    Boolean alreadyAdded = false;
    for (OpportunityTeamMember otm : opp.OpportunityTeamMembers) {
        if (otm.UserId == dstUser.Id) {
            alreadyAdded = true;
            break;
        }
    }

    if (!alreadyAdded) {
        teamMembersToInsert.add(new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = dstUser.Id,
            TeamMemberRole = 'High-Value Specialist'
        ));
    }
}
      
        if (!teamMembersToInsert.isEmpty()) {
            insert teamMembersToInsert;
        }
        

    }
}