/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Rahul Gupta
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-11-2025   Rahul Gupta   Initial Version
**/
public without sharing class UpdateGrowerParentHandler {

    private static final String CLASS_NAME = UpdateGrowerParentHandler.class.getName();

    private static final String COMMUNITY_LOGIN_TYPE = 'Chatter Communities External User';
    private static final String GRAY_LABEL_GROWER_COMMUNITY = 'Grower Portal';
    private static final String WHITE_LABEL_GROWER_COMMUNITY = 'Growmark Grower Portal';

    
    /**
    * @description 
    * @author Rahul Gupta | 01-11-2025 
    **/
    @InvocableMethod(label = 'Assign Proper Grower Parent')
    public static void assignProperGrowerParent() {

        try {

            // assign that dealer as its parent
            List<Account> growerAccounts = [
                    SELECT Id, ParentId
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
            String currentLoggedInCommunity = getCurrentLoggedInCommunity();

            // get the latest related dealer under that community
            Id latestDealer = getLatestRelatedDealerForCommunity(currentLoggedInCommunity, growerAccounts[0]);

            growerAccounts[0].ParentId = latestDealer;
            
            Database.update(growerAccounts[0], true);

        } catch (CustomException customException) {
            LoggingUtility.saveExceptionLogging(customException, CLASS_NAME);

        } catch (Exception standardException) {
            LoggingUtility.saveExceptionLogging(standardException, CLASS_NAME);
        }
    }

    
    /**
    * @description 
    * @author Rahul Gupta | 01-11-2025 
    * @return String 
    **/
    private static String getCurrentLoggedInCommunity() {

        Map<Id, Network> growerCommunities = new Map<Id, Network>([
                    SELECT Id, Name
                    FROM Network
                    LIMIT 10
                ]);

        List<LoginHistory> loginHistories = [
                SELECT Id, NetworkId
                FROM LoginHistory
                WHERE UserId = :UserInfo.getUserId()
                AND LoginType = :COMMUNITY_LOGIN_TYPE
                
                ORDER BY LoginTime DESC
                LIMIT 1
            ];

        if (loginHistories.isEmpty() || growerCommunities.keySet().isEmpty()) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        if (!growerCommunities.containsKey(loginHistories[0].NetworkId)) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        return growerCommunities.get(loginHistories[0].NetworkId).Name;
    }


    /**
    * @description 
    * @author Rahul Gupta | 01-11-2025 
    * @param String community 
    * @return Id 
    **/
    private static Id getLatestRelatedDealerForCommunity(String community, Account growerAccount) {

        List<Dealer_Applicant_Relationship__c> dealerRelations;
        
        if (community.equals(WHITE_LABEL_GROWER_COMMUNITY)) {
            dealerRelations = [
                    SELECT Id, 
                           Dealer__c, 
                           Applicant__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Applicant__c = :growerAccount.Id
                    AND Dealer__r.Name = :ConstantValues.GROWMARK_COOP_TYPE
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

        } else if (community.equals(GRAY_LABEL_GROWER_COMMUNITY)) {
            dealerRelations = [
                    SELECT Id, 
                           Dealer__c, 
                           Applicant__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Applicant__c = :growerAccount.Id
                    AND Dealer__r.Name != :ConstantValues.GROWMARK_COOP_TYPE
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