/**
 * This Action class provides core loggign framework and publich methods. 
 * 
 * Note: All the ApexCRUDViolation rules are explicitly turned off intententionally
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class Log {
    private static Log instance = null;
    private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
    
	//private static Log__e currentEvent = null;

    //private static LogEntry__c currentRecord = null;

    private List<Map<String,Object>> logEntries = new List<Map<String,Object>>();

    //Logger Dynamic Controls
    public Boolean mute {get; set;}
    public Boolean muteFlush {get; set;}
    public LoggingLevel currentLogLevel {get; set;}

    private Boolean writeToEvent {get; set;}
    private Boolean writeToObject {get; set;}
    private Boolean writeToSystemDebug {get; set;}

    public Log() {
        loadLogSettings();
    }

    public void put(LoggingLevel level, Object message, String source) {
        if(source != null) {
            emit(level, message, 'NonApex:' + source);
        } else {
            emit(level, message, null);
        }
	}

	/**
     * Actual log entry is made by this method depending on settings.  
     */ 
	private void emit(LoggingLevel level, Object message, String source) {
        //Log to System Debug, when enabled.
        if (writeToSystemDebug) {
            System.debug(level, message);
        }

        //Return, if muted. 
        //Don't log if current log level is set to lower than requested log level.
        //No need to log when no logging is enabled.
        if(mute 
            || (currentLogLevel.ordinal() > level.ordinal()) //subham - need to understand
            || (!writeToEvent && !writeToObject)) {
            return;
        }

        // Resolve Apex Source code details where log is invoked from. 
        Map<String, Object> newLogEntry = new Map<String, Object>();

        newLogEntry.put('User__c', UserInfo.getUserId());
        newLogEntry.put('Level__c', level.name());
        newLogEntry.put('Quiddity__c', Request.getCurrent().getQuiddity().name());
        newLogEntry.put('RequestId__c', Request.getCurrent().getRequestId());
        newLogEntry.put('Message__c', String.valueOf(message));
        newLogEntry.put('StackTrace__c', source == null?  getStackTraceString(): null);
        newLogEntry.put('Source__c', source == null? getSourcePointer((String)newLogEntry.get('StackTrace__c')) : source);
        newLogEntry.put('CreatedTime__c', System.now());
        logEntries.add(newLogEntry);
	}

    /**
     * Flush out the log entries from memory to platform events and / or custom object
     */
    public void flush() {
        //Flushing can be paused to control all log enries are published at once 
        //When a complex transaction is invoking other transacdtions to save DMLs.
        if(muteFlush) {
            return;
        }
        List<Log__e> listOfLogEvents = new List<Log__e>();
        List<LogEntry__c> listOfLogEntryObjects = new List<LogEntry__c>();

        for(Map<String, Object> cEntry : logEntries) {
            if(writeToEvent) {
                listOfLogEvents.add(new Log__e(
                    User__c = (String)cEntry.get('User__c'),
                    Level__c = (String)cEntry.get('Level__c'),
                    Quiddity__c = (String)cEntry.get('Quiddity__c'),
                    RequestId__c = (String)cEntry.get('RequestId__c'),
                    Message__c = (String)cEntry.get('Message__c'),
                    StackTrace__c = (String)cEntry.get('StackTrace__c'),
                    Source__c = (String)cEntry.get('Source__c'),
                    CreatedTime__c = (DateTime)cEntry.get('CreatedTime__c')
                ));
            } 
            if(writeToObject) {
                listOfLogEntryObjects.add(new LogEntry__c(
                    User__c = (String)cEntry.get('User__c'),
                    Level__c = (String)cEntry.get('Level__c'),
                    Quiddity__c = (String)cEntry.get('Quiddity__c'),
                    RequestId__c = (String)cEntry.get('RequestId__c'),
                    Message__c = (String)cEntry.get('Message__c'),
                    Source__c = (String)cEntry.get('Source__c'),
                    StackTrace__c = (String)cEntry.get('StackTrace__c'),
                    CreatedTime__c = (DateTime)cEntry.get('CreatedTime__c')
                ));
            }
        }
        if(listOfLogEvents.size() > 0) { EventBus.publish(listOfLogEvents); }
        if(listOfLogEntryObjects.size() > 0) { insert listOfLogEntryObjects; }
        logEntries.clear();
    }
    /**
     * Reads the MDT settings for current user if found and sets the log levels. If not found
     * System setings are read from "System" developer name. 
     * 
     * If no setings are found then System.debug behaviour is emulated.
     */
    private void loadLogSettings() {
        LogSetting__mdt logSettings = LogSetting__mdt.getInstance('UserId_' + UserInfo.getUserId());
        if(logSettings == null) {
            logSettings = LogSetting__mdt.getInstance('ProfileId_' + UserInfo.getProfileId());
        }
        if(logSettings == null) {
            logSettings = LogSetting__mdt.getInstance('System');
        }
        muteFlush = false;
        mute = logSettings != null ? logSettings.Mute__c : false;
        writeToEvent = logSettings != null ? logSettings.WriteToEvent__c : false;
        writeToObject = logSettings != null ? logSettings.WriteToObject__c : false;
        writeToSystemDebug = logSettings != null ? logSettings.WriteToSystemDebug__c : true;
        //Note - Finest log level enables it to reach system debug.
        currentLogLevel = logSettings != null ? LoggingLevel.valueOf(logSettings.LogLevel__c) : LoggingLevel.FINEST; 
    }
    /**
     * Returns the Apex stack trace
     */
    private String getStackTraceString() {
        String stackTraceString = new DmlException().getStackTraceString(); //why DmlException() is used?
        if (stackTraceString.length() > 5000) {
            stackTraceString = stackTraceString.substring(0, 5000);
        }
        return stackTraceString;
    }
    /** 
     * This extracts code information to populate in the log object.
     */ 
	private String getSourcePointer(String stackStraceString) {
		// Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
        String sourcePointer = 'UNKNOWN';
        Map<String, Object> codeDetails =  new Map<String, Object>();
		List<String> stacktrace = stackStraceString.split('\n');
		for(String line : stacktrace) {
			Matcher matcher = STACK_LINE.matcher(line);
            matcher.find();
			//if(matcher.find() && !line.startsWith('Class.Log.') && !line.startsWith('Class.Logger.')) {
				Boolean hasNamespace = String.isNotBlank(matcher.group(3));
				if(hasNamespace && !matcher.group(2).equals('Log') && !matcher.group(2).equals('Logger') && !matcher.group(2).equals('PortalHelper') && !matcher.group(2).equals('LoanServicingHelper')) {
                    //namespace.className.methodName#LineNumber
                    return 'Apex:' + matcher.group(1) + '.' + matcher.group(2) + '.' + prettyMethod(matcher.group(3)) + '#' + String.valueOf(matcher.group(4));
				}
                if(!hasNamespace && !matcher.group(1).equals('Log') && !matcher.group(1).equals('Logger') && !matcher.group(1).equals('PortalHelper') && !matcher.group(2).equals('LoanServicingHelper')) {
                    //className.methodName#LineNumber
                    return  'Apex:' + matcher.group(1) + '.' + prettyMethod(matcher.group(2)) + '#' + String.valueOf(matcher.group(4));
				}
			//}
		}
        return 'UNKNOWN';
	}

    /**
     * Enhances method names to be more readable format. 
     */
	private String prettyMethod(String method) {
		String result = (method == null) ? 'anonymous' : method;
		return (result.contains('init')) ? 'constructor' : result;
	}

    /**
     * Static method returns the singlton instance if found or instantiates one.
     */
    public static Log me() {
        if(instance == null) {
            instance = new Log();
        }
        return instance;
    }
}