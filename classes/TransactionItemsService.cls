/**
 * Name: TransactionItemsService
 * Purpose: Service class for transactionItem records.
 * Test Class: TransactionItemTriggerTest
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */
public class TransactionItemsService {

    /**
     * Method Name: integrationCallouts
     * Purpose: Check if count of the transaction items inserted in this salesforce transaction is 
     			equal to the 'related transaction Count' field on related Transaction record. 
    			If so, send the transaction items and transaction records to the integration.
     */
    public static void integrationCallouts(List<Transaction_Item__c> transactionItemsList){
        try{
            Map<Id, Set<Id>> transactionIdToTransactionItemIdsMap = new Map<Id, Set<Id>>(); // holds transaction Id and its related transaction Item Ids 
            
            // fetch the counts of number of transaction Items per each transaction in incoming transaction items list
            for(Transaction_Item__c transactionItemRec: transactionItemsList){
                // populate the map of transaction Id to Transaction Item Ids
                if(transactionIdToTransactionItemIdsMap.containsKey(transactionItemRec.Transaction__c)){
                    transactionIdToTransactionItemIdsMap.get(transactionItemRec.Transaction__c).add(transactionItemRec.Id);  
                } else{
                    transactionIdToTransactionItemIdsMap.put(transactionItemRec.Transaction__c, new Set<Id>{transactionItemRec.Id});  
                }           
            }
            
            Set<Id> transactionItemIdsSet = new Set<Id>();  // transaction Item Ids 
            // check if the related transaction count in transaction and transaction items in list are same 
            for(Transaction__c transactionRec : [SELECT id, Related_Transaction_Count__c
                                                 FROM Transaction__c
                                                 WHERE id IN :transactionIdToTransactionItemIdsMap.keySet()]){
                if(transactionIdToTransactionItemIdsMap.containsKey(transactionRec.Id) 
                        && transactionRec.Related_Transaction_Count__c == transactionIdToTransactionItemIdsMap.get(transactionRec.Id).size()){
                    if(transactionIdToTransactionItemIdsMap.containskey(transactionRec.Id)){
                        transactionItemIdsSet.addAll(transactionIdToTransactionItemIdsMap.get(transactionRec.Id));
                    } 
                }                
            }
            transactionIdToTransactionItemIdsMap = new Map<Id, Set<Id>>();  // reinitialise it as it is no longer required
            
            // send transaction items to Integration
            if(!transactionItemIdsSet.isEmpty()){
                prepareTransactionItems(transactionItemIdsSet);
            }
        } catch(Exception e){
            System.debug('Exception occured in Transaction Items Integration Callouts: '+e.getMessage());
        }

	}    

    /**
     * Method Name: prepareTransactionItems
     * Purpose: Prepare the transaction items in JSON format.
     */    
    @future(callout=true)
    public static void prepareTransactionItems(Set<Id> transactionItemIdsSet){
        try{
           Map<Id, Transaction_Item__c> transactionItemsMap = new Map<Id,Transaction_Item__c>([Select Id, name, cost__c, Transaction__c
                                                                                              from Transaction_Item__c 
                                                                                              WHERE id IN :transactionItemIdsSet
                                                                                              ORDER BY Transaction__c]);
            Map<Id, Set<Id>> transactionToTransactionItemsMap = new Map<Id, Set<Id>>();
            
            // mapping transaction items to a transaction
            for(Transaction_Item__c transactionItemRec: transactionItemsMap.values()){
                if(transactionToTransactionItemsMap.containsKey(transactionItemRec.Transaction__c)){
                    transactionToTransactionItemsMap.get(transactionItemRec.Transaction__c).add(transactionItemRec.Id);
                } else{
                    transactionToTransactionItemsMap.put(transactionItemRec.Transaction__c, new Set<Id>{transactionItemRec.Id});
                }
            }
            
            // fetch the transaction records
            Map<Id, Transaction__c> transactionsMap = new Map<Id,Transaction__c>([Select id, total_cost__c, total_discount__c, createddate
                                                                                  from Transaction__c
                                                                                  where id IN :transactionToTransactionItemsMap.keySet()]);
            
            // prepare JSON for transaction Items for a specific transaction
            for(Id transactionId : transactionsMap.keySet()){
                if(transactionToTransactionItemsMap.containsKey(transactionId)){
                    // preparing JSON request body for transaction items of a transaction
                    JSONGenerator jsonBody = JSON.createGenerator(true);
                    jsonBody.writeStartArray();
                    for(Id transactionItemId : transactionToTransactionItemsMap.get(transactionId)){
                        if(transactionItemsMap.containsKey(transactionItemId)){   
                            jsonBody = prepareJSON(transactionItemsMap.get(transactionItemId), jsonBody);
                        }
                    }
                    jsonBody.writeEndArray();
                    String jsonData = jsonBody.getAsString();
                    if(sendTransactionItems(jsonData) == 200){ // can add status codes 201 and 202 also depending on the requirement
                        if(transactionsMap.containsKey(transactionId)){
                            // if transaction items are sent successfully, then send the transaction
                            TransactionService.sendTransaction(transactionsMap.get(transactionId));    
                        }
                    } else {
                        // error/application logging can be added here
                        System.debug('Exception occured in sending Transaction Items to Integration.');
                    }    
				}
            }
        } catch(Exception e){
             System.debug('Exception occured in sending Transaction Items to Integration: '+e.getMessage());
        }    
        
    }
    
