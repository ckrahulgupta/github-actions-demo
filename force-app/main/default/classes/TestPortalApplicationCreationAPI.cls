@isTest
public class TestPortalApplicationCreationAPI {
    //Creating Test data for all
    @testSetup
    static void setup(){        
        genesis__Business_Information__c businessInfo = new genesis__Business_Information__c();
        businessInfo.genesis__Business_Country__c='India';
        Database.Insert(businessInfo);     
        
        Account acc = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual';
        acc.Name='SJha';
        Database.Insert(clEntity);
        acc.clcommon__Legal_Entity_Type__c = clEntity.Id;
        acc.genesis__Business_Information__c=businessInfo.Id;
        Database.Insert(acc);
        
        Contact con=new Contact();
        con.FirstName='Simran';
        con.LastName='Jha';
        con.Email='simran1@gmail.com';
        con.Phone='1234567890';
        Database.Insert(con);
                
        clcommon__Party__c clparty = new clcommon__Party__c();
        clparty.clcommon__Account__c=acc.Id;
        clparty.clcommon__Contact__c=con.Id;
        Database.insert(clparty); 
        
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.clcommon__Product_Name__c ='SimpliFy';
        Database.Insert(clProduct);
     
        genesis__Applications__c app = new genesis__Applications__c();
        clcommon__CL_Purpose__c  clPurposes = new clcommon__CL_Purpose__c();
        clPurposes.Name='Crop';
        app.genesis__Product_Type__c ='Package';
        app.genesis__Term__c = 12;
        app.genesis__Interest_Rate__c = 1;
        app.genesis__Loan_Amount__c = 35000;
        Database.Insert(clPurposes);
        app.genesis__CL_Product__c= clProduct.Id;
        app.genesis__CL_Purpose__c = clPurposes.Id;
        Database.Insert(app);
    }
    //Passing Id null and productType true
    @isTest
    public static void TestPortalApplicationCreationAPI(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account acc= new Account();
        requestMap.put('account', Json.serialize(acc));

        genesis__Applications__c app = new genesis__Applications__c();
        requestMap.put('productType',true);
        requestMap.put('application', Json.serialize(app));

        PortalApplicationCreationAPI saveApi = new PortalApplicationCreationAPI();
        clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
    }
    //Passing Id null and productType false
    @isTest
    public static void TestPortalApplicationCreationAPI3(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account acc= new Account();
        requestMap.put('account', Json.serialize(acc));
       
        genesis__Applications__c app = new genesis__Applications__c();
        requestMap.put('productType',false);
        requestMap.put('application', Json.serialize(app));

        PortalApplicationCreationAPI saveApi = new PortalApplicationCreationAPI();
        clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
    }
    //Passing all data to Application,Account, businessInfo
    @isTest
    public static void TestPortalApplicationCreationAPI1(){        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Business_Information__c businessInfo = TestClassHelper.createBusinessInfo();
        requestMap.put('businessInformation', Json.serialize(businessInfo)); 
        
        Account acc = TestClassHelper.createAccount(businessInfo);
        requestMap.put('account', Json.serialize(acc));

        genesis__Applications__c app = TestClassHelper.createApplication();        
        requestMap.put('application', Json.serialize(app));

        PortalApplicationCreationAPI saveApi = new PortalApplicationCreationAPI();
        clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
    }
    //This method is for not passing any record to any object
    @isTest
    public static void TestPortalApplicationCreationAPI2(){
        Map<String, Object> requestMap = new Map<String, Object>();
        PortalApplicationCreationAPI saveApi = new PortalApplicationCreationAPI();
        clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
    }
}