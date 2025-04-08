/**
 * Created by Riadh Mankai on 1/11/24.
 * This class is responsible for cleaning up logging data in batches.
 * It is used to remove old and unnecessary log records from the system.
 * The cleanup process is performed in batches to optimize performance and avoid governor limits.
 */
public class LoggingDataCleaningBatch implements Database.Batchable<SObject>, Database.Stateful {
	/**
	 * List of object names to clean by default
	 */
	public static List<String> defaultObjectNames = new List<String> {
		  Schema.intframework__Integration_Log__c.getSObjectType().getDescribe().getName(),
		  Schema.clcommon__Execution_Criteria_Result__c.getSObjectType().getDescribe().getName(),
		  Schema.clcommon__Log__c.getSObjectType().getDescribe().getName()
	};

	/**
	 * List of object names to clean
	 */
	private List<String> objectNames;

	/**
	 * Default constructor - clean default object names
	 */
	public LoggingDataCleaningBatch() {
		this.objectNames = defaultObjectNames;
	}

	/**
	 * Constructor - clean specified object names
	 * @param objectNamesParam	List<String> List of object names to clean
	 */
	public LoggingDataCleaningBatch(List<String> objectNamesParam) {
		if (objectNamesParam != null && !objectNamesParam.isEmpty()) {
			this.objectNames = objectNamesParam;
		} else {
			this.objectNames = defaultObjectNames;
		}
	}

	/**
	 * This method is called by the system to start the batch job.
	 * It returns a query locator object that is used to retrieve the records to be processed.
	 * @param BC Database.BatchableContext
	 * @return Database.QueryLocator
	 */
	public Database.QueryLocator start(Database.BatchableContext BC) {
		String currentObjectName = this.objectNames.remove(0);
		String query = String.format('SELECT Id FROM {0} WHERE CreatedDate < LAST_N_DAYS:30', new String[] {
			  currentObjectName
		});
		return Database.getQueryLocator(query);
	}

	/**
	 * This method is called by the system to process (delete) the records returned by the start method.
	 * @param BC Database.BatchableContext
	 * @param scope List<SObject>
	 */
	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		Database.delete(scope, true);
	}

	/**
	 * This method is called by the system after all the records returned by the start method have been processed.
	 * It is used to schedule a new batch job if there are more objectNames to process.
	 * @param BC Database.BatchableContext
	 */
	public void finish(Database.BatchableContext BC) {
		// If there are more objectNames, start a new batch job with them
		if (!this.objectNames.isEmpty()) {
			LoggingDataCleaningBatch batch = new LoggingDataCleaningBatch(this.objectNames);
			Database.executeBatch(batch, 2000);
		}
	}
}