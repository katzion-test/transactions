public class SendTransactionItemsQueueable implements Queueable {
    Set<Id> transactionItemIdsSet  = new Set<Id>();
    Set<Id> transactionIdsSet  = new Set<Id>();
    
    public SendTransactionItemsQueueable(Set<Id> txnItemIdsSet, Set<Id> txnIdsSet ){
        this.transactionItemIdsSet = txnItemIdsSet;
        this.transactionIdsSet = txnIdsSet;
    }
    
    public void execute(QueueableContext context) {
		Database.executeBatch(new BatchSendTransactionItems(this.transactionItemIdsSet,this.transactionIdsSet ));
        System.debug('BatchSendTransactionItems batch job started');      
    }
}