/**
 * Public interfacing methods for logging.
 * 
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class Logger {
    global static void error(Object message) {
        Log.me().put(LoggingLevel.ERROR, message, null);
	}
    global static void warn(Object message) {
        Log.me().put(LoggingLevel.WARN, message, null);
	}
    global static void info(Object message) {
        Log.me().put(LoggingLevel.INFO, message, null);
	}
	global static void debug(Object message) {
        Log.me().put(LoggingLevel.DEBUG, message, null);
	}
    global static void fine(Object message) {
        Log.me().put(LoggingLevel.FINE, message, null);
	}
    global static void finer(Object message) {
        Log.me().put(LoggingLevel.FINER, message, null);
	}
    global static void finest(Object message) {
        Log.me().put(LoggingLevel.FINEST, message, null);
	}

    // Pubish and/or write inmemory log objects to event bus and/or database 
    global static void flush() {
        Log.me().flush();
    }
    
    //Pause logging, any log entries after this will be ignored until resumed.
    global static void pause() {
        Log.me().mute=true;
    }
    //Resumes logging.
    global static void resume() {
        Log.me().mute = false;
    }

    //Defers flushing, means any flush statements are ignored until keepFlushing is invoked. 
    global static void deferFlushing() {
        Log.me().muteFlush = true;
    }
    //Start to respect flush statements, if previously defered. 
    global static void keepFlushing() {
        Log.me().muteFlush = false;
    }
	
    //Returns the current loggin level.
    global static LoggingLevel getCurrentLogLevel() {
        return Log.me().currentLogLevel;
    }
}