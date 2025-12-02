public class OpportunityHandler {
    
    public static void applyHighValueValidations(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        for (Opportunity opp : newList) {

            Boolean isHighValue = opp.Amount >= 1000000;

            if (Trigger.isUpdate && isHighValue && opp.StageName == 'Closed Won') {
                Opportunity oldOpp = oldMap.get(opp.Id);
                
                Boolean fromRestrictedStage =
                    oldOpp.StageName == 'Prospecting' ||
                    oldOpp.StageName == 'Qualification';

                if (fromRestrictedStage) {
                    opp.StageName.addError('High-Value opportunities cannot move directly from Prospecting or Qualification to Closed Won.');
                }
            }

            if (isHighValue && opp.Probability <= 20) {
                opp.Probability.addError('Probability must be greater than 20% for High-Value Opportunities.');
            }
        }
    }
}