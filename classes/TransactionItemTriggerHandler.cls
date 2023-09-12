/**
 * Name: TransactionItemTriggerHandler
 * Purpose: Handler class for transactionItemTrigger Trigger.
 * Test Class: TransactionItemTriggerTest
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */

public class TransactionItemTriggerHandler { 
	// After Insert Trigger handler
    public static void handleAfterInsert(List<Transaction_Item__c> transactionItemsList){
		// sends transaction items and transactions to integration        
        TransactionItemsService.integrationCallouts(transactionItemsList);
        //TransactionItemsService.integrationCalloutsBatch(transactionItemsList);
    }

}