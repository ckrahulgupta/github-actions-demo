/**
 * Created by Riadh Mankai on 1/12/2024.
 * Scheduler class for LoggingDataCleaningBatch
 */

public class LoggingDataCleaningScheduler implements Schedulable {
	/**
	 * List of object names to clean by the scheduler
	 */
	private final List<String> objectNames;

	/**
	 * Default constructor
	 */
	public LoggingDataCleaningScheduler() {
		this.objectNames = null;
	}

	/**
	 * Constructor with parameters
	 * @param objectNamesParam List of object names to clean by the scheduler
	 */
	public LoggingDataCleaningScheduler(List<String> objectNamesParam) {
		this.objectNames = objectNamesParam;
	}

	/**
	* Method called by the scheduler
	 * @param SC Scheduler context
*/
	public void execute(SchedulableContext SC) {
		LoggingDataCleaningBatch cleaningBatch = new LoggingDataCleaningBatch(this.objectNames);
		Database.executeBatch(cleaningBatch, 2000);
	}
}