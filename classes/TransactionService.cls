/**
 * Name: TransactionService
 * Purpose: Service class for transaction records.
 * Test Class: TransactionItemTriggerTest
 * -----------------------------------------------------------------------
 * Date			 Name 					Description
 * -----------------------------------------------------------------------
 * 08/09/2023	 Ramya Chintakula		Created
 */
public class TransactionService {
    
    /**
     * Method Name: sendTransaction
     * Purpose: Send the transaction record to the integration.
     */
     public static void sendTransaction(Transaction__c  transactionRec){  
         // preparing JSON request body for transaction
         String jsonData = prepareJSONBody(transactionRec);
		 transactionSendCallout(jsonData);   
     }
    
    private static String prepareJSONBody(Transaction__c  transactionRec){
		 JSONGenerator jsonBody = JSON.createGenerator(true);
         jsonBody.writeStartObject();                	  
         jsonBody.writeFieldName('keys');
         jsonBody.writeStartObject();
         jsonBody.writeStringField('TransactionID',transactionRec.Id);
         jsonBody.writeEndObject(); 
         jsonBody.writeFieldName('values');
         jsonBody.writeStartObject();
         jsonBody.writeStringField('TotalCost',string.valueof(transactionRec.total_cost__c));
         jsonBody.writeStringField('TotalDiscount',string.valueof(transactionRec.total_discount__c));
         jsonBody.writeStringField('TransactionDate',string.valueof(Date.valueof(transactionRec.createddate)));
         jsonBody.writeEndObject();  
         jsonBody.writeEndObject();                 
         String jsonData = jsonBody.getAsString();
         System.debug('Transaction request body: '+jsonData);
         return jsonData;
    }
    
    private static void transactionSendCallout(String jsonData){
        Http http = new Http();
         HttpRequest request = new HttpRequest();
         request.setEndpoint('http://api.example.com/accounts'); //   // Should be a named credential and Remote Site Settings to be created
         request.setMethod('POST');        	
         request.setBody(jsonData);
         // send transaction request
         HttpResponse response = http.send(request);
         if( response.getStatusCode() != 200) {// can add status codes 201 and 202 also depending on the requirement
             // error/application logging can be added here
             System.debug('Error occured in sending Transaction records to Integration');
         }  
    }
}