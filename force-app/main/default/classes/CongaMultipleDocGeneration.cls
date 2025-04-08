/**
 * @description       : This class is used to generate the Conga Templates
 * @author            : Simran
 * @group             : 
 * @last modified on  : 02-25-2024
 * @last modified by  : Ravi Ranjan
**/
global without sharing class CongaMultipleDocGeneration {
    private static final String APPLICATION_ID_IS_NULL = 'Application Id is null';
    private static final String DOCUMENT_GENERATED = 'Document Generated Successfully';
    private static final String SPOUSE_NOT_AVAILABLE = 'Application does not contain any Spouse';
    private static final String INSURANCE_AGENT_NOT_AVAILABLE = 'Application does not contain any Insurance Agent';
    private static final String DEALER_NOT_AVAILABLE = 'Application does not contain any Dealer';
    private static final String CLASS_NAME='CongaMultipleDocGeneration';
    private static final String NOTHING = '';
    private static final string PENDING_APPROVAL = 'PENDING APPROVAL';
    private static final String ACTIVE = 'ACTIVE';
        
    
    /**
    * @description Method for Spousal Consent Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String spousalConsent(String appId){
        List< clcommon__Party__c > objPartyList = new  List< clcommon__Party__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objPartyList = [SELECT  Id,
                                        clcommon__Type__c, 
                                        clcommon__Type__r.Name, 
                                        Consent_of_Spouse__c 
                                FROM clcommon__Party__c
                                WHERE clcommon__Type__r.Name = :PortalConstants.SPOUSE_PARTY_NAME 
                                AND genesis__Application__c =: appId];
                if(!objPartyList.isEmpty()){
                    for(clcommon__Party__c objParty : objPartyList){
                        objParty.Consent_of_Spouse__c = true;
                    }
                    Database.update(objPartyList, true); 
                    return DOCUMENT_GENERATED;
                }
                return SPOUSE_NOT_AVAILABLE;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }

    
    /**
    * @description //Method for AOI Crop Letter Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String aoiCropLetter(String appId){
        List< clcommon__Party__c > objPartyList = new  List< clcommon__Party__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objPartyList = [SELECT  Id,
                                        clcommon__Type__c, 
                                        clcommon__Type__r.Name, 
                                        AOI_Crop_Letter__c  
                                FROM clcommon__Party__c
                                WHERE clcommon__Type__r.Name = :PortalConstants.INSURANCE_AGENT_PARTY_NAME 
                                AND genesis__Application__c =: appId];
                if(!objPartyList.isEmpty()){
                    for(clcommon__Party__c objParty : objPartyList){
                        objParty.AOI_Crop_Letter__c  = true;
                    }
                    Database.update(objPartyList); 
                    for(clcommon__Party__c objParty : objPartyList){
                        objParty.AOI_Crop_Letter__c  = false;
                    }
                    Database.update(objPartyList, true);
                    return DOCUMENT_GENERATED;
                }
                return INSURANCE_AGENT_NOT_AVAILABLE;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
    
    /**
    * @description Method for Patron Release Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String patronRelease(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList = [SELECT Id,
                                             Patron_Release_Letter__c 
                                      FROM genesis__Applications__c
                                      WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Patron_Release_Letter__c  = true;
                    }
                    Database.update(objApplicationList, true); 
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Patron_Release_Letter__c  = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
    /**
    * @description Method for Modification Agreement Maturity
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String modificationAgreementMaturity(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList = [SELECT Id,
                                             Modification_Agreement_Maturity_Checkbox__c
                                      FROM genesis__Applications__c
                                      WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Modification_Agreement_Maturity_Checkbox__c  = true;
                    }
                    Database.update(objApplicationList, true); 
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Modification_Agreement_Maturity_Checkbox__c  = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
    /**
    * @description Method for Modification Agreement Maturity Date Extension
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String modificationAgreementMaturityDateExtension(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList = [SELECT Id,
                                             Modification_Agreement_Maturity_Date__c 
                                      FROM genesis__Applications__c
                                      WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Modification_Agreement_Maturity_Date__c  = true;
                    }
                    Database.update(objApplicationList, true); 
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Modification_Agreement_Maturity_Date__c  = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    } 

   
    /**
    * @description Method for Lien Subordinate Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String lienSubordinate(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList =[SELECT Id,
                                            Lien_Subordinate_Agreement__c  
                                    FROM genesis__Applications__c
                                    WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Lien_Subordinate_Agreement__c   = true;
                    }
                    Database.update(objApplicationList, true); 
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Lien_Subordinate_Agreement__c   = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }

    
    /**
    * @description Method for Credit Reference Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String creditReference(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList =[SELECT Id,
                                            Credit_Reference_Checkbox__c  
                                    FROM genesis__Applications__c
                                    WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Credit_Reference_Checkbox__c   = true;
                    }
                    Database.update(objApplicationList, true); 
                    
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Credit_Reference_Checkbox__c   = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }

    
    /**
    * @description Method for AOI Crop Release Letter Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String aoiCropReleaseLetter(String appId){
        List< clcommon__Party__c > objPartyList = new  List< clcommon__Party__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objPartyList = [SELECT Id,
                                    clcommon__Type__c, 
                                    clcommon__Type__r.Name, 
                                    AOI_Crop_Release_Letter__c  
                                FROM clcommon__Party__c
                                WHERE clcommon__Type__r.Name = :PortalConstants.INSURANCE_AGENT_PARTY_NAME 
                                AND genesis__Application__c =: appId];
                if(!objPartyList.isEmpty()){
                    for(clcommon__Party__c objParty : objPartyList){
                        objParty.AOI_Crop_Release_Letter__c  = true;
                    }
                    Database.update(objPartyList, true); 
                    return DOCUMENT_GENERATED;
                }
                return INSURANCE_AGENT_NOT_AVAILABLE;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
   
    /**
    * @description Method for Indemnity Crop Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String indemnityCrop(String appId){
        List< clcommon__Party__c > objPartyList = new  List< clcommon__Party__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objPartyList = [SELECT Id,
                                    clcommon__Type__c, 
                                    clcommon__Type__r.Name, 
                                    Indemnity_Crop__c 
                                FROM clcommon__Party__c
                                WHERE clcommon__Type__r.Name = :PortalConstants.INSURANCE_AGENT_PARTY_NAME 
                                AND genesis__Application__c =: appId];
                if(!objPartyList.isEmpty()){
                    for(clcommon__Party__c objParty : objPartyList){
                        objParty.Indemnity_Crop__c = true;
                    }
                    Database.update(objPartyList, true); 
                    return DOCUMENT_GENERATED;
                }
                return INSURANCE_AGENT_NOT_AVAILABLE;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }

    
    /**
    * @description Method for Customized Loan Approval Document Generation
    * @author Ravi Ranjan | 02-07-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String customizedLoanApproval(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList = [SELECT Id,
                                            Customized_Loan__c 
                                    FROM genesis__Applications__c
                                    WHERE id =: appId];
                if(!objApplicationList.isEmpty()){
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Customized_Loan__c  = true;
                    }
                    Database.update(objApplicationList, true); 
                    for(genesis__Applications__c objApplication : objApplicationList){
                        objApplication.Customized_Loan__c  = false;
                    }
                    Database.update(objApplicationList, true); 
                    return DOCUMENT_GENERATED;
                }
                return DEALER_NOT_AVAILABLE;   
            }   
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
    /**
    * @description Method for Generating Loan Commitment letter after modification
    * @author Ravi Ranjan | 02-06-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String loanCommitmentLetter(String appId){
        List< genesis__Applications__c > objApplicationList = new  List< genesis__Applications__c >();
        try{
            if(appId == null){
                return APPLICATION_ID_IS_NULL;
            }
            else{
                objApplicationList = [SELECT Id,
                                             genesis__Status__c
                                      FROM genesis__Applications__c
                                      WHERE id =: appId LIMIT 1];
                if(objApplicationList.isEmpty()){
                    return NOTHING; 
                }
                if(objApplicationList[0].genesis__Status__c == ACTIVE){
                    objApplicationList[0].genesis__Status__c = PENDING_APPROVAL;
                    Database.update(objApplicationList, true); 

                    objApplicationList[0].genesis__Status__c = ACTIVE;
                    Database.update(objApplicationList, true); 
                    
                    return DOCUMENT_GENERATED;
                }
                return NOTHING;       
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
}