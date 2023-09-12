/**
 * Name: TransactionItemTriggerTest
 * Purpose: Test class for TransactionItemTriggerHandler
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */
@isTest
private class TransactionItemTriggerTest {
    /**
     * Method Name: testSingleTransactionCreation
     * Purpose: Test 1 Transaction record with transaction items 
     */
    @isTest
    static void testSingleTransactionCreation() { 
        // Create Transaction
        Transaction__c transactionRec = new Transaction__c(Related_Transaction_Count__c = 2);
		Insert transactionRec;
		
        // Create Transaction Items
        List<Transaction_Item__c> transactionItemsList = new List<Transaction_Item__c>();
        Transaction_Item__c transactionItem1 = new Transaction_Item__c(cost__c = 123.45, discount__c = 34.5, 
                                                                       Transaction__c = transactionRec.ID);
        transactionItemsList.add(transactionItem1) ;
        
 		Transaction_Item__c transactionItem2 = new Transaction_Item__c(cost__c = 111.45, discount__c = 0.5, 
                                                                       Transaction__c = transactionRec.ID);
		transactionItemsList.add(transactionItem2) ;
		
        // Preparing mock responses for callouts
		mockResponse fakeTransactionItemResp = new mockResponse(200,
                                                                'Complete',
                                                                '[{"TransactionItemId": "dummy"}]',
                                                                null);
        Test.setMock(HttpCalloutMock.class, fakeTransactionItemResp);
        
        // Test 
        Test.startTest();
		Insert transactionItemsList;
        Test.stopTest();

        Integer transactionCount = [SELECT count() from Transaction__c];
        Integer transactionItemsCount = [SELECT count() from Transaction_Item__c];   
        
        // assertions
        System.assertEquals(transactionItemsCount,2);
        System.assertEquals(transactionCount,1);        
    }

    /**
     * Method Name: testMultipleTransactionsCreation
     * Purpose: Test multiple Transaction records with transaction items 
     */    
    @isTest
    static void testMultipleTransactionsCreation() {         
        // Create Transactions
        List<Transaction__c> transactionsList = new List<Transaction__c>();
        Transaction__c transactionRec1 = new Transaction__c(Related_Transaction_Count__c = 2);
		transactionsList.add(transactionRec1);
		Transaction__c transactionRec2 = new Transaction__c(Related_Transaction_Count__c = 1);
		transactionsList.add(transactionRec2);  
        Insert transactionsList;      
 		
        // Create Transactions Items
        List<Transaction_Item__c> transactionItemsList = new List<Transaction_Item__c>();
        Transaction_Item__c transactionItem11 = new Transaction_Item__c(cost__c = 123.45, discount__c = 34.5, 
                                                                       Transaction__c = transactionRec1.ID);
        transactionItemsList.add(transactionItem11) ;
        
 		Transaction_Item__c transactionItem12 = new Transaction_Item__c(cost__c = 111.45, discount__c = 0.5, 
                                                                       Transaction__c = transactionRec1.ID);
		transactionItemsList.add(transactionItem12) ;
        
 
		Transaction_Item__c transactionItem21 = new Transaction_Item__c(cost__c = 444.45, discount__c = 78.5, 
                                                                       Transaction__c = transactionRec2.ID);
        transactionItemsList.add(transactionItem21) ;
        
		// generate mock response for HTTP callouts
		mockResponse fakeTransactionItemResp = new mockResponse(200,
                                                                 'Complete',
                                                                 '[{"TransactionItemId": "dummy"}]',
                                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeTransactionItemResp);
                
        // Test 
		Test.startTest();
		Insert transactionItemsList;
		Test.stopTest();
        
        Integer transactionCount = [SELECT count() from Transaction__c];
        Integer transactionItemsCount = [SELECT count() from Transaction_Item__c];   
        
        // assertions
        System.assertEquals(transactionItemsCount,3);
        System.assertEquals(transactionCount,2);
    }
    
