/**
 * Name: BatchSendTransactionItems
 * Purpose: Batch class to send transaction Items and transactions to integration.
 * Test Class: 
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */
public class BatchSendTransactionItems  implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    Set<Id> transactionItemIdsSet  = new Set<Id>();
	Set<Id> transactionIdsSet  = new Set<Id>();
    
    public BatchSendTransactionItems(Set<Id> txnItemIdsSet, Set<Id> txnIdsSet){
        this.transactionItemIdsSet = txnItemIdsSet;
        this.transactionIdsSet = txnIdsSet;
	}
   public Database.QueryLocator start(Database.BatchableContext BC){
   		String query;
        // Fetch Transaction records and transaction Item records
      	query = 'SELECT id, total_cost__c, total_discount__c, createddate, (Select id, name, cost__c, transaction__c  from Transaction_Items__r Where Id IN :transactionItemIdsSet)';
      	query = query + ' from Transaction__c where Id IN  :transactionIdsSet' ;
      	System.debug('Query is: ' +query);
		return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
		//pick a transaction and fetch  all transaction item records from the scope 
        // format them as JSON and send the txn Items records
        // if thats success, then send the transaction records
       System.debug('scope is: ' +scope);
       for(Sobject s : scope){
           Transaction__c transactionRec = (Transaction__c)s;
           List<Transaction_Item__c> transactionItemsList = transactionRec.transaction_Items__r;
           System.debug('Iransaction Items are: ' +transactionItemsList);
           String jsonTransactionItems = prepareTransactionItems(transactionItemsList); // Should be  put this is Service classes
           // Send Transaction Item records to integration, if they are success, then send corrresponding transaction record
           if(sendTransactionItems(jsonTransactionItems) == 200){
               String jsonTransaction = prepareTransaction(transactionRec); // Should be  put this is Service classes
               if(sendTransaction(jsonTransaction) != 200){
                  //error logging
               }
           } else {
		   	   //error logging
           }
           
      	}    
       
   }
    
    private static string prepareTransactionItems(List<Transaction_Item__c> transactionItemsList){
        String jsonTransactionItems = '';
        // prepare JSON
        return jsonTransactionItems;
    }
    
    private static Integer sendTransactionItems(String jsonTransactionItems){
        Integer responseCode = 200;
        // send request 
        return responseCode;
        
    }   
    
    private static string prepareTransaction(Transaction__c transactions){
        String jsonTransaction = '';
        // prepare JSON
        return jsonTransaction;
    }
    
	private static Integer sendTransaction(String jsonTransaction){
        Integer responseCode = 200;
        // send request 
        return responseCode;
        
    } 
    

   public void finish(Database.BatchableContext BC){
       // Do some checks if there are any required
       // send any emails if required
   }

}
