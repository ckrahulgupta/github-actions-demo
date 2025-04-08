/**
 * @description       : Service class for modifying Base Rate Values
 * @author            : Sounak Ganguly
 * @group             : 
 * @last modified on  : 03-10-2024
**/
public inherited sharing class BaseRateService {

    /**
     * @description       : sets the base rate info
     * @author            : Sounak Ganguly
     * @group             : 
     * @last modified on  : 03-10-2024
    **/
    public class BaseRateInfo {

        /**
        * @description : Getter Setter for BaseRateInfo
        * @author  Sounak Ganguly
        * @return clcommon__Floating_Rate_Index__c
        **/
        public clcommon__Floating_Rate_Index__c floatingRateIndex { get; set; }
        /**
        * @description : Constructor for Base Rate
        * @author  Sounak Ganguly
        * @param floatingRateIndex  
        **/
        public BaseRateInfo(clcommon__Floating_Rate_Index__c floatingRateIndex) {
            this.floatingRateIndex = floatingRateIndex;
        }
    }

    /**
    * @description : Fetch Base Rate Details from Partner Program for a particular account
    * @author  Sounak Ganguly
    * @param accountId
    * @return BaseRateInfo
    **/
    public static BaseRateInfo fetchAndCacheBaseRate(Id accountId) {
        BaseRateInfo cachedBaseRateInfo = (BaseRateInfo) Cache.Session.get(accountId);

        if (cachedBaseRateInfo != null) {
            return cachedBaseRateInfo;
        }

        Account account = [
                SELECT Id, CFA_Partner_Program__c, CFA_Partner_Program__r.Base_Rate__c
                FROM Account
                WHERE Id = :accountId
                //WITH SECURITY_ENFORCED
                LIMIT 1
                ];

        if (account != null && account.CFA_Partner_Program__c != null) {
            clcommon__Floating_Rate_Index__c floatingRateIndex = [
                SELECT Id, Name, Current_Floating_Rate__c
                FROM clcommon__Floating_Rate_Index__c
                WHERE Id = :account.CFA_Partner_Program__r.Base_Rate__c
                AND clcommon__Active__c = true
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (floatingRateIndex != null) {
                BaseRateInfo baseRateInfo = new BaseRateInfo(floatingRateIndex);
                Cache.Session.put(accountId, baseRateInfo);

                return baseRateInfo;
            }
        }

        return null;
    }
}