    /**
	* Method Name: prepareJSON
	* Purpose: prepare JSON body for the transaction Items.
	*/    
    private static JSONGenerator prepareJSON(Transaction_Item__c transactionItemRec, JSONGenerator jsonBody){
		jsonBody.writeStartObject();                	  
        jsonBody.writeFieldName('keys');
        jsonBody.writeStartObject();
        jsonBody.writeStringField('TransactionItemID',transactionItemRec.Id);
        jsonBody.writeEndObject(); 
        jsonBody.writeFieldName('values');
        jsonBody.writeStartObject();
        jsonBody.writeStringField('ItemCost',string.valueof(transactionItemRec.Cost__c));
        jsonBody.writeStringField('ItemName',string.valueof(transactionItemRec.Name));
        jsonBody.writeEndObject();  
        jsonBody.writeEndObject();
        return jsonBody;
    }  
    
	/**
    * Method Name: sendTransactionItems
    * Purpose: Perform HTTP callouts to send the transaction Items to Integration.
    */
    private static Integer sendTransactionItems(String jsonData){
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://api.example.com/accounts'); // Should be a named credential and Remote Site Settings to be created
        request.setMethod('POST');
        request.setBody(jsonData);
        System.debug('Transaction Items request body: '+request.getBody());  
        // send transaction items 
        HttpResponse response = http.send(request);
        return response.getStatusCode();
    }
    
    /**
     * Method Name: integrationCalloutsBatch
     * Purpose: Check if count of the transaction items inserted in this salesforce transaction is 
     			equal to the 'related transaction Count' field on related Transaction record. 
    			If so, trigger the batch to send the transaction items and transaction records to the integration.
     */
   
    public static void integrationCalloutsBatch(List<Transaction_Item__c> transactionItemsList){
        try{
            Map<Id, Set<Id>> transactionIdToTransactionItemIdsMap = new Map<Id, Set<Id>>(); // holds transaction Id and its related transaction Item Ids 
            Set<Id> transactionItemIdsSet = new Set<Id>();  // transaction Item Ids 
            Set<Id> transactionIdsSet = new Set<Id>();  // transaction Item Ids 
            
            // fetch the counts of number of transaction Items per each transaction in incoming transaction items list
            for(Transaction_Item__c transactionItemRec: transactionItemsList){
                //transactionItemIdsSet.add(transactionItemRec.id);
                
                // populate the map of transaction Id to Transaction Item Ids
                if(transactionIdToTransactionItemIdsMap.containsKey(transactionItemRec.Transaction__c)){
                    transactionIdToTransactionItemIdsMap.get(transactionItemRec.Transaction__c).add(transactionItemRec.Id);  
                } else{
                    transactionIdToTransactionItemIdsMap.put(transactionItemRec.Transaction__c, new Set<Id>{transactionItemRec.Id});  
                }           
            }
            
            // check if the related transaction count in transaction and transaction items in list are same 
            for(Transaction__c transactionRec : [SELECT id, Related_Transaction_Count__c
                                                 FROM Transaction__c
                                                 WHERE id IN :transactionIdToTransactionItemIdsMap.keySet()]){
                if(transactionIdToTransactionItemIdsMap.containsKey(transactionRec.Id) 
                        && transactionRec.Related_Transaction_Count__c == (transactionIdToTransactionItemIdsMap.get(transactionRec.Id)).size()){
                    if(transactionIdToTransactionItemIdsMap.containskey(transactionRec.Id)){
                        transactionIdsSet.add(transactionRec.Id);
                        transactionItemIdsSet.addAll(transactionIdToTransactionItemIdsMap.get(transactionRec.Id));
                    } 
                }                
            }
            transactionIdToTransactionItemIdsMap = new Map<Id, Set<Id>>();  // reinitialise it as it is no longer required
            // send transaction items to Integration
            if(!transactionItemIdsSet.isEmpty()){
                System.enqueueJob(new SendTransactionItemsQueueable(transactionItemIdsSet, transactionIdsSet));  
            }
        } catch(Exception e){
            System.debug('Exception occured in Transaction Items Integration Callouts: '+e.getMessage());
        }

	}
    
}