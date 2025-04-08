/**
 * @description       : Purpose of this class to is to send an email to the My Program Approver
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   16-03-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalApproveAgentMyProgram  implements clcommon.PortalCustomRemoteAPI1 {
    // Parameter constants specific for this class starts
    private static final String PROGRAM_ID = 'programId';
    private static final String REPLACE_STRING = 'Url:[delegate=';
    private static final String RTAE_CARD_URL = '/lightning/r/genesis__Rate_Card_Setup_Header__c/';
    private static final String VIEW_MODE = 'view';
    private static final String EMAILSUBJECT = 'My Program Approval Request';
    private static final String COMMENT_KEY = 'genesis__Description__c';
    // Parameter constants specific for this class ends
    clcommon.Response response = new clcommon.Response();
    String myProgramID = '';
    String comment = '';
    List<String> emailIdList = new List<String>();
    /**
    * @description sends email to the my program approver
    * @author Soumik Pattanayak | 08-10-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            if(request.get(PROGRAM_ID) == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            myProgramID = String.valueOf(request.get(PROGRAM_ID));
            
            comment = String.valueOf(request.get(COMMENT_KEY));
            
            //query the details of the my program to be shown
            genesis__Rate_Card_Setup_Header__c objMyProgram = [SELECT Id,
                                                                        Name,
                                                                        Status__c,
                                                                        Account__r.Name
                                                                        FROM genesis__Rate_Card_Setup_Header__c
                                                                        WHERE Id = :myProgramID];
            if(objMyProgram == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }                                                            
            objMyProgram.Status__c = PortalConstants.SUBMITTED_MY_PROGRAM;
            objMyProgram.genesis__Description__c = comment;
            
            Database.update(objMyProgram,true);
            String baseURL =String.valueOf(System.URL.getOrgDomainUrl());
            String myProgramURL = (baseURL.replace(REPLACE_STRING,'')).replace(']','');
            myProgramURL = myProgramURL +RTAE_CARD_URL+myProgramID+'/'+VIEW_MODE;                                                        
            //send email to the members of the approver queue
            List<Group> approverQueueList =[SELECT Id 
                                            FROM GROUP
                                            WHERE Name = :PortalConstants.MY_PROGRAM_QUEUE];
            List<GroupMember> approverUserList =   [SELECT  Id,
                                                            UserOrGroupId,
                                                            GroupId
                                                    FROM GroupMember
                                                    WHERE GroupId = :approverQueueList[0].Id];
            for(GroupMember objGroupMember : approverUserList){
                //get the user email address
                User approver = [SELECT Id, 
                                        Username, 
                                        Email 
                                FROM User 
                                WHERE Id = :objGroupMember.UserOrGroupId];
                emailIdList.add(approver.Email);                                
            }
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            //set the email Ids of the approvers
            String htmlBody = PortalHelper.getHtmlForMyProgramApproval(objMyProgram.Account__r.Name, myProgramURL, objMyProgram.Name);
            emailMessage.setToAddresses(emailIdList);
            emailMessage.subject = EMAILSUBJECT;
            emailMessage.setHtmlBody(htmlBody);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
            if(results.size() > 0){
                if (results[0].success) {
                    response.status = clcommon.Constants.SUCCESS;
                } else {
                    throw new CustomException(ConstantValues.EMAIL_SEND_FAILED); 
                }
            }
        } 
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
        } 
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;                                  
    }
}