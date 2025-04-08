/**
 * This Action class provides interface to flow infrastructure to be able to create log 
 * entries in the central framework. 
 * 
 * Note: All the ApexCRUDViolation rules are explicitly turned off intententionally
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class LogInvocableAction {
     /**
     * Create a log entry
     * 
     * @param preProvisioningRequests List of provisioning requests
     */
    @InvocableMethod(label='Create a Log Entry' 
                    description='Creates a log entry using log.me() library' 
                    category='Pre Provisioning')
    public static void makeLogEntry(List<Request> requestList) {
        Log.me().put(LoggingLevel.valueOf(requestList[0].level), requestList[0].message, requestList[0].source);
        if(requestList[0].forceFlush) {
            Logger.keepFlushing(); //unsets defer action, if previously called.
            Logger.flush();
        } else if(requestList[0].flushNow) {
            Logger.flush();
        }
    }
    //Request payload structure for log entry
    public class Request {
        @InvocableVariable(label='Source' description='Uniquely tracable developer name here. Example is flow developer name' required='true')
        public String source;
        @InvocableVariable(label='Log Level' description='Enter on of the supported log levels. Refer to LoggingLevel for valid values.')
        public String level;
        @InvocableVariable(label='Message' description='Message to be logged')
        public String message;
        @InvocableVariable(label='Flush Now' description='Flush the log entires kept in memory so far, but respects defer flushing')
        public Boolean flushNow = false;
        @InvocableVariable(label='Force Flush' description='Flush log entries and overwrites defer flushing')
        public Boolean forceFlush = false;
    }
}