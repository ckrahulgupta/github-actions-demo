/**
 * @description       : to verify the application before submitting it.
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 20-01-2025
 * @last modified by  : Soumik Pattanayak
**/
public inherited sharing class PortalAppSubmissionValidationUtil {
       

    //Custom Labels to be used in the class
    private static String noScoreApplicantCodes=PortalConstants.CODE_FOR_NOSCORE_APPLICANT;
    private static Set<String> noScoreApplicantCodesSet=new Set<String>(noScoreApplicantCodes.split(PortalConstants.COMMA_STRING));

    private static String usersThatSubmitAppString=PortalConstants.USERS_WITH_PERMISSION_TO_SUBMIT_APPLICATION;
    private static List<String> usersThatSubmitAppList=usersThatSubmitAppString.split(PortalConstants.COMMA_STRING);


    
    /**
    * @description this method is to validate if the user has the permissions to submit the application
    * @author Rakesh Saraf | 11-13-2024 
    * @param applicationId 
    * @return User 
    **/
    public static User isValidUser(String applicationId) {
        Boolean isApplicationIdValid = PortalConstants.FALSE_VALUE;
            List<User> loggedInUser = [SELECT Id,
                                            ContactId,
                                            AccountId,
                                            Account.ParentId, 
                                            Account.Parent.Name
                                        FROM USER
                                        WHERE Id = :UserInfo.getUserId()];
                
            if(!loggedInUser.isEmpty()) {  
                if(loggedInUser[0].ContactId == null && 
                    PortalConstants.STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                        isApplicationIdValid = PortalConstants.TRUE_VALUE;
                }else{
                    List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                        FROM clcommon__Party__c
                                                                        WHERE genesis__Application__c = :applicationId
                                                                            AND clcommon__Contact__c = :loggedInUser[0].ContactId
                                                                            AND clcommon__Party_Types__c IN :usersThatSubmitAppList];
                    if(!applicationParties.isEmpty()) {  
                        isApplicationIdValid = PortalConstants.TRUE_VALUE;
                    }
                } 
            }

            if(!isApplicationIdValid){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

        return loggedInUser[0];                                             
    }

    /**
    * @description checks whether addition info is required to be validated or not
    * @author Rakesh Saraf | 10-26-2024 
    * @param applicationObj 
    * @param principalPartyList 
    * @param borrowerAccoubtObj 
    * @return Boolean 
    **/
    private static Boolean checkIfAdditionalInfoRequired(genesis__Applications__c applicationObj,List<clcommon__Party__c> principalPartyList,Account borrowerAccoubtObj){
        
        String legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(borrowerAccoubtObj);

        Boolean isRequired=false;

        if(applicationObj.Credit_Application_And_Agreement_Process__c==PortalConstants.REQUEST_SECOND_LOOK){

            Integer numOfNoScoreApplicant=0;
            for(clcommon__Party__c individualParty:applicationObj.genesis__Parties__r){
                if(noScoreApplicantCodesSet.contains(individualParty.clcommon__Account__r.Score_1__c)){
                    numOfNoScoreApplicant+=1;
                }
            }
        
            if(legalEntity== PortalConstants.SOLE_PROP_ENTITY & 
                    numOfNoScoreApplicant>0 & numOfNoScoreApplicant==applicationObj.genesis__Parties__r.size() ){
                        isRequired=false;
            }
            else if(legalEntity != PortalConstants.SOLE_PROP_ENTITY & 
                        numOfNoScoreApplicant>0 & numOfNoScoreApplicant==principalPartyList.size()  ){
                            isRequired=false;
            }
            else {
                isRequired=true;
            }
        }
        else if(applicationObj.Credit_Application_And_Agreement_Process__c!=PortalConstants.CUSTOMIZE_LOAN &&
                    applicationObj.genesis__Credit_Rating__c != null && 
                        (applicationObj.genesis__Credit_Rating__r.Name == PortalConstants.TIER_THREE_CREDIT |
                        applicationObj.genesis__Credit_Rating__r.Name == PortalConstants.TIER_FOUR)){
                    
                            isRequired= true;
        }

        return isRequired;

        
    }

    /**
    * @description validate additional info
    * @author Rakesh Saraf | 10-25-2024 
    * @param paramMap 
    * @param principalPartyList 
    **/
    public static void validateAdditionalInformation(Map<String,Object> paramMap,List<clcommon__Party__c> principalPartyList){
        

        Double collateralValues;
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_KEY);
        Boolean shouldDeny=(Boolean)paramMap.get(PortalConstants.KEY_SHOULD_DENY);

        if(!checkIfAdditionalInfoRequired(applicationObj,principalPartyList,(Account)paramMap.get(PortalConstants.ACCOUNT_KEY)) | 
                shouldDeny){
            
                    return;
        }
        

        List<clcommon__Collateral__c> cropList = [SELECT 
                                                Id,clcommon__Collateral_Category__r.Name,
                                                Total_Acres__c,Producer_Share_Percent__c,Approved_Yield__c,
                                                Insurance_Plan__c,Percent_Coverage_Level__c,Percent_Fed__c,
                                                clcommon__Collateral_Type__c, genesis__Application__c, 
                                                clcommon__Collateral_Code__c
                                            FROM clcommon__Collateral__c 
                                            WHERE genesis__Application__c =:applicationObj.Id];

        PortalApplicationOriginationHelper.checkEmptyList(cropList, String.valueOf(PortalConstants.INSUFFICIENT_COLLATERALS).replace(PortalConstants.KEY_MATCH_LOAN_AMOUNT, PortalConstants.EMPTY_STRING));

        AggregateResult collateralValuesTotalSum = [SELECT SUM(Total_Collateral_Price__c) 
                                                        FROM clcommon__Collateral__c 
                                                        WHERE genesis__Application__c = :applicationObj.Id];
        collateralValues = Double.valueOf(collateralValuesTotalSum.get(PortalConstants.AGGREGATE_KEY));
        if(applicationObj.genesis__Loan_Amount__c > collateralValues |
            (collateralValues == null & 
            applicationObj.genesis__Loan_Amount__c > 0)){
            
                throw new CustomException(PortalConstants.INSUFFICIENT_COLLATERALS);
        }

        
            // if denial flag is false then only validate additional info
        validateAdditionalInfoParty(paramMap, applicationObj,principalPartyList);
        

    }

    /**
    * @description validating all the additional info parties
    * @author Rakesh Saraf | 10-23-2024 
    * @param paramMap 
    * @param applicationObj 
    * @param principalPartyList 
    **/
    private static void validateAdditionalInfoParty(Map<String,Object> paramMap,genesis__Applications__c applicationObj,List<clcommon__Party__c> principalPartyList){
        Account borrowerAccountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_KEY);
        clcommon__Party__c applicantPartyObj=(clcommon__Party__c)paramMap.get(PortalConstants.KEY_PARTY);
        
        List<String> exceptionStringList=new List<String>();

        //Query on all the parties of the application and check for the Additional parties are there or not
        List<clcommon__Party__c> additionalInfoPartyList = [SELECT  Id, 
                                                                    clcommon__Party_Types__c
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c = :applicationObj.Id AND 
                                                                (clcommon__Party_Types__c IN (:PortalConstants.LANDOWNER_PARTY_NAME,
                                                                                                :PortalConstants.SPOUSE_PARTY_NAME ,
                                                                                                :PortalConstants.BUYER_PARTY_NAME ,
                                                                                                :PortalConstants.INSURANCE_AGENT_PARTY_NAME))];
        Map<String,String> partyMap = new Map<String,String>();
        for(clcommon__Party__c eachAdditionalInfoParty : additionalInfoPartyList){
            partyMap.put(eachAdditionalInfoParty.clcommon__Party_Types__c,PortalConstants.KEY_PARTY);
        }

        if(!partyMap.containsKey(PortalConstants.LANDOWNER_PARTY_NAME)){
            exceptionStringList.add(PortalConstants.LANDOWNER_DETAILS_MISSING);
        }
        if(!partyMap.containsKey(PortalConstants.BUYER_PARTY_NAME)){
            exceptionStringList.add(String.valueOf(PortalConstants.BUYER_DETAILS_MISSING).replace(PortalConstants.KEY_COMPLETE_POTENTIAL, PortalConstants.EMPTY_STRING));
        }
        if(!partyMap.containsKey(PortalConstants.INSURANCE_AGENT_PARTY_NAME)){
            exceptionStringList.add(String.valueOf(PortalConstants.AGENCY_DETAILS_MISSING).replace(PortalConstants.KEY_COMPLETE, PortalConstants.KEY_THE));
        }
        if((borrowerAccountObj.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY ) &
                (applicantPartyObj.Marital_Status__c == PortalConstants.MARITAL_STATUS_MARRIED) &
                !partyMap.containsKey(PortalConstants.SPOUSE_PARTY_NAME)){

                    exceptionStringList.add(String.valueOf(PortalConstants.SPOUSE_DETAILS_MISSING).replace(PortalConstants.KEY_ALL, PortalConstants.EMPTY_STRING).replace(PortalConstants.KEY_FOLLOWING, PortalConstants.EMPTY_STRING));
        }
        else if((borrowerAccountObj.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY )){
            //In Case of a Business => Check for the principals whether they are married or not
            exceptionStringList=validateSpouseDetailsForBusiness(principalPartyList,partyMap,exceptionStringList);
        }

        if(!exceptionStringList.isEmpty()){
            throw new CustomException(exceptionStringList[0]);
        }
    }
    /**
    * @description validates the spouse details for the principal of business.
    * @author Rakesh Saraf | 10-30-2024 
    * @param principalPartyList 
    * @param partyMap 
    * @param exceptionStringList 
    * @return List<String> 
    **/
    private static List<String> validateSpouseDetailsForBusiness(List<clcommon__Party__c> principalPartyList,Map<String,String> partyMap,List<String> exceptionStringList){
        Boolean marriedFlag = false;

        for(clcommon__Party__c coApplicantParty : principalPartyList){
            if(coApplicantParty.Marital_Status__c == PortalConstants.MARITAL_STATUS_MARRIED){
                marriedFlag = true;
                Break;
            }
        }
        if( marriedFlag &
            !partyMap.containsKey(PortalConstants.SPOUSE_PARTY_NAME)){

                exceptionStringList.add(String.valueOf(PortalConstants.SPOUSE_DETAILS_NOT_ENTERED));
                
        }
        return exceptionStringList;
    }


    /**
    * @description validations required if the application is an evergreen application
    * @author Rakesh Saraf | 10-24-2024 
    * @param applicationObj 
    * @param shouldDeny 
    **/
    public static void validationForEvergreenApplication(genesis__Applications__c applicationObj,Boolean shouldDeny){
        
        if(applicationObj.Is_Evergreen__c == true){
            //Set the Signing Method to Email Docusign by default
            applicationObj.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
            //Set DocuSign_Credit_Agreement_Initiated__c as true to prevent sending Email
            applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
            //Evergreen Checks
            
            if(applicationObj.genesis__Credit_Rating__r.Name == PortalConstants.TIER_2_CREDIT &
                applicationObj.Evergreen_Tier_Two_Business_Info_Status__c != PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED){
                    throw new CustomException(PortalConstants.EVERGREEN_TIER_TWO_BIZ_INFO_ERROR);
            }
            else if(applicationObj.genesis__Credit_Rating__r.Name == PortalConstants.TIER_2_CREDIT){
                checkBusinessInfoForTierTwoEvergreen(applicationObj);
            }
        }else{
            checkSigningMethodPresentForEvergreenApp(applicationObj,shouldDeny);
        }
    }

   /**
    * @description check if signing method is present or not for  non evergreen application
    * @author Rakesh Saraf | 10-30-2024 
    * @param applicationObj 
    * @param shouldDeny 
    **/
    private static void checkSigningMethodPresentForEvergreenApp(genesis__Applications__c applicationObj,Boolean shouldDeny){
        if((applicationObj.Signing_Method__c == NULL || 
            (applicationObj.Signing_Method__c != PortalConstants.PAPER_SCANNED 
                && applicationObj.Agreement_Sign__c != true)) 
                    & !shouldDeny){
                
                        throw new CustomException(PortalConstants.SIGNING_METHOD_IS_MISSING);
            }
    }

    /**
    * @description check if the total assets and liabilities are present for the parties of the application or not in the case of a Tier 2 Evergreen application
    * @author Rakesh Saraf | 11-17-2024 
    * @param applicationObj 
    **/
    private static void checkBusinessInfoForTierTwoEvergreen(genesis__Applications__c applicationObj){
        for(clcommon__Party__c eachParty:applicationObj.genesis__Parties__r){
            if(eachParty.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL_ENTITY){
                continue;
            } 
            if(eachParty.Total_Assets__c==null || eachParty.Total_Assets__c<0){
                throw new CustomException(PortalConstants.APPL_TOTAL_ASSETS_MISSING);
            }
            if(eachParty.Total_Liabilities__c==null || eachParty.Total_Liabilities__c<0){
                throw new CustomException(PortalConstants.APPL_TOTAL_LIABILITIES_MISSING);
            }

        }
    }

    /**
    * @description validates the borrower details for the application
    * @author Rakesh Saraf | 10-22-2024 
    * @param currentApplicationList 
    * @param borrowerDetailsMap 
    * @param principalDetailsMap 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> validateApplicationInfoForApplicants(List<genesis__Applications__c> currentApplicationList,Map<String,Id> borrowerDetailsMap,Map<String,List<Id>> principalDetailsMap){
        Account borrowerAccountObj=new Account();
        Contact borrowerContactObj=new Contact();
        genesis__Business_Information__c borrowerBusinessInfoObj=new genesis__Business_Information__c();
        clcommon__party__c borrowerPartyObj = new clcommon__party__c();
        Integer borrwerAccountIndex = 0;
        Integer borrwerContactIndex = 0;
        Integer borrwerBInfoIndex = 0;

        String borrowerAccountId=(Id)borrowerDetailsMap.get(PortalConstants.ACCOUNT_KEY);
        String borrowerContactId=(Id)borrowerDetailsMap.get(PortalConstants.CONTACT_KEY);
        String borrowerBusinessInfoId=(Id)borrowerDetailsMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        List<Id> principalAccountIdList = (List<ID>) principalDetailsMap.get(PortalConstants.ACCOUNT_KEY);
        List<Id> principalContactIdList = (List<ID>) principalDetailsMap.get(PortalConstants.CONTACT_KEY);
        List<Id> principalBInfoIdList = (List<ID>) principalDetailsMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        List<clcommon__party__c> applicantPartyList = new List<clcommon__party__c>();
        

        //Query on Account for borrower as well as principal validation
        List<Account> applicantAccountList =[SELECT Id,
                                                    Name,
                                                    clcommon__Legal_Entity_Type__c,
                                                    BillingCountry,
                                                    Score_1__c,
                                                    clcommon__Legal_Entity_Type__r.Name
                                            FROM Account
                                            WHERE Id=:borrowerAccountId
                                            OR Id IN :principalAccountIdList];

        // Query on Contact for borrower as well as principal validation
        List<Contact> applicantContactList =[SELECT Id,
                                                    FirstName,
                                                    LastName,
                                                    genesis__SSN__c,
                                                    Confirm_SSN__c,
                                                    Birthdate
                                            FROM Contact
                                            WHERE Id=:borrowerContactId
                                            OR Id IN :principalContactIdList];



        
        //Query on Business info for borrower as well as principal validation
        List<genesis__Business_Information__c> applicantBusinessInfoList =  [SELECT Id,
                                                                                    genesis__Total_Assets__c,
                                                                                    genesis__Total_Liabilities__c,
                                                                                    genesis__Tax_Identification_Number__c
                                                                                FROM genesis__Business_Information__c
                                                                                WHERE Id=:borrowerBusinessInfoId
                                                                                OR Id IN :principalBInfoIdList];

        
        PortalApplicationOriginationHelper.checkEmptyList(applicantAccountList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);
        PortalApplicationOriginationHelper.checkEmptyList(applicantContactList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);
        PortalApplicationOriginationHelper.checkEmptyList(applicantBusinessInfoList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);
        
        //we need the borrower acc, contact and business info for validation, so we store it and send the list of principals for validation
        for(Integer partyCount = 0; partyCount<currentApplicationList[0].genesis__Parties__r.size(); partyCount++){
            if(applicantAccountList[partyCount].id==borrowerAccountId){
                borrowerAccountObj=applicantAccountList[partyCount];
                borrwerAccountIndex=partyCount;
            }
            if(applicantContactList[partyCount].id==borrowerContactId){
                borrowerContactObj=applicantContactList[partyCount];
                borrwerContactIndex=partyCount;
            }
            if(applicantBusinessInfoList[partyCount].id==borrowerBusinessInfoId){
                borrowerBusinessInfoObj=applicantBusinessInfoList[partyCount];
                borrwerBInfoIndex=partyCount;
            }
            if(currentApplicationList[0].genesis__Parties__r[partyCount].clcommon__Account__r.id == borrowerAccountId){
                borrowerPartyObj=currentApplicationList[0].genesis__Parties__r[partyCount];
            }
            else{
                applicantPartyList.add(currentApplicationList[0].genesis__Parties__r[partyCount]);
            }
        }

        applicantAccountList.remove(borrwerAccountIndex);
        applicantContactList.remove(borrwerContactIndex);
        applicantBusinessInfoList.remove(borrwerBInfoIndex);

        //validating borrower data
        PortalValidationUtil.validateApplicationData(new Map<String,Object>{
                                        PortalConstants.ACCOUNT_OBJ_KEY=>borrowerAccountObj,
                                        PortalConstants.CONTACT_OBJ_KEY=>borrowerContactObj,
                                        PortalConstants.KEY_SHOULD_VALIDATE=>PortalConstants.SAVE_AND_CONTINUE,
                                        PortalConstants.APPLICATION_OBJ_KEY=>currentApplicationList[0],
                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>borrowerBusinessInfoObj,
                                        PortalConstants.BORROWER_PARTY_NAME=>borrowerPartyObj});

        //map containing the borrower account and contct
        Map<String,Object> borrowerInfoMap=new Map<String,Object>{
            PortalConstants.ACCOUNT_KEY=>borrowerAccountObj,
            PortalConstants.CONTACT_KEY=>borrowerContactObj,
            PortalConstants.KEY_PARTY=>borrowerPartyObj
        };

        //validating the principal data
        validateApplicationInfoForPrincipal(new Map<String, List<Object>>{
                                                                        PortalConstants.KEY_PRINICPAL_ACC=>applicantAccountList,
                                                                        PortalConstants.KEY_PRINICPAL_CONTACT=>applicantContactList,
                                                                        PortalConstants.KEY_PRINICPAL_BUSINESS_INFO=>applicantBusinessInfoList,
                                                                        PortalConstants.KEY_PARTY=>applicantPartyList
                                                                        });
        return borrowerInfoMap;
    }


    /**
    * @description Validation For Principal
    * @author Rakesh Saraf | 10-17-2024 
    * @param principalDetailsMap
    **/
    private static void validateApplicationInfoForPrincipal(Map<String,List<Object>> principalDetailsMap){
        List<Account> principalAccountList = (List<Account>) principalDetailsMap.get(PortalConstants.KEY_PRINICPAL_ACC);
        List<Contact> principalContactList = (List<Contact>) principalDetailsMap.get(PortalConstants.KEY_PRINICPAL_CONTACT);
        List<genesis__Business_Information__c> principalBusinessInfoList = (List<genesis__Business_Information__c>) principalDetailsMap.get(PortalConstants.KEY_PRINICPAL_BUSINESS_INFO);
        List<clcommon__Party__c> principalPartyList = (List<clcommon__Party__c>) principalDetailsMap.get(PortalConstants.KEY_PARTY);


        //will only run if the application has principals, so we check for the principals linked to the party.
        for(Integer partyCount = 0; partyCount<principalAccountList.size(); partyCount++){
            PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>principalContactList[partyCount], 
                                                                            PortalConstants.ACCOUNT_KEY=>principalAccountList[partyCount],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>principalBusinessInfoList[partyCount],
                                                                            PortalConstants.SAVE_TYPE_KEY=> PortalConstants.SAVE_AND_CONTINUE,
                                                                            PortalConstants.KEY_PARTY=> principalPartyList[partyCount]});
        }
    }

    
    /**
    * @description basic validations to start the save and continue process
    * @author Rakesh Saraf | 10-26-2024 
    * @param applicationObj 
    **/
    public static void validateDealerPartnerProgram(genesis__Applications__c applicationObj){
        //if the dealer coop type is not growmark, the dealer must have a partner program
        if(applicationObj.Coop_Type__c != PortalConstants.GROWMARK_COOP_TYPE 
                & String.isBlank(applicationObj.Dealer_name__r.CFA_Partner_Program__c)){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description validate if application is scored or not
    * @author Rakesh Saraf | 10-28-2024 
    * @param applicationObj 
    **/
    public static void validateApplicationScored(genesis__Applications__c applicationObj){
        //if the credit application and agreement process of the application is not customized loan, it should be scored.
        if(applicationObj.Credit_Application_And_Agreement_Process__c != PortalConstants.CUSTOMIZE_LOAN &
            String.isBlank(applicationObj.genesis__Credit_Rating__c)){
                //Please Score the applicationObj before submitting it
                throw new CustomException(PortalConstants.SCORE_BEFORE_SUBMIT);
        }
    }
}