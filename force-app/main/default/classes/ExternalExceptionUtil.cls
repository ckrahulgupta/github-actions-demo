/**
 * @description       : Exception Util class for External Api
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 09-05-2024
 * @last modified by  : Suraj Kumar
**/
public inherited sharing class ExternalExceptionUtil {
    /**
    * @description : saves the exception log
    * @author Suraj Kumar | 05-23-2024 
    * @param objException 
    * @param exceptionNameString 
    **/
    public static void saveExceptionLog(Exception objException, String exceptionNameString){
        Database.Insert(new clcommon__Log__c(Name = exceptionNameString ,
                                            clcommon__Message__c = exceptionNameString 
                                            + objException.getStackTraceString()
                                            + objException.getMessage(),
                                            clcommon__Time__c = System.Now()), false);
    }

    /**
    * @description : This method is sets the response for Unauthorize access 
    * @author Suraj Kumar | 05-23-2024 
    * @param response 
    **/
    public static void setUnauthorizeResponse(RestResponse response){
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        contentMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.USER_NOT_AUTHORISED);
        responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
        responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.FAILURE_VALUE);
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        response.statusCode = ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE;
    }

    /**
    * @description : This method is sets the response for Exception encountered
    * @author Suraj Kumar | 05-23-2024 
    * @param response 
    * @param responseMessage
    **/
    public static void setFailureResponse(RestResponse response, String responseMessage){
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        contentMap.put(ExternalConstants.MESSAGE_KEY, responseMessage);
        responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
        responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.FAILURE_VALUE);
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        response.statusCode = ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE;
    }

    /**
    * @description : handles custom exceptions for external apis
    * @author Krishanu Chinya | 06-12-2024 
    * @param customExceptionObj 
    * @param className 
    * @param response 
    **/
    public static void handleCustomException(CustomException customExceptionObj,String className,RestResponse response){
        ExternalExceptionUtil.saveExceptionLog(customExceptionObj, className);
        if(customExceptionObj.getMessage().equals(ExternalConstants.USER_NOT_AUTHORISED)){
            setUnauthorizeResponse(response);
        }
        else{
            setFailureResponse(response,customExceptionObj.getMessage());
        }
    }

    /**
    * @description : method to throw exception
    * @author Suraj Kumar | 05-16-2024 
    * @param exceptionName 
    **/
    public static void throwCustomException(String exceptionName){ 
        throw new CustomException(exceptionName);
    }
}