/**************************************************************************************\
Class Name : FICOResponseParser
Developer : Subham Nandi
Created Date : 10th December 2021
Last Modified date : 28th December 2021
Purpose : Recieves the response, generates a file, parses and store the response
\**************************************************************************************/

public without sharing class FICOResponseParser {

    public FICOResponseParser(String response, String applicationId, String accountId){
        
        
        Blob objBlob = Blob.valueOf(response.replace('&lt;','<').replace('&gt;','>').replace('<?xml version="1.0" encoding="UTF-8"?>', '').replace('SOAP-ENV','SOAP'));
        Attachment objAttachment = new Attachment();
        objAttachment.Body = objBlob;
        objAttachment.ParentId = applicationId;
        objAttachment.Name = ConstantValues.RESPONSE_ATTACHMENT_NAME + '.xml';
        Database.insert(objAttachment, true);
        //savepoint
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            DOM.Document xmlDocument = new DOM.Document();
            String responseBody = response.replace('&lt;','<').replace('&gt;','>').replace('<?xml version="1.0" encoding="UTF-8"?>', '').replace('SOAP-ENV','SOAP');
            //Initialisation of parsing
            xmlDocument.load(responseBody);
            Dom.XMLNode envelope = xmlDocument.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body',envelope.getNamespace());
            Dom.XMLNode obtainDecisionDataResponse  = body.getChildElement('ObtainDecisionDataResponse','http://www.liquidCredit.com/');
            Dom.XMLNode obtainDecisionDataResult  = obtainDecisionDataResponse.getChildElement('ObtainDecisionDataResult','http://www.liquidCredit.com/');
            Dom.XmlNode filiquidCredit = obtainDecisionDataResult.getChildElement('FI_LiquidCredit',null);
            Dom.XmlNode principalList = filiquidCredit.getChildElement('principal_list',null);
            //Forming a map to access the particular principals from salesforce, for whom the responses are coming
            Map<String, clcommon__Party__c> partyMap = new Map<String, clcommon__Party__c>();
            List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
            List<clcommon__Party__c> updatePartyList = new List<clcommon__Party__c>();
            List<Account> objAccountToUpdateList = new List<Account>();
            String borrowerAccountId;
            if(applicationId != null){
                partyList =    [SELECT  Name, 
                                        Id, 
                                        clcommon__Type__r.Name,
                                        clcommon__Contact__r.genesis__SSN__c, 
                                        clcommon__Account__c,
                                        clcommon__Party_Types__c,
                                        clcommon__Account__r.Score_1__c,
                                        clcommon__Account__r.Score_2__c,
                                        clcommon__Account__r.SBSS70_Score__c,
                                        clcommon__Account__r.BK10_Score__c   
                                FROM clcommon__Party__c 
                                WHERE genesis__Application__c = :applicationId
                                AND (clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME OR
                                clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                AND clcommon__Account__c != null];
            }
            for(clcommon__Party__c objIndividualParty : partyList){
                if(objIndividualParty.clcommon__Contact__c != null &&
                    objIndividualParty.clcommon__Contact__r.genesis__SSN__c != null){
                        partyMap.put(objIndividualParty.clcommon__Contact__r.genesis__SSN__c,objIndividualParty);
                }
                if(objIndividualParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                    borrowerAccountId = objIndividualParty.clcommon__Account__c;
                }
            }
            
            List<Dom.XMLNode> childNodeOfPrincipalList = principalList.getChildElements();
            //Parsing for multiple principal
            for(Dom.XmlNode node : childNodeOfPrincipalList){
                
                Dom.XmlNode decisionData = node.getChildElement('decisionData',null);
                Dom.XmlNode dataSourceAnalysisList = decisionData.getChildElement('dataSourceAnalysisList',null);
                Dom.XmlNode dataSourceAnalysis = dataSourceAnalysisList.getChildElement('dataSourceAnalysis',null);
                String score1;
                String score2;
                Dom.XmlNode scoreNode1 = dataSourceAnalysis.getChildElement('score1',null);
                if(scoreNode1!=null){
                    score1= scoreNode1.getAttribute('Score',null);
                }
                Dom.XmlNode scoreNode2 = dataSourceAnalysis.getChildElement('score2',null);
                if(scoreNode2!= null){
                    score2= scoreNode2.getAttribute('Score',null);
                }
                Dom.XmlNode scoringList = decisionData.getChildElement('scoringList',null);
                List<Dom.XmlNode> listOfScoring = scoringList.getChildElements();
                //getting the ssn for a particular principal from the response and storing it in a string
                String ssn = node.getChildElement('SSN',null).getText();
                //Checking whether the principal inside the map have the same ssn as coming in the response
                if(partyMap.get(ssn) != null){
                    clcommon__Party__c objPartyToParse = partyMap.get(ssn);
                    Account objAccount = new Account(Id = objPartyToParse.clcommon__Account__c);
                    objAccount.FICO_Recorded_On__c = datetime.now();
                    objAccount.Score_1__c = score1;
                    objAccount.Score_2__c = score2;
                    if(listOfScoring.size() > 0){
                        if(listOfScoring[0].getAttribute('type',null) == ConstantValues.SBSS_SCORE){
                            objAccount.SBSS70_Score__c = listOfScoring[0].getChildElement('totalScore',null).getText();
                            if(listOfScoring.size() > 1){
                                objAccount.BK10_Score__c = listOfScoring[1].getChildElement('totalScore',null).getText();
                            }
                            
                        }
                        else{
                            if(listOfScoring.size() > 1){
                                objAccount.SBSS70_Score__c = listOfScoring[1].getChildElement('totalScore',null).getText();
                            }
                            objAccount.BK10_Score__c = listOfScoring[0].getChildElement('totalScore',null).getText();
                        }
                    }
                    objAccountToUpdateList.add(objAccount);
                }
            }
            //parsing the response for the business associated with the application
            if(partyList.size()>1){
                Account objAccountToUpdateBusiness;
                //clcommon__Party__c objPartyToUpdateBusiness = new clcommon__Party__c();
                if(borrowerAccountId != null){
                    objAccountToUpdateBusiness = new Account(Id = borrowerAccountId);
                }
                objAccountToUpdateBusiness.FICO_Recorded_On__c = datetime.now();
                Dom.XmlNode businessInfo = filiquidCredit.getChildElement('business_info',null);
                Dom.XmlNode decisionData = businessInfo.getChildElement('decisionData',null);
                Dom.XmlNode scoringListForBusiness = decisionData.getChildElement('scoringList',null);
                List<Dom.XmlNode> listOfScoringForBusiness = scoringListForBusiness.getChildElements();
                if(listOfScoringForBusiness.size() > 0){
                    if(listOfScoringForBusiness[0].getAttribute('type',null) == ConstantValues.SBSS_SCORE){
                        if(listOfScoringForBusiness.size() > 1){
                            if(listOfScoringForBusiness[1].getChildElement('totalScore',null).getText() != null){
                                objAccountToUpdateBusiness.BK10_Score__c = listOfScoringForBusiness[1].getChildElement('totalScore',null).getText();
                            }
                        }
                        if(listOfScoringForBusiness[0].getChildElement('totalScore',null).getText() != null){
                            objAccountToUpdateBusiness.SBSS70_Score__c = listOfScoringForBusiness[0].getChildElement('totalScore',null).getText();
                        }
                    }
                    else{
                        if(listOfScoringForBusiness[0].getChildElement('totalScore',null).getText() != null){
                            objAccountToUpdateBusiness.BK10_Score__c = listOfScoringForBusiness[0].getChildElement('totalScore',null).getText();
                        }
                        if(listOfScoringForBusiness.size() > 1){
                            if(listOfScoringForBusiness[1].getChildElement('totalScore',null).getText() != null){
                                objAccountToUpdateBusiness.SBSS70_Score__c = listOfScoringForBusiness[1].getChildElement('totalScore',null).getText();
                            }
                        }
                    }
                }
                objAccountToUpdateList.add(objAccountToUpdateBusiness);
            }
            //Adding the all the parties that need to get their score fields populate in a list and upserting the scores in party level
            Database.upsert(objAccountToUpdateList, false);
            
        } 
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.RESPONSE_PARSER_EXCEPTION);
        }
        catch(Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, ConstantValues.RESPONSE_PARSER_EXCEPTION);
        }
    }
}