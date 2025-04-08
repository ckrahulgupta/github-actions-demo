@RestResource(urlMapping='/api/v1/external/AccountContact')
global with sharing class AccountContactCreationAPI {
    private static final String NULL_INPUT = 'Null value sentt';
    private static final String FIRST_NAME = 'firstName';
    private static final String LAST_NAME = 'lastName';
    private static final String STATUS = 'status';
    private static final String MESSAGE = 'message';
    private static final String SUCCESS = 'success';
    private static final String ERROR = 'error';
    private static final String ACCOUNT_ID = 'accountId';
    private static final String CONTACT_ID = 'contactID';
    private static final String BODY = 'body';
    private static final String CONTENT = 'content';
    private static final String MIDDLE_NAME = 'middleName';
    private static final String PHONE = 'phone';
    private static final String EMAIL = 'email';
    private static final String SSN = 'ssn';
    
    global static boolean isValid(String name){
        if(!String.isEmpty(name) && name.isAlpha()){
            return true;
        }return false;
    }
    
    public static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern pattern = Pattern.compile(emailRegex);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }

    
    @HttpPost
    global static void doPost() {
        RestRequest requestParam = RestContext.request;
        String requestBody = requestParam.requestBody.toString();
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','application/json');
        Savepoint dbSavePoint = Database.setSavepoint();
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        
        try {
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            Account accountObj = new Account();
            Contact contactObjj = new Contact();
            if(!requestMap.containsKey(FIRST_NAME)
               		|| !requestMap.containsKey(LAST_NAME)
              		|| !requestMap.containsKey(MIDDLE_NAME)
              		|| !requestMap.containsKey(PHONE)
              		|| !requestMap.containsKey(EMAIL)
              		|| !requestMap.containsKey(SSN)){
                throw new CustomException(NULL_INPUT);
            }
            String firstName = (String) requestMap.get(FIRST_NAME);
            String lastName = (String) requestMap.get(LAST_NAME);
            String middleName = (String) requestMap.get(MIDDLE_NAME);
            String phone = (String) requestMap.get(PHONE);
            String email = (String) requestMap.get(EMAIL);
            String ssn = (String) requestMap.get(SSN);
            
            if (!isValid(firstName) 
                	|| !isValid(lastName) 
                	|| !middleName.isAlpha()
               		|| !phone.isNumeric()
               		|| phone.length()!=10
               		|| !ssn.isNumeric()
               		|| ssn.length()!=9
               		|| !isValidEmail(email)) {
                throw new CustomException(NULL_INPUT);
            }
            
            Contact[] contactObj=[SELECT Id, FirstName, LastName, Phone, Email, genesis__SSN__c, AccountId
                                 FROM contact
                                 WHERE genesis__SSN__c = :ssn
                                 LIMIT 1];

            if(contactObj.size()!=0){
                accountObj.id=contactObj[0].AccountId;
                contactObjj.Id=contactObj[0].Id;
            }
            accountObj.Name = lastName + ', ' + firstName + ' ' + middleName;
            accountObj.Phone = phone;
            Database.upsert(accountObj, true);
            
            contactObjj.FirstName = firstName;
            contactObjj.LastName = lastName;
            contactObjj.Phone = phone;
            contactObjj.Email = email;
            contactObjj.genesis__SSN__c = ssn;
            contactObjj.AccountId = accountObj.Id;
            Database.upsert(contactObjj, true);
            
            responseMap.put(STATUS, SUCCESS);
            BodyMap.put(ACCOUNT_ID, accountObj.Id);
            bodyMap.put(CONTACT_ID, contactObjj.Id);
            contentMap.put(BODY,bodyMap);
            responseMap.put(CONTENT,contentMap);
            response.statusCode = 201;
            response.responseBody = blob.valueOf(JSON.serialize(responseMap));
        } catch (CustomException e) {
            Database.rollback(dbSavePoint);
            responseMap.put(STATUS, ERROR);
            responseMap.put(MESSAGE, e.getMessage());
            response.statusCode = 400;
            response.responseBody = blob.valueOf(JSON.serialize(responseMap));
        } catch (Exception e) {
            Database.rollback(dbSavePoint);
            responseMap.put(STATUS, ERROR);
            responseMap.put(MESSAGE, e.getMessage());
            response.statusCode = 500;
            response.responseBody = blob.valueOf(JSON.serialize(responseMap));
        }
    }
}
/*
{
	"status": "string",
	"content": {
		"body": {
			"contact_details": {
				"id": "string"
            },
            "account_details": {
				"id": "string"
    		}
		}
	}
}*/