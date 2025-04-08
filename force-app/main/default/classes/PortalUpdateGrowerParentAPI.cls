/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : Shruti Tamakhuwala
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-11-2025   Rahul Gupta   Initial Version
**/
global without sharing class PortalUpdateGrowerParentAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String CLASS_NAME = PortalUpdateGrowerParentAPI.class.getName();
    private static final String COMMUNITY_NAME = 'community_name';
    private static final String GL_GROWER = 'gl_grower';
    private static final String WL_GROWER = 'wl_grower';
    
    /**
    * @description overridden method to process the Portal API request
    * @author Rahul Gupta | 01-11-2025 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> request) {

        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        try {
            List<Account> growerAccounts = [
                    SELECT Id, ParentId, Parent.Coop_Type__c, RecordType.Name
                    FROM Account
                    WHERE Id IN (
                        SELECT AccountId
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                    )
                    LIMIT 1
                ];

            if (growerAccounts.isEmpty()) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            
            // get the community the grower is trying to login
            String currentLoggedInCommunity = String.valueOf(request.get(COMMUNITY_NAME));

            if (!(growerAccounts[0].RecordType.Name).equalsIgnoreCase(PortalConstants.GROWER_PROFILE) || !isCoopTypeSwitching(currentLoggedInCommunity, growerAccounts[0].Parent.Coop_Type__c)) {
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }

            // get the latest related dealer under that community
            Id latestDealer = getLatestRelatedDealerForCommunity(currentLoggedInCommunity, growerAccounts[0].Id);

            // assign that dealer as its parent
            growerAccounts[0].ParentId = latestDealer;          
            Database.update(growerAccounts[0], true);

            response.status = clcommon.Constants.SUCCESS;

        } catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            LoggingUtility.saveExceptionLogging(customException, CLASS_NAME);

        } catch (Exception standardException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            LoggingUtility.saveExceptionLogging(standardException, CLASS_NAME);
        }

        return response;
    }

    /**
    * @description the purpose of this method is check if the grower switching between gray label and white label
    * @author Rahul Gupta | 01-11-2025 
    * @param currentCommunity 
    * @param latestCoopType 
    * @return Boolean 
    **/
    private static Boolean isCoopTypeSwitching(String currentCommunity, String latestCoopType) {
        
        if (latestCoopType.equals(ConstantValues.GROWMARK_COOP_TYPE) && 
            currentCommunity.equals(GL_GROWER)) {
            return true;
        }

        if (!latestCoopType.equals(ConstantValues.GROWMARK_COOP_TYPE) && 
            currentCommunity.equals(WL_GROWER)) {
            return true;
        }

        return false;
    }

    /**
    * @description purpose of this method is to get the latest related dealer under that community for the logged in grower
    * @author Rahul Gupta | 01-11-2025 
    * @param community 
    * @param growerAccountId 
    * @return Id 
    **/
    private static Id getLatestRelatedDealerForCommunity(String community, Id growerAccountId) {

        List<Dealer_Applicant_Relationship__c> dealerRelations;
        
        if (community.equals(WL_GROWER)) {
            dealerRelations = [
                    SELECT Id, 
                            Dealer__c, 
                            Applicant__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Applicant__c = :growerAccountId
                    AND Dealer__r.Coop_Type__c = :ConstantValues.GROWMARK_COOP_TYPE
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
        } else if (community.equals(GL_GROWER)) {
            dealerRelations = [
                    SELECT Id, 
                            Dealer__c, 
                            Applicant__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Applicant__c = :growerAccountId
                    AND Dealer__r.Coop_Type__c != :ConstantValues.GROWMARK_COOP_TYPE
                    AND Dealer__r.Coop_Type__c != null
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
        }

        if (dealerRelations.isEmpty()) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        return dealerRelations[0].Dealer__c;
    } 
}