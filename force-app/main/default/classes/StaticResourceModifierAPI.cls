/**
 * @description       : The purpose of this class is to do modify operations on static resources.
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Ayan Bhowmik
**/
public with sharing class StaticResourceModifierAPI {
    private static final String CLASS_NAME = StaticResourceModifierAPI.class.getName();
    private static final List<String> PARAM_LIST = new List<String>{'Conga_Template_Logo',
                                                                    '_Dealer_Portal_Logo',
                                                                    '_Dealer_Portal_Nav_Banner',
                                                                    '_Grower_Portal_Logo',
                                                                    '_Grower_Portal_Nav_Banner'};
    /**
    * @description Checking user access.
    * @author Ayan Bhowmik | 06-17-2024 
    **/
    private static void checkObjectAccess(){
        if(!Schema.sObjectType.ContentVersion.isAccessible()
                    | !Schema.sObjectType.CFA_Partner_Program__c.isAccessible()
                    | !Schema.sObjectType.CFA_Partner_Program__c.isUpdateable()){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS);
        }
    }
    /**
    * @description Invocable method to create static resource.
    * @author Ayan Bhowmik | 06-14-2024 
    * @param requestList 
    **/
    @InvocableMethod(callout=true label = 'Upload Image' description = 'Upload Image to Static Resource')
    public static void uploadImage(List<FlowInputsWrapper> requestList){
        try{
            checkObjectAccess();
            String congaTemplateLogoId = '';
            String programId = requestList[0].programId;
            String coopType = requestList[0].coopTypeName;
            List<String> contentDocList = new List<String>();
            ints.MetadataService.MetadataPort service = createService();
            Map<String, String> fieldToSrMap = new Map<String, String>();
            List<String> contentDocIdList = requestList[0].contentDocIdList;
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            Map<String, ContentVersion> docIdToVesrionMap = new Map<String, ContentVersion>();
            List<ints.MetadataService.StaticResource> staticResourceList =  new List<ints.MetadataService.StaticResource>();
            contentDocList = getContentDocIdList(contentDocIdList);
            if(!contentDocList.isEmpty()){
                contentVersionList = [SELECT Id, 
                                            VersionData, 
                                            Title, 
                                            FileExtension,
                                            ContentDocumentId
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contentDocList
                                        ORDER BY CreatedDate DESC];
            }
            for(ContentVersion eachContentVersion : contentVersionList){
                docIdToVesrionMap.put(eachContentVersion.ContentDocumentId, eachContentVersion);
            }
            coopType = CFAOriginationHelperClass.removeNonAlphabeticCharacters(coopType);    
            for(Integer eachContentDocIndex = 0; eachContentDocIndex < contentDocList.size(); eachContentDocIndex++){
                ints.MetadataService.StaticResource staticResourceObj = new ints.MetadataService.StaticResource();
                ContentVersion contentVersionObj = docIdToVesrionMap.get(contentDocList[eachContentDocIndex]);
                if(contentVersionObj == null){
                    continue;
                }
                if(String.isBlank(congaTemplateLogoId)){
                    congaTemplateLogoId = contentDocList[eachContentDocIndex];
                }
                staticResourceObj.fullName = coopType + PARAM_LIST[eachContentDocIndex];
                staticResourceObj.ContentType = ConstantValues.IMAGE_SLASH_STRING + contentVersionObj.FileExtension;
                staticResourceObj.cacheControl = ConstantValues.PUBLIC_STRING;
                staticResourceObj.content = EncodingUtil.base64Encode(contentVersionObj.VersionData);
                staticResourceList.add(staticResourceObj);
                fieldToSrMap = getFieldToSrMap(staticResourceObj.fullName, fieldToSrMap, eachContentDocIndex);
            }
            if(!staticResourceList.isEmpty() & !Test.isRunningTest()){
                service.createMetadata(staticResourceList);
                System.enqueueJob(new CFAPartnerProgramUpdateQueueable(fieldToSrMap, programId, congaTemplateLogoId));
            }
        } catch(CustomException customExceptionObj){
            PortalHelper.saveExceptionLog(customExceptionObj, CLASS_NAME);
        }catch(Exception exceptionObj){
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
    /**
    * @description Purpose of this method is to create service for calling product api.
    * @author Ayan Bhowmik | 06-17-2024 
    * @return ints.MetadataService.MetadataPort 
    **/
    private static ints.MetadataService.MetadataPort createService(){ 
        ints.MetadataService.MetadataPort service = new ints.MetadataService.MetadataPort();
        service.SessionHeader = new ints.MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    /**
     * @description Wrapper class to take variables from flow.
     */
    public class FlowInputsWrapper{
        @InvocableVariable
        public String coopTypeName;

        @InvocableVariable
        public List<String> contentDocIdList;

        @InvocableVariable
        public String programId;
    }
    /**
    * @description Get map of all static resource where key is the field name.
    * @author Ayan Bhowmik | 06-19-2024 
    * @param name 
    * @param fieldToSrMap 
    * @param eachContentDocIndex 
    * @return Map<String, String> 
    **/
    private static Map<String, String> getFieldToSrMap(String name, Map<String, String> fieldToSrMap, Integer eachContentDocIndex){
        if(!fieldToSrMap.containsKey(PARAM_LIST[eachContentDocIndex])){
            fieldToSrMap.put(PARAM_LIST[eachContentDocIndex], name);
        }
        return fieldToSrMap;
    }
    /**
    * @description This method return content doc id list.
    * @author Ayan Bhowmik | 06-19-2024 
    * @param contentDocIdList 
    * @return List<String> 
    **/
    private static List<String> getContentDocIdList(List<String> contentDocIdList){
        List<String> contentDocList = new List<String>();
        for(String eachContentDoc : contentDocIdList){
            String contentDocStr = eachContentDoc.substring(eachContentDoc.indexOf(ConstantValues.LEFT_SQUARE_BRACKET_STRING) + 1,
                                                            eachContentDoc.indexOf(ConstantValues.RIGHT_SQUARE_BRACKET_STRING));
            if(String.isBlank(contentDocStr)){
                contentDocList.add(ConstantValues.EMPTY_STRING);
            }else{
                contentDocList.add(contentDocStr);
            }
        }
        return contentDocList;
    }
}