/**
 * @description       : Test class for ExternalExceptionUtil
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 09-06-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ExternalExceptionUtilTest {
    @isTest 
    public static void testSaveExceptionLog(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            try{
                throw new CustomException('Test exception');
            }catch(Exception exceptionObj){
                String exceptionNameString = 'Test exception';
                Test.startTest();
                ExternalExceptionUtil.saveExceptionLog(exceptionObj,exceptionNameString);
                Test.stopTest();
                clcommon__Log__c logObj = [SELECT Id, 
                                                    Name 
                                                FROM clcommon__Log__c];
                System.assertEquals(logObj.Name, exceptionNameString, 'Asertion Failed');
            }
        }   
    }

    @isTest 
    public static void testSetUnauthorizeResponse(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        System.runAs(userObj){
            Test.startTest();
            ExternalExceptionUtil.setUnauthorizeResponse(response);
            Test.stopTest();
            System.assertEquals(response.statusCode, ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, 'Assertion Failed');
        }
    }

    @isTest 
    public static void testSetFailureResponse(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        System.runAs(userObj){
            Test.startTest();
            ExternalExceptionUtil.setFailureResponse(response, 'Invalid Application Id');
            Test.stopTest();
            System.assertEquals(response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    @isTest
    static void testHandleCustomException() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        CustomException customExceptionObj = new CustomException(ExternalConstants.USER_NOT_AUTHORISED);
        RestResponse response = new RestResponse();

        System.runAs(userObj){
            Test.startTest();
            ExternalExceptionUtil.handleCustomException(customExceptionObj, 'ExternalExceptionUtil', response);
            Test.stopTest();
        }
    
        System.assertEquals(401, response.statusCode, 'Assertion Failed');
    }

    @isTest
    static void testThrowCustomException() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalExceptionUtil.throwCustomException('Something went wrong');
            }catch(CustomException customExceptionObj){
                System.assertEquals('Something went wrong', customExceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

}