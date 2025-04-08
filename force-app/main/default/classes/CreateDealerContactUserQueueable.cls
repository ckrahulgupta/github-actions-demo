/**
 * @description       : Purpose of this class is to create dealer contact user and call CreateDealerContactPartyBatch.
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Ayan Bhowmik
**/
public with sharing class CreateDealerContactUserQueueable implements Queueable {
    private Map<String, Object> recordDetailsMap = new Map<String, Object>();
    private String accountId;
    private String dealerId;
    private List<String> previousRecordTypeName;


    /**
    * @description The purpose of this constructor is to assign neccessary parameter.
    * @author Ayan Bhowmik | 04-09-2024 
    * @param recordDetailsMap 
    **/
    public CreateDealerContactUserQueueable(Map<String, Object> recordDetailsMap) {
        this.recordDetailsMap = recordDetailsMap;
        this.accountId=(String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID);
        this.dealerId=(String)recordDetailsMap.get(ConstantValues.DEALER_ID);
    }


    /**
    * @description The purpose of this execute method is to create a user for dealer contacts.
    * @author Ayan Bhowmik | 04-09-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        try{
            checkLicense();
            Id profileId;
            String newRecordType = '';
            User newPortalUser = new User();
            String alias = ConstantValues.EMPTY_STRING;
            List<Contact> contactList = (List<Contact>)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_LIST);
            CFAOriginationHelperClass.checkEmptyList(contactList, ConstantValues.CONTACT_FETCH_ERROR);
            if(contactList[ConstantValues.ZERO_VALUE].Account.Coop_Type__c != ConstantValues.GROWMARK_COOP_TYPE 
                        & contactList[ConstantValues.ZERO_VALUE].Account.RecordType.Name == ConstantValues.FIELD_STAFF_AGENT){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            if(contactList[ConstantValues.ZERO_VALUE].Account.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE 
                        & contactList[ConstantValues.ZERO_VALUE].Account.RecordType.Name != ConstantValues.AGRIBUSINESS){
                String profileName = ConstantValues.GROWMARK_COOP_TYPE + ConstantValues.SPACE_STRING + contactList[ConstantValues.ZERO_VALUE].Account.RecordType.Name;
                List<Profile> profileList = [SELECT Id, 
                                                    Name 
                                                FROM Profile 
                                                WHERE Name =: profileName 
                                                WITH SECURITY_ENFORCED 
                                                LIMIT 1];
                CFAOriginationHelperClass.checkEmptyList(profileList, ConstantValues.PROFILE_FETCH_ERROR);
                profileId = profileList[ConstantValues.ZERO_VALUE].Id;
            } else {
                List<Profile> profileList =[SELECT Id,
                                                    Name 
                                                FROM Profile 
                                                WHERE Name =: contactList[ConstantValues.ZERO_VALUE].Account.RecordType.Name 
                                                WITH SECURITY_ENFORCED 
                                                LIMIT 1];
                CFAOriginationHelperClass.checkEmptyList(profileList, ConstantValues.PROFILE_FETCH_ERROR);
                profileId = profileList[ConstantValues.ZERO_VALUE].Id;
            }
            alias = contactList[ConstantValues.ZERO_VALUE].LastName + System.today();
            newPortalUser.Alias = alias.substring(ConstantValues.ZERO_VALUE, ConstantValues.SEVEN_VALUE);
            newPortalUser.ContactId = contactList[ConstantValues.ZERO_VALUE].Id;
            newPortalUser.Email = contactList[ConstantValues.ZERO_VALUE].Email;
            newPortalUser.EmailEncodingKey = ConstantValues.ISO_ENCODING;
            newPortalUser.FirstName = contactList[ConstantValues.ZERO_VALUE].FirstName;
            newPortalUser.LanguageLocaleKey = PortalConstants.ENGLISH_US;
            newPortalUser.LastName = contactList[ConstantValues.ZERO_VALUE].LastName; 
            newPortalUser.LocaleSidKey = PortalConstants.ENGLISH_US;
            newPortalUser.ProfileId = profileId;
            newPortalUser.TimeZoneSidKey = PortalConstants.AMERICA_LOS_ANGELES_TIME_ZONE;
            newPortalUser.UserName = contactList[ConstantValues.ZERO_VALUE].Email;
            newPortalUser.IsActive = true;
            
            if(User.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                Database.Insert(newPortalUser, true);
            }

            newRecordType = CFAOriginationHelperClass.getRecordType((List<String>)recordDetailsMap.get(ConstantValues.RECORD_TYPE_NAME));
            CFAOriginationHelperClass.createAccountShareRecord(recordDetailsMap);
            if(!String.isBlank(newRecordType) || newRecordType != null){
                recordDetailsMap.put(ConstantValues.RECORD_TYPE_NAME, newRecordType);
                CreateDealerContactPartyBatch createDealerContactParty = new CreateDealerContactPartyBatch(recordDetailsMap);
                Database.executeBatch(createDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));   
            }
        } catch(CustomException customExceptionObj) {
            PortalHelper.saveExceptionLog(customExceptionObj, CreateDealerContactUserQueueable.class.getName());
        } catch(Exception exceptionObj){
            PortalHelper.saveExceptionLog(exceptionObj, CreateDealerContactUserQueueable.class.getName());
        }
    }
    
    /**
    * @description The purpose of this method is to check licenses for user.
    * @author Ayan Bhowmik | 04-03-2024 
    **/
    public static void checkLicense(){
        List<UserLicense> userLicenseList = [SELECT Id, 
                                                    TotalLicenses, 
                                                    UsedLicenses 
                                                FROM UserLicense 
                                                WHERE Name =: ConstantValues.CUSTOMER_COMMUNITY_PLUS
                                                WITH SECURITY_ENFORCED];
        CFAOriginationHelperClass.checkEmptyList(userLicenseList, ConstantValues.LICENSES_FETCHING_ERROR);
        if((userLicenseList[ConstantValues.ZERO_VALUE].TotalLicenses - userLicenseList[ConstantValues.ZERO_VALUE].UsedLicenses) == ConstantValues.ZERO_VALUE){
            throw new CustomException(ConstantValues.NO_LICENSES);
        }
    }
}