    /**
     * Method Name: testNotMatchingCountsCreation
     * Purpose: Test multiple Transaction records with transaction items where related transaction count is 
     * 			not matching the number of transaction items in transaction
     */        
    @isTest
    static void testNotMatchingCountsCreation() { 
        // Create Transactions
        List<Transaction__c> transactionsList = new List<Transaction__c>();
        Transaction__c transactionRec1 = new Transaction__c(Related_Transaction_Count__c = 4);
		transactionsList.add(transactionRec1);
		Transaction__c transactionRec2 = new Transaction__c(Related_Transaction_Count__c = 1);
		transactionsList.add(transactionRec2);  
        Insert transactionsList;      

        // Create Transaction Items
        List<Transaction_Item__c> transactionItemsList = new List<Transaction_Item__c>();
        Transaction_Item__c transactionItem11 = new Transaction_Item__c(cost__c = 123.45, discount__c = 34.5, 
                                                                       Transaction__c = transactionRec1.ID);
        transactionItemsList.add(transactionItem11) ;

        Transaction_Item__c transactionItem12 = new Transaction_Item__c(cost__c = 146.45, discount__c = 33.5, 
                                                                       Transaction__c = transactionRec1.ID);
        transactionItemsList.add(transactionItem12) ;        
 
		Transaction_Item__c transactionItem21 = new Transaction_Item__c(cost__c = 444.45, discount__c = 78.5, 
                                                                       Transaction__c = transactionRec2.ID);
        transactionItemsList.add(transactionItem21) ;
        
        // set mock response for callouts
		mockResponse fakeTransactionItemResp = new mockResponse(200,
                                                                 'Complete',
                                                                 '[{"TransactionItemId": "dummy"}]',
                                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeTransactionItemResp);
        
        // Test 
		Test.startTest();
		Insert transactionItemsList;
		Test.stopTest();
        
        Integer transactionCount = [SELECT count() from Transaction__c];
        Integer transactionItemsCount = [SELECT count() from Transaction_Item__c];   
        
        // Assertions
        System.assertEquals(transactionItemsCount,3);
        System.assertEquals(transactionCount,2);
    }

    /**
     * Method Name: testcalloutFailure
     * Purpose: Test callout failures
     */        
    @isTest
    static void testcalloutFailure() { 
        // Create Transactions
        List<Transaction__c> transactionsList = new List<Transaction__c>();
        Transaction__c transactionRec1 = new Transaction__c(Related_Transaction_Count__c = 4);
		transactionsList.add(transactionRec1);
		Transaction__c transactionRec2 = new Transaction__c(Related_Transaction_Count__c = 1);
		transactionsList.add(transactionRec2);  
        Insert transactionsList;      

        // Create Transaction Items
        List<Transaction_Item__c> transactionItemsList = new List<Transaction_Item__c>();
        Transaction_Item__c transactionItem11 = new Transaction_Item__c(cost__c = 123.45, discount__c = 34.5, 
                                                                       Transaction__c = transactionRec1.ID);
        transactionItemsList.add(transactionItem11) ;

        Transaction_Item__c transactionItem12 = new Transaction_Item__c(cost__c = 146.45, discount__c = 33.5, 
                                                                       Transaction__c = transactionRec1.ID);
        transactionItemsList.add(transactionItem12) ;        
 
		Transaction_Item__c transactionItem21 = new Transaction_Item__c(cost__c = 444.45, discount__c = 78.5, 
                                                                       Transaction__c = transactionRec2.ID);
        transactionItemsList.add(transactionItem21) ;
        
        // set mock response for callouts
		mockResponse fakeTransactionItemResp = new mockResponse(401,
                                                                 'Complete',
                                                                 '[{"TransactionItemId": "dummy"}]',
                                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeTransactionItemResp);
        
        // Test 
		Test.startTest();
		Insert transactionItemsList;
		Test.stopTest();
        
        Integer transactionCount = [SELECT count() from Transaction__c];
        Integer transactionItemsCount = [SELECT count() from Transaction_Item__c];   
        
        // Assertions
        System.assertEquals(transactionItemsCount,3);
        System.assertEquals(transactionCount,2);
    }    
       
}