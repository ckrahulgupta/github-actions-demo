/**
 * @description       : Generates the request body to make the callout to FICO and get the response
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Ayush Kumar Singh
**/

global with sharing class FICORequestGeneratorHelper {
    /**
    * @description Generate FICO Request Body
    * @author  Pritam Roy | 03-04-2024 
    * @param req 
    * @return string 
    **/
    public static string generateFICORequestBody(Map<String, Object> req){
        //Class Constant
        String nameRegex = '[^a-zA-Z0-9\\s]';
        try {

            DOM.Document doc = new DOM.Document();
             //Variables for DBA Entities
            String streetAddressDBA = '';
            String cityDBA = '';
            String stateDBA = '';
            String zipCodeDBA = '';
            String taxIdDBA = '';
            String netWorthDBA = '';
            String phoneDBA = '';
            //Instantiating list of maps to fetch the request parameters from the integration framework and storing it
            List<Map<String,Object>> partyList = (List<Map<String, Object>>)req.get('PartyInfo');
            List<Map<String,Object>> applicantPartyList = new List<Map<String,Object>>();
            List<Map<String,Object>> borrowerPartyList = new List<Map<String,Object>>();
            List<Map<String,Object>> borrowerBusinessInfoList = new List<Map<String,Object>>();
            Map<Id,Object> contactToBusinessMap = new Map<Id,Object>();
            Map<Id,String> contactVsPrincipalNumMap = new Map<Id,String>();
            List<String> addressList = new List<String>();
            List<String> dbaAddressList = new List<String>();
            List<String> businessAddressList = new List<String>();

            for(Map<String,Object> partyMap : partyList){
                if((partyMap.get('LegalEntity') == PortalConstants.SOLE_PROP_ENTITY || partyMap.get('PartyTypes') == ConstantValues.PRINCIPAL_PARTY)){
                    if(partyMap.get('PartyTypes') == ConstantValues.BORROWER_PARTY){
                        borrowerPartyList.add(partyMap);
                        borrowerBusinessInfoList.add(partyMap);
                    }
                    applicantPartyList.add(partyMap);
                }
                else{
                    borrowerPartyList.add(partyMap);
                    borrowerBusinessInfoList.add(partyMap);
                }
                contactToBusinessMap.put((Id)partyMap.get('ContactId'), (Object)partyMap.get('Networth'));
                contactVsPrincipalNumMap.put((Id)partyMap.get('ContactId'),String.valueOf(partyMap.get('PrincipalNumber')));
            }
            if(borrowerPartyList.isEmpty()){
                borrowerPartyList.add(partyList[0]);
            }
            
            //Creating the XML Request to make the callout
            dom.XmlNode envelope = doc.createRootElement('Envelope',ConstantValues.SOAP_NS,'soapenv');
            envelope.setNamespace('liq',ConstantValues.SERVICE_NS);
            dom.XmlNode header = envelope.addChildElement('Header',ConstantValues.SOAP_NS, null);
            dom.XmlNode body = envelope.addChildElement('Body',ConstantValues.SOAP_NS, null);
            dom.XmlNode obtainDecisionData = body.addChildElement('ObtainDecisionData',ConstantValues.SERVICE_NS,'liq');
            dom.XmlNode inputPayLoad = obtainDecisionData.addChildElement('inputPayload',ConstantValues.SERVICE_NS,'liq');
            dom.XmlNode cdata = inputPayLoad.addChildElement('![CDATA[',null,null);
            dom.XmlNode fiLiquidCredit = cdata.addChildElement('FI_LiquidCredit',null,null);
            fiLiquidCredit.setAttribute('submission_xref_id',ConstantValues.SUB_XREF_ID);
            fiLiquidCredit.setAttribute('customer_id',ConstantValues.CUSTOMER_ID);
            fiLiquidCredit.setAttribute('product_category_id',ConstantValues.PRODUCT_CATEGORY_ID);
            //the actual payload which is inside the CDATA goes inside here
            if(partyList.size()>0 && partyList[0].get('LoanAmount') != null){
                if(partyList[0].get('LoanAmount')!= null){
                    dom.XmlNode loanAmount = fiLiquidCredit.addChildElement('loan_amount',null,null).addTextNode(String.valueOf(Integer.valueOf(partyList[0].get('LoanAmount'))));
                }
            }
            dom.XmlNode loanPurpose = fiLiquidCredit.addChildElement('loan_purpose',null,null).addTextNode((String)ConstantValues.LOAN_PURPOSE);
            //principal list is the child of fiLiquidCredit
            dom.XmlNode principalList = fiLiquidCredit.addChildElement('principal_list',null,null);
            //Following are the child of principal_list

            //A loop is run to fetch multiple principal under a business for which the callout is made
            for(Map<String, Object> eachContact : applicantPartyList){
                dom.XmlNode principalInfo = principalList.addChildElement('principal_info',null,null);
                principalInfo.setAttribute('customer_xref_id',ConstantValues.CUSTOMER_XREF_ID);
                //Following are the children of principal info
                dom.XmlNode dataSourceList = principalInfo.addChildElement('dataSourceList',null,null);
                dataSourceList.setAttribute('printImageRequestFlag',ConstantValues.PRINT_IMAGE_REQUEST_FLAG);
                dataSourceList.setAttribute('parsedDataRequestFlag',ConstantValues.PARSED_DATA_REQUEST_FLAG);
                dataSourceList.setAttribute('rawDataRequestFlag',ConstantValues.RAW_DATA_REQUEST_FLAG);
                //Following are the children of data source list
                dom.XmlNode dataSource = dataSourceList.addChildElement('dataSource',null,null);
                dataSource.setAttribute('score1Model',ConstantValues.SCORE1_MODEL);
                dataSource.setAttribute('score2Model',ConstantValues.SCORE2_MODEL);
                dataSource.setAttribute('connectionUsername',ConstantValues.CONNECTION_USERNAME);
                dataSource.setAttribute('connectionPassword',ConstantValues.CONNECTION_PASSWORD);
                dataSource.setAttribute('code',ConstantValues.CODE);
                dataSource.setAttribute('priority',ConstantValues.PRIORITY);
                dateTime birthDateofContact;
                String dateString;
                if(eachContact.get('Birthdate') != null){
                    birthDateofContact = (dateTime) eachContact.get('Birthdate');
                    dateString =  birthDateofContact.format('MMddyyyy','India');
                }
                dom.XmlNode requestMade = dataSource.addChildElement('request',null,null);
                dom.XmlNode subscriberId = requestMade.addChildElement('subscriber_id',null,null).addTextNode(ConstantValues.SUBSCRIBER_ID_NUMBER);
                if(eachContact.get('FirstName')!=null){
                    dom.XmlNode firstName = principalInfo.addChildElement('first_name',null,null).addTextNode(String.valueOf(eachContact.get('FirstName')).replaceAll(nameRegex, ''));
                }
                //middle name is not a necessary field to make the callout, attaching a null check to handle that. 
                if(eachContact.get('MiddleName')!=null){
                    dom.XmlNode middleInitial = principalInfo.addChildElement('middle_initial',null,null).addTextNode(String.valueOf(eachContact.get('MiddleName')).replaceAll(nameRegex, '').substring(0,1));
                }
                if(eachContact.get('LastName')!=null){
                    dom.XmlNode lastName = principalInfo.addChildElement('last_name',null,null).addTextNode(String.valueOf(eachContact.get('LastName')).replaceAll(nameRegex, ''));
                }
                dom.XmlNode nameSuffix = principalInfo.addChildElement('name_suffix',null,null);
                if(dateString != null){
                    dom.XmlNode birthDate = principalInfo.addChildElement('birthdate',null,null).addTextNode(dateString);
                }
                if(eachContact.get('SSN')!=null){
                    dom.XmlNode ssn = principalInfo.addChildElement('SSN',null,null).addTextNode(String.valueOf(eachContact.get('SSN')).replaceAll(ConstantValues.NONDIGITS,''));
                }
                dom.XmlNode currentAddress = principalInfo.addChildElement('current_address',null,null);
                if(eachContact.get('Street')!=null){
                    addressList = ((String)eachContact.get('Street')).split(',');
                    Integer addressLength = addressList[0].length();
                    String reducedAddress = addressLength <= 30?addressList[0] : addressList[0].substring(0,30);
                    dom.XmlNode address = currentAddress.addChildElement('address',null,null).addTextNode(reducedAddress);
                }
                if(eachContact.get('City')!= null){
                    dom.XmlNode city = currentAddress.addChildElement('city',null,null).addTextNode((String)eachContact.get('City'));
                }
                if(eachContact.get('State')!= null){
                    dom.XmlNode state = currentAddress.addChildElement('state',null,null).addTextNode((String)eachContact.get('State'));
                }
                if(eachContact.get('PostalCode')!= null){
                    String postalCode = String.valueOf(eachContact.get('PostalCode')).substring(0,5);
                    dom.XmlNode zip = currentAddress.addChildElement('zip',null,null).addTextNode((String)eachContact.get('PostalCode'));
                }
                if(eachContact.get('Phone')!=null){
                    dom.XmlNode phoneNumber = principalInfo.addChildElement('phone_number',null,null).addTextNode((String.valueOf(eachContact.get('Phone'))).replaceAll(ConstantValues.NONDIGITS,''));
                }
                if(contactToBusinessMap.get((Id)eachContact.get('ContactId'))!=null){
                    dom.XmlNode netWorth = principalInfo.addChildElement('net_worth',null,null).addTextNode(String.valueOf(Integer.valueOf(contactToBusinessMap.get((Id)eachContact.get('ContactId')))));
                }
                
                //Get all the Primary Applicant data and store it in Maps
                if((String)contactVsPrincipalNumMap.get((Id)eachContact.get('ContactId')) == '1'){
                    dbaAddressList = ((String)eachContact.get('Street')).split(',');
                    Integer dbaAddressLength = dbaAddressList[0].length();
                    String reducedAddress = dbaAddressLength <= 30?dbaAddressList[0] : dbaAddressList[0].substring(0,30);
                    //String reducedAddress = dbaAddressList[0].substring(0,30);
                    streetAddressDBA = reducedAddress;
                    cityDBA = (String)eachContact.get('City');
                    stateDBA = (String)eachContact.get('State');
                    zipCodeDBA = String.valueOf(eachContact.get('PostalCode')).substring(0,5);
                    taxIdDBA = String.valueOf(eachContact.get('SSN')).replaceAll(ConstantValues.NONDIGITS,'');
                    netWorthDBA = String.valueOf(Integer.valueOf(contactToBusinessMap.get((Id)eachContact.get('ContactId'))));
                    if(String.valueOf(eachContact.get('Phone'))!=null){
                    	phoneDBA = (String.valueOf(eachContact.get('Phone'))).replaceAll(ConstantValues.NONDIGITS,'');
                    }
                    System.debug('Net Worth === '+ netWorthDBA);
                }
            }
            //following are the children nodes of fiLiquidCredit
            dom.XmlNode businessInfo = fiLiquidCredit.addChildElement('business_info',null,null);
            businessInfo.setAttribute('business_xref_id',ConstantValues.BUSINESS_XREF_ID);
            businessInfo.setAttribute('ol_cb_score_cutoff',ConstantValues.OL_SCORE_CUTOFF);
            businessInfo.setAttribute('scoring_model_suite_type',ConstantValues.SCORING_MODEL);
            //following are the children nodes of businessInfo
            if(borrowerPartyList.size() > 0){
                if(borrowerPartyList[0].get('Name')!=null){
                    dom.XmlNode businessName = businessInfo.addChildElement('business_legal_name',null,null).addTextNode(String.valueOf(borrowerPartyList[0].get('Name')).replaceAll(nameRegex, ''));
                }
                if(borrowerPartyList[0].get('Street')!=null){
                    businessAddressList = ((String)borrowerPartyList[0].get('Street')).split(',');
                    Integer businessAddressLength = businessAddressList[0].length();
                    String reducedAddress = businessAddressLength <=30?businessAddressList[0] : businessAddressList[0].substring(0,30);
                    dom.XmlNode businessAddress = businessInfo.addChildElement('business_address',null,null).addTextNode(reducedAddress);
                }
                if(borrowerPartyList[0].get('City')!=null){
                    dom.XmlNode businessCity = businessInfo.addChildElement('business_city',null,null).addTextNode((String)borrowerPartyList[0].get('City'));
                }
                if(borrowerPartyList[0].get('State')!= null){
                    dom.XmlNode businessState = businessInfo.addChildElement('business_state',null,null).addTextNode((String)borrowerPartyList[0].get('State'));
                }
                if(borrowerPartyList[0].get('PostalCode')!= null){
                    dom.XmlNode businessZip = businessInfo.addChildElement('business_zip',null,null).addTextNode(String.valueOf(borrowerPartyList[0].get('PostalCode')).substring(0,5));
                }
            }            
            //Check for DBA Flow
            if(borrowerPartyList[0].get('LegalEntity') == PortalConstants.INDIVIDUAL_ENTITY){
                //For the DBA Entities
                //Get child nodes and check whether business addresses were added or not. If not for DBA, add business addresses from contact
                Dom.XmlNode businessAddressDBA = businessInfo.getChildElement('business_address', null);
                Dom.XmlNode businessCityDBA = businessInfo.getChildElement('business_city', null);
                Dom.XmlNode businessStateDBA = businessInfo.getChildElement('business_state', null);
                Dom.XmlNode businessZipDBA = businessInfo.getChildElement('business_zip', null);
                Dom.XmlNode businessNameDBA = businessInfo.getChildElement('business_legal_name', null);
                if(businessAddressDBA == null){
                    dom.XmlNode businessAddress = businessInfo.addChildElement('business_address',null,null).addTextNode(streetAddressDBA);
                }
                if(businessCityDBA == null){
                    dom.XmlNode businessCity = businessInfo.addChildElement('business_city',null,null).addTextNode(cityDBA);
                }
                if(businessStateDBA == null){
                    dom.XmlNode businessState = businessInfo.addChildElement('business_state',null,null).addTextNode(stateDBA);
                }
                if(businessZipDBA == null){
                    dom.XmlNode businessZip = businessInfo.addChildElement('business_zip',null,null).addTextNode(zipCodeDBA);
                }
            }
            if(applicantPartyList.size() > 0){
                if(borrowerPartyList[0].get('LegalEntity') != PortalConstants.INDIVIDUAL_ENTITY && applicantPartyList[0].get('Phone')!=null){
                    dom.XmlNode businessPhone = businessInfo.addChildElement('business_phone',null,null).addTextNode((String.valueOf(applicantPartyList[0].get('Phone'))).replaceAll(ConstantValues.NONDIGITS,''));
                }
                else if(borrowerPartyList[0].get('LegalEntity') == PortalConstants.INDIVIDUAL_ENTITY && phoneDBA != null){
                    dom.XmlNode businessPhone = businessInfo.addChildElement('business_phone',null,null).addTextNode(phoneDBA);
                }
            }
            if(borrowerBusinessInfoList.size()>0){
                if(borrowerBusinessInfoList[0].get('TaxIDNumber')!=null){
                    dom.XmlNode fedTaxId = businessInfo.addChildElement('fed_tax_id',null,null).addTextNode(String.valueOf(borrowerBusinessInfoList[0].get('TaxIDNumber')).replaceAll(ConstantValues.NONDIGITS, ''));
                }
                else if(borrowerPartyList[0].get('LegalEntity') == PortalConstants.SOLE_PROP_ENTITY && borrowerPartyList[0].get('borrowerContactSSN')!=null){
                    dom.XmlNode fedTaxId = businessInfo.addChildElement('fed_tax_id',null,null).addTextNode(String.valueOf(borrowerPartyList[0].get('borrowerContactSSN')).replaceAll(ConstantValues.NONDIGITS, ''));
                }
                else if(borrowerPartyList[0].get('LegalEntity') == PortalConstants.INDIVIDUAL_ENTITY && taxIdDBA != null){
                    dom.XmlNode fedTaxId = businessInfo.addChildElement('fed_tax_id',null,null).addTextNode(taxIdDBA);
                }

                if(borrowerPartyList[0].get('Networth')!=null){
                    dom.XmlNode currentBalance = businessInfo.addChildElement('curr_dda_balance',null,null).addTextNode(String.valueOf(Integer.valueOf(borrowerPartyList[0].get('Networth'))));
                }
                else if(borrowerPartyList[0].get('LegalEntity') == PortalConstants.INDIVIDUAL_ENTITY && netWorthDBA != null){
                    dom.XmlNode currentBalance = businessInfo.addChildElement('curr_dda_balance',null,null).addTextNode(netWorthDBA);
                }
            }
            String ficoRequest = doc.toXmlString().replace('</![CDATA[>', ']]>').replace('><FI_LiquidCredit','<FI_LiquidCredit').replace('Header />','Header/>').remove('<?xml version="1.0" encoding="UTF-8"?>');
            System.debug('Request=======>'+ficoRequest);
            return(ficoRequest);
    
        } catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICORequestGeneratorHelper.class.getName());
        }
        return null;
    }
}