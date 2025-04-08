/**
 * @description       : creates account and related contact for external apis
 * @author            : Kabir Pramanik
 * @group             : 
 * @last modified on  : 08-12-2024
 * @last modified by  : Kabir Pramanik
**/
@RestResource(urlMapping = '/api/v1/external/saveAccountContact ')
global with sharing class externaAPIDummyKabir{
    private static final String CLASS_NAME = externaAPIDummyKabir.class.getName();
    private static final String APPLICANT_DETAIL_KEY =  'applicant_details';
    private static final String FIRST_NAME_KEY = 'first_name';
    private static final String MIDDLE_NAME_KEY = 'middle_name';
    private static final String LAST_NAME_KEY = 'last_name';
    private static final String PHONE_KEY = 'phone_number';
    private static final String SSN_KEY = 'ssn';
    private static final String EMAIL_KEY = 'email';
    private static final String APPLICANT_DETAILS_MISSING_MESSAGE = 'Applicant details are missing';
    private static final String REQUIRED_PARAMETER_MISSING_MESSAGE = 'Required parameter missing';

    private static final String STATUS_KEY = 'status';
    private static final String CONTENT_KEY = 'content';
    private static final String MESSAGE_KEY = 'message';
    private static final String ACCOUNT_ID_KEY = 'account_id';
    private static final String CONTACT_ID_KEY = 'contact_id';

    private static final String SUCCESS_VALUE = 'Success';
    private static final Integer TWO_HUNDRED_ONE_STATUS_CODE = 201;
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    
    private static final String NAME_REGEX = '^[a-zA-Z]+(?: [a-zA-Z]+)*$';
	private static final String EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%⌗~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
	private static final String SSN_REGEX = '^\\d{9}$'; // Format: XXXXXXXXX
	private static final String PHONE_REGEX = '^\\d{10}$'; // Format: XXXXXXXXX
    private static final String NAME_REGEX_MESSAGE = 'Names should only contain letters and spaces.';
	private static final String PHONE_REGEX_MESSAGE = 'Invalid phone number format. Use XXXXXXXXXX';
    private static final String EMAIL_REGEX_MESSAGE = 'Invalid email format.';
    private static final String SSN_REGEX_MESSAGE =	'Invalid SSN format. Use XXXXXXXXX.';

    /**
    * @description :
    * @author Kabir Pramanik | 08-12-2024 
    **/
    @HttpPost
    global static void doPostAccountContact(){
        RestResponse response = RestContext.response;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        // Map<String, Object> bodyMap = new Map<String, Object>();
        Account accountObj = new Account();
        Contact contactObj = new Contact(); 
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            RestRequest requestParam = RestContext.request;
            response.addHeader(CONTENT_TYPE, APPLICATION_JSON);

            String requestBody = requestParam.requestBody.toString();
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);

            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            if(!requestMap.containsKey(APPLICANT_DETAIL_KEY)){
                throw new CustomException(APPLICANT_DETAILS_MISSING_MESSAGE);
            }
            
            Map<String,Object> applicantDetailsMap = (Map<String,Object>) requestMap.get(APPLICANT_DETAIL_KEY);

            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(applicantDetailsMap.get(SSN_KEY)), ExternalConstants.SSN_MISSING);

            populateApplicantData(accountObj, contactObj, applicantDetailsMap);

            contentMap.put(CONTACT_ID_KEY, contactObj.Id);
            contentMap.put(ACCOUNT_ID_KEY, accountObj.Id);
            contentMap.put(MESSAGE_KEY, SUCCESS_VALUE);
            responseMap.put(CONTENT_KEY, contentMap);
            responseMap.put(STATUS_KEY, SUCCESS_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = TWO_HUNDRED_ONE_STATUS_CODE;

        }catch(CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(customExceptionObj, CLASS_NAME);
            if(customExceptionObj.getMessage().equals(ExternalConstants.USER_NOT_AUTHORISED)){
                ExternalExceptionUtil.setUnauthorizeResponse(response);
            }
            else{
                ExternalExceptionUtil.setFailureResponse(response,customExceptionObj.getMessage());
            }
        }catch(Exception exceptionObj){
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
            ExternalExceptionUtil.setFailureResponse(response,ExternalConstants.UNEXPECTED_ERROR);
        }

        
    }

    /**
    * @description 
    * @author Kabir Pramanik | 08-12-2024 
    * @param accountObj 
    * @param contactObj 
    * @param applicantDetailsMap 
    **/
    private static void populateApplicantData(Account accountObj,
                                                Contact contactObj, 
                                                Map<String, Object> applicantDetailsMap){
        if(!applicantDetailsMap.containsKey(FIRST_NAME_KEY)
                    || !applicantDetailsMap.containsKey(LAST_NAME_KEY)
                    || !applicantDetailsMap.containsKey(MIDDLE_NAME_KEY)
                    || !applicantDetailsMap.containsKey(PHONE_KEY)
                    || !applicantDetailsMap.containsKey(EMAIL_KEY)
                    || !applicantDetailsMap.containsKey(SSN_KEY)){
            throw new CustomException(REQUIRED_PARAMETER_MISSING_MESSAGE);
        }
        String firstName = String.valueOf(applicantDetailsMap.get(FIRST_NAME_KEY));
        String middleName = String.valueOf(applicantDetailsMap.get(MIDDLE_NAME_KEY));
        String lastName = String.valueOf(applicantDetailsMap.get(LAST_NAME_KEY));
        String phone = String.valueOf(applicantDetailsMap.get(PHONE_KEY));
        String email = String.valueOf(applicantDetailsMap.get(EMAIL_KEY));
        String ssn = String.valueOf(applicantDetailsMap.get(SSN_KEY));
        String fullName = ExternalConstants.EMPTY_STRING;
        List<Contact> contactList = [SELECT Id,
                                genesis__SSN__c
                            FROM Contact
                            WHERE genesis__SSN__c =: ssn
                            WITH SECURITY_ENFORCED];
		    // Validation checks
    	if(!Pattern.matches(NAME_REGEX, firstName) 
        		|| !Pattern.matches(NAME_REGEX, middleName) 
        		|| !Pattern.matches(NAME_REGEX, lastName)){
        	throw new CustomException(NAME_REGEX_MESSAGE);
    	}
		
		if(!Pattern.matches(EMAIL_REGEX, email)) {
        	throw new CustomException(EMAIL_REGEX_MESSAGE);
    	}

    	if(!Pattern.matches(SSN_REGEX, ssn)) {
        	throw new CustomException(SSN_REGEX_MESSAGE);
    	}

    	if(!Pattern.matches(PHONE_REGEX, phone)) {
        	throw new CustomException(PHONE_REGEX_MESSAGE);
    	}
                                                    
        if(String.isBlank(middleName)){
            fullName = firstName +  ExternalConstants.SPACE_STRING + lastName;
        } else{
            fullName = firstName + ExternalConstants.SPACE_STRING + middleName + ExternalConstants.SPACE_STRING + lastName;
        }

        if(contactList.isEmpty()){
            accountObj.Name = fullName;
            accountObj.Phone = phone;
            Database.insert(accountObj, true);

            contactObj.FirstName = firstName;
            if(String.isBlank(middleName)){
                contactObj.LastName = lastName;
            } else{
                contactObj.LastName = middleName + ExternalConstants.SPACE_STRING + lastName;
            }
            contactObj.Phone = phone;
            contactObj.Email = email;
            contactObj.AccountId = accountObj.Id;
            Database.insert(contactObj, true);
        } else{
            accountObj = [SELECT Id FROM Account WHERE Id =: contactList[0].AccountId WITH SECURITY_ENFORCED];
            accountObj.Name = fullName;
            accountObj.Phone = phone;
            Database.update(accountObj, true);

            contactObj =  contactList[0];
            contactObj.FirstName = firstName;
            if(String.isBlank(middleName)){
                contactObj.LastName = lastName;
            } else{
                contactObj.lastName = middleName + ExternalConstants.SPACE_STRING + lastName;
            }
            contactObj.Phone = phone;
            contactObj.Email = email;
            contactObj.genesis__SSN__c = ssn;
            Database.update(contactObj, true);
        }
    }
}