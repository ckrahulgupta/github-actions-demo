/**
 * @description       : Logging Utility Helper class
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
**/
public with sharing class LoggingUtility {

    
    /**
    * @description : purpose of this method is to save Request log for NLS integration
    * @author  Pritam Roy | 03-07-2024 
    * @param exceptionNameString 
    * @param requestBodyMessage 
    **/
    public static void saveRequestLogging(String exceptionNameString,String requestBodyMessage){
        Database.insert(new clcommon__Log__c(Name = exceptionNameString ,
                        clcommon__Message__c = requestBodyMessage,
                        clcommon__Time__c = System.Now()), false);
    }

    
    /**
    * @description : purpose of this method is to save Response log for NLS integration
    * @author  Pritam Roy | 03-07-2024 
    * @param exceptionNameString 
    * @param responseBodyMessage 
    **/
    public static void saveResponseLogging(String exceptionNameString,String responseBodyMessage){
        Database.insert(new clcommon__Log__c(Name = exceptionNameString ,
                        clcommon__Message__c = responseBodyMessage,
                        clcommon__Time__c = System.Now()), false);
    }
    
    
    /**
    * @description : purpose of this method is to save Exception log.
    * @author  Pritam Roy | 03-07-2024 
    * @param objException 
    * @param exceptionNameString 
    **/
    public static void saveExceptionLogging(Exception objException, String exceptionNameString){
        Database.Insert(new clcommon__Log__c(Name = exceptionNameString ,
                                            clcommon__Message__c = exceptionNameString 
                                            + objException.getStackTraceString()
                                            + objException.getMessage(),
                                            clcommon__Time__c = System.Now()), false);
    }
}