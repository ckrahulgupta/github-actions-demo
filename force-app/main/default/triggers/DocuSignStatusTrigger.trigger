/***************************************************************************************
 * Trigger Name       : DocuSignStatusTrigger
 * Developed By       : simranjha
 * Purpose            : This trigger is fire when there is any update on Envelope status.
 * @created Date      : 04-09-2022
 * @last modified on  : 05-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 ****************************************************************************************/
trigger DocuSignStatusTrigger on dfsle__EnvelopeStatus__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        for(dfsle__EnvelopeStatus__c status : trigger.new){
            clcommon.Response objResponse = new clcommon.Response();
            try{
                //Checking envelope status is completed or not.
                if(status.dfsle__Status__c == PortalConstants.COMPLETED_TASK_STATUS){
                    List<genesis__Applications__c> objApplication = [Select Agreement_Sign__c 
                                                                    FROM genesis__Applications__c 
                                                                    WHERE Id = :status.dfsle__SourceId__c];
                    objApplication[0].Agreement_Sign__c = true;
                    objApplication[0].genesis__Status__c = PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS;
                    Database.upsert(objApplication[0]);
                }
            }
            catch (Exception objException) {
                objResponse.status = clcommon.Constants.API_EXCEPTION;
                objResponse.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            }
        }
    }  
}