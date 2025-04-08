/**
 * @description       : Helper class Exception handling and logs
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public inherited sharing class AsyncHelper {

    /**
     * @description Creating a wrapper class for log.
     */
    public class AsyncLogWrapper {
        public Type className;
        public String jobId;
        public String logString;
        public Exception objException;
    }

    /**
    * @description Logs batch exceptions in clcommon__Batch_Process_Log__c
    * @author Rahul Gupta | 08-02-2023 
    * @param objAsyncLogWrapper 
    **/
    public static void logBatchJobException(AsyncLogWrapper objAsyncLogWrapper) {

        String message = '';

        if (objAsyncLogWrapper.objException != null) {
            message += '====== StackTrace: ' + objAsyncLogWrapper.objException.getStackTraceString() 
                            + ' ====== Message: ' + objAsyncLogWrapper.objException.getMessage();
        }

        if (objAsyncLogWrapper.logString != null) {
            message += ' ====== Additional Details: ' + objAsyncLogWrapper.logString;
        }
        
        if(Schema.sObjectType.clcommon__Batch_Process_Log__c.isCreateable()) {
            clcommon__Batch_Process_Log__c batchProcessLog = 
                                    new clcommon__Batch_Process_Log__c(
                                                clcommon__Batch_Job_Id__c=objAsyncLogWrapper.jobId,
                                                clcommon__Message__c=message,
                                                clcommon__Batch_Id__c=objAsyncLogWrapper.className.toString(),
                                                clcommon__Timestamp__c=System.now()
                                            );
        
            Database.insert(batchProcessLog, true);
        }
    }

    /**
    * @description Logs async exceptions in clcommon__Log__c
    * @author Rahul Gupta | 09-27-2023 
    * @param objAsyncLogWrapper 
    **/
    public static void logAsyncJobException(AsyncLogWrapper objAsyncLogWrapper) {
        String message = '';

        if (objAsyncLogWrapper.objException != null) {
            message += '====== StackTrace: ' + objAsyncLogWrapper.objException.getStackTraceString() 
                            + ' ====== Message: ' + objAsyncLogWrapper.objException.getMessage();
        }

        if (objAsyncLogWrapper.logString != null) {
            message += ' ====== Additional Details: ' + objAsyncLogWrapper.logString;
        }
        if(Schema.sObjectType.clcommon__Log__c.isCreateable()) {
            clcommon__Log__c log = new clcommon__Log__c(
                    Name=objAsyncLogWrapper.className.toString(),
                    clcommon__Message__c=message,
                    clcommon__Time__c=System.now()
                );
        
            Database.insert(log, true);
        }
    }

    /**
    * @description Getting Asynchronus Log Wrapper Instance
    * @author Rahul Gupta | 08-02-2023 
    * @param className 
    * @param jobId 
    * @param objException 
    * @return AsyncLogWrapper 
    **/
    public static AsyncLogWrapper getAsyncLogWrapperInstance(Type className, String jobId, Exception objException) {
        AsyncLogWrapper objAsyncLogWrapper = new AsyncLogWrapper();
        objAsyncLogWrapper.jobId = jobId;
        objAsyncLogWrapper.className = className;
        objAsyncLogWrapper.objException = objException;

        return objAsyncLogWrapper;
    }

    /**
    * @description Getting Asynchronus Log Wrapper Instance
    * @author Rahul Gupta | 09-27-2023  
    * @param className 
    * @param objException 
    * @return AsyncLogWrapper 
    **/
    public static AsyncLogWrapper getAsyncLogWrapperInstance(Type className, Exception objException) {
        AsyncLogWrapper objAsyncLogWrapper = new AsyncLogWrapper();
        objAsyncLogWrapper.className = className;
        objAsyncLogWrapper.objException = objException;

        return objAsyncLogWrapper;
    }

    /**
    * @description Getting Asynchronus Log Wrapper Instance
    * @author Ayan Bhowmik | 02-27-2024 
    * @param className 
    * @return AsyncLogWrapper 
    **/
    public static AsyncLogWrapper getAsyncLogWrapperInstance(Type className) {
        AsyncLogWrapper objAsyncLogWrapper = new AsyncLogWrapper();
        objAsyncLogWrapper.className = className;

        return objAsyncLogWrapper;
    }
}