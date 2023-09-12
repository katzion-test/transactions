/**
 * Name: transactionItemTrigger
 * Purpose: Trigger for Transaction_Item__c object
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */

trigger transactionItemTrigger on Transaction_Item__c (after insert) {
	// After Insert, call the handler method for processing
	System.debug('In Trigger');
	if(Trigger.isAfter && Trigger.isInsert){ 
        System.debug('In After Insert Trigger');
        TransactionItemTriggerHandler.handleAfterInsert(Trigger.New);
    }    
}