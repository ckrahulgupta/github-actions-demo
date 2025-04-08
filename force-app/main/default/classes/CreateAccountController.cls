/**
 * @description       : This is the controller class of Create Account Flow Screen
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-09-2024
 * @last modified by  : Ayan Bhowmik
**/
public with sharing class CreateAccountController {

    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.Account.isAccessible())
                | (!Schema.sObjectType.RecordType.isAccessible())
                | (!Schema.sObjectType.CFA_Partner_Program__c.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
    * @description This method return the configurable recordtypes.
    * @author Ayan Bhowmik | 06-28-2024 
    * @param recordId 
    * @return List<RecordType> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypeList(Id recordId){
        try {
            checkAccessOnObjects();
            List<Account> dealerAccount = new List<Account>();
            List<RecordType> recordTypeList = new List<RecordType>();
            List<CFA_Partner_Program__c> partnerProgramList = new List<CFA_Partner_Program__c>();
            List<String> nonDealerContactList = new List<String>{ConstantValues.COAPPLICANT,
                                                                    ConstantValues.DEALER,
                                                                    ConstantValues.GROWER,
                                                                    ConstantValues.BUYER,
                                                                    ConstantValues.INSURANCE_AGENT,
                                                                    ConstantValues.LANDOWNER,
                                                                    ConstantValues.SPOUSE};
            if(!String.isBlank(recordId)){
                dealerAccount = [SELECT Id,
                                        CFA_Partner_Program__c,
                                        Coop_Type__c
                                    FROM Account
                                    WHERE Id =: recordId
                                    LIMIT 1];
            }
            CFAOriginationHelperClass.checkEmptyList(dealerAccount, ConstantValues.DEALER_NOT_FOUND);
            if(dealerAccount[0].Coop_Type__c != ConstantValues.GROWMARK_COOP_TYPE){
                if(dealerAccount[0].CFA_Partner_Program__c != null){
                    partnerProgramList = [SELECT Id,
                                                Allow_Field_Staff_Agents__c,
                                                Allow_Payment_Admin__c,
                                                Allow_Sales_Agent_Admin__c
                                            FROM CFA_Partner_Program__c
                                            WHERE Id =: dealerAccount[0].CFA_Partner_Program__c
                                            LIMIT 1];
                }
                CFAOriginationHelperClass.checkEmptyList(partnerProgramList, ConstantValues.PARTNER_PROGRAM_NOT_FOUND);
                if(!partnerProgramList[0].Allow_Field_Staff_Agents__c){
                    nonDealerContactList.add(ConstantValues.FIELD_STAFF_AGENT);
                }
                if(!partnerProgramList[0].Allow_Payment_Admin__c){
                    nonDealerContactList.add(ConstantValues.PAYMENT_ADMINISTRATOR);
                }
                if(!partnerProgramList[0].Allow_Sales_Agent_Admin__c){
                    nonDealerContactList.add(ConstantValues.SALES_AGENT_ADMIN);
                }   
            }
            recordTypeList = [SELECT Id,
                                    Name
                                FROM RecordType
                                WHERE sObjectType =: ConstantValues.ACCOUNT
                                AND Name NOT IN :nonDealerContactList];
            CFAOriginationHelperClass.checkEmptyList(recordTypeList, ConstantValues.RECORD_TYPE_NOT_FOUND);
            return recordTypeList;
        } catch (CustomException customExceptionObj) {
            CFAOriginationHelperClass.throwAuraHandledException(customExceptionObj.getMessage());
        } catch (Exception e) {
            CFAOriginationHelperClass.throwAuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
        return null;
    }
}