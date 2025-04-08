/**
 * @description       : utility class related to jwt
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 05-18-2024
 * @last modified by  : Ayush Kumar Singh
**/
public without sharing class JWTUtil {

    private static final String SIGNATURE_ALG = 'HmacSHA256';
    private static final String SEPARATOR = '___';
    private static final String PLUS_REPLACEMENT = '_PLUS_';
    private static final String SLASH_REPLACEMENT = '_SLASH_';
    private static final String EQUAL_TO_REPLACEMENT = '_EQUAL_';
    
    /**
    * @description : generates a jwt token for the payload
    * @author Krishanu Chinya | 04-08-2024 
    * @param payload 
    * @return String 
    **/
    public static String generateEmailVerificationToken(Map<String, String> payload) {
        CFA_Configuration__c credentialParameters =  CFA_Configuration__c.getOrgDefaults();
        DateTime creationTime = DateTime.now(); //GMT TIME
        String createdDateTime = creationTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        payload.put('createdDate', createdDateTime);

        
        Map<String, String> header = new Map<String, String> {
            'typ' => 'JWT',
            'alg' => 'HS256'
        };

        String content = (EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))) + SEPARATOR 
                            + EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(payload)))).replaceAll(PortalConstants.EQUALS_STRING, PortalConstants.EMPTY_STRING);

        Blob checksum = Crypto.generateMac(SIGNATURE_ALG, Blob.valueOf(content), EncodingUtil.base64Decode(credentialParameters.Email_Change_Decryption_Key__c));        
        String generatedToken = content + SEPARATOR + EncodingUtil.base64Encode(checksum).replaceAll(PortalConstants.EQUALS_STRING, PortalConstants.EMPTY_STRING);
        
        generatedToken = generatedToken.replaceAll(PortalConstants.PLUS_STRING, PLUS_REPLACEMENT);
        generatedToken = generatedToken.replaceAll(PortalConstants.SLASH_STRING, SLASH_REPLACEMENT);
        generatedToken = generatedToken.replaceAll(PortalConstants.EQUALS_STRING, EQUAL_TO_REPLACEMENT);

        return generatedToken;        
    }
    
    /**
    * @description : checks whether the token is valid or not
    * @author Krishanu Chinya | 04-08-2024 
    * @param token 
    * @return Boolean 
    **/
    public static Boolean isValidEmailVerificationToken(String token) {
        CFA_Configuration__c credentialParameters =  CFA_Configuration__c.getOrgDefaults();
        token = replaceTokenCharacter(token);
        
        String[] parts = token.split(SEPARATOR);
        return Crypto.verifyHMac(
                        SIGNATURE_ALG, 
                        Blob.valueOf(parts[0] + SEPARATOR + parts[1]), 
                        EncodingUtil.base64Decode(credentialParameters.Email_Change_Decryption_Key__c), 
                        EncodingUtil.base64Decode((parts[2]))
                    );
    }

    /**
    * @description : decrypts the jwt token
    * @author Krishanu Chinya | 04-08-2024 
    * @param token 
    * @return Map<String, String> 
    **/
    public static Map<String,String> decryptToken (String token){
        token = replaceTokenCharacter(token);
        String[] parts = token.split(SEPARATOR);
        Blob res = EncodingUtil.base64decode(parts[1]);
        return (Map<String,String>) JSON.deserialize(res.toString(), Map<String,String>.class);
    }

    /**
     * @description Replacing token character
     * @param token 
     * @return  `String`
     */
    public static String replaceTokenCharacter(String token){
        token = token.replaceAll(PLUS_REPLACEMENT,PortalConstants.PLUS_STRING);
        token = token.replaceAll(SLASH_REPLACEMENT,PortalConstants.SLASH_STRING);
        token = token.replaceAll(EQUAL_TO_REPLACEMENT,PortalConstants.EQUALS_STRING);
        return token;
    }
}