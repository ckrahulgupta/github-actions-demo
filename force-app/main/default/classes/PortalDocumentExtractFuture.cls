/**
 * @description       : Extract portal document asynchronously
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
**/
global class PortalDocumentExtractFuture {

    /**
     * @description : This method takes a List of Portal Document Id and Extract those Portal Documents.
     * @param recordIds 
     */
	@future
    public static void processRecords(List<String> recordIds) { 
        System.debug('Starting Deployment...');
        
        for (String id : recordIds) {
            clcommon.PortalActions.extractBuilderConfigurations(id);
        }

        System.debug('Deployment Finished...');
    }
}