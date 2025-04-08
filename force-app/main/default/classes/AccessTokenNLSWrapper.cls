/**********************************************************************************************************************
 * @description       : This is a wrapper class which helps to deserialize the Access Token JSON response.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-21-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**********************************************************************************************************************/

global with sharing class AccessTokenNLSWrapper {    

    public String access_token;  
    public String expires_in; //300
    public String token_type; //Bearer

    /**
    * @description : This Method will pass the accesstoken response and store it in the wrapper class.
    * @author Arka Jyoti Deb 12-21-2021 
    * @param addressString 
    * @return AccessTokenNLSWrapper 
    **/
    public static AccessTokenNLSWrapper parse(String addressString){       
        return (AccessTokenNLSWrapper) System.JSON.deserialize(addressString, AccessTokenNLSWrapper.class);       
    }   
}