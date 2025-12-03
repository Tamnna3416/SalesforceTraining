public class ProductUsageBatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
      ProductUsageBatch productUsageBatch = new ProductUsageBatch();
      DataBase.executeBatch(productUsageBatch,200);
    }

}