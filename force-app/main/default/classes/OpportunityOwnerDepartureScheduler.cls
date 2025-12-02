public class OpportunityOwnerDepartureScheduler implements Schedulable{
    public void execute(SchedulableContext sc)
    {
        OpportunityOwnerDepartureBatch batch =new  OpportunityOwnerDepartureBatch();
        Database.executeBatch(batch);
    }


}