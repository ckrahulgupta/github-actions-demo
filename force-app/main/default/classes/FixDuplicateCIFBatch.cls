/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-31-2025
 * @last modified by  : Krishanu Chinya
**/
global class FixDuplicateCIFBatch implements Database.Batchable<sObject>, Database.Stateful {
    // Map to track which CIFs should be retained
    private Map<String, Id> validCIFs = new Map<String, Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all accounts where CIF is not null
        return Database.getQueryLocator(
            [SELECT Id, cif_number__c, RecordType.Name,coop_type__c,name
            FROM Account 
            WHERE cif_number__c != null 
            AND recordtype.name in ('Grower','CoApplicant') and Id in ('001VD000009AlF6YAK','001VD000009ArqhYAC')]  //38732 accounts in prod
        );
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountsList) {
        System.debug('accounts fetched : ' + accountsList.size());
        Map<String, List<Account>> cifVsAccountsMap = new Map<String, List<Account>>();
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, List<genesis__applications__c>> accVsAppMap = new Map<Id, List<genesis__applications__c>>(); //tracks all apps of an account
        Map<Id, List<genesis__applications__c>> accVsAppinNLSMap = new Map<Id, List<genesis__applications__c>>(); //tracks apps that are presnt in NLS
        List<genesis__applications__c> appsToUpdate = new List<genesis__applications__c>();

        List<genesis__Applications__c> appList = [Select id, name,genesis__account__c, genesis__Status__c from genesis__Applications__c where genesis__account__c in :accountsList];
        
        //making a map of cif vs the accounts they are used 
        for (Account acc : accountsList) {
            if (!cifVsAccountsMap.containsKey(acc.cif_number__c)) {
                cifVsAccountsMap.put(acc.cif_number__c, new List<Account>());
            }
            cifVsAccountsMap.get(acc.cif_number__c).add(acc);
            System.debug('for this cif : ' + cifVsAccountsMap.get(acc.cif_number__c));
        }
        System.debug ('cifVsAccountsMap : ' + cifVsAccountsMap);

        //making an map of each account and the apps where they are present as borrower
        for(genesis__applications__c app : appList){
            if (!accVsAppMap.containsKey(app.genesis__account__c)) {
                accVsAppMap.put(app.genesis__account__c, new List<genesis__applications__c>());
            }
            accVsAppMap.get(app.genesis__account__c).add(app);

            if(app.genesis__status__c == 'ACTIVE' || app.genesis__status__c == 'CLOSED'){
                if (!accVsAppinNLSMap.containsKey(app.genesis__account__c)) {
                    accVsAppinNLSMap.put(app.genesis__account__c, new List<genesis__applications__c>());
                }
                accVsAppinNLSMap.get(app.genesis__account__c).add(app);
            }
            
        }
                
        //for each cif, we process
        for (String cif : cifVsAccountsMap.keySet()) {
            System.debug('CIF Chosen : ' + cif);
            List<Account> accounts = cifVsAccountsMap.get(cif);
            if(accounts.size()==1){
                continue; 
            }
            Account borrowerAccount = null;

            Boolean borrowerWithLoanInNLSFound = false;
            List<Account> checkAccLaterList = new List<Account>();

            System.debug('accounts size : ' + accounts.size());
            System.debug('accounts to process : ' + accounts);
            
            for (Account acc : accounts) {
                System.debug('Account chosen : ' + acc.name);

                //check if there's an application in Active or Closed
                List<genesis__applications__c> appsInNLS = accVsAppinNLSMap.get(acc.id);
                List<genesis__applications__c> appsList = accVsAppMap.get(acc.id);

                if(!appsInNLS.isEmpty() && borrowerWithLoanInNLSFound== true){
                    //critical case: 2 grower has loans in nls with same cif
                    System.debug('critical case: 2 grower has loans in nls with same cif');
                    //need changes in NLS

                    acc.cif_number__c = getNewCIF(acc.coop_type__c);
                    accountsToUpdate.add(acc);
                    appsToUpdate.addAll(appsList); //update the apps later

                    System.debug('UPDATE NLS FOR ACCOUNT : ' + acc.id);
                }
                
                if(!appsInNLS.isEmpty()){
                    System.debug('growers who have a loan present in NLS, dont update CIF in this case');
                    borrowerWithLoanInNLSFound = true; //growers who have a loan present in NLS, don't update CIF in this case
                    continue;
                }
                
                if(appsInNLS.isEmpty() && !appsList.isEmpty()){ //grower has apps, not present in NLS
                    System.debug('grower has apps, not present in NLS');
                    if(borrowerWithLoanInNLSFound == true ){ //we already have a grower with app in NLS with this cif, so update cif and loan number here
                        System.debug('we already have a grower with app in NLS with this cif, so update cif and loan number here');
                        acc.cif_number__c = getNewCIF(acc.coop_type__c);
                        accountsToUpdate.add(acc);
                        appsToUpdate.addAll(appsList); //update the apps later
                    }else{ //we are not having a grower who is having an app in nls but have an app
                        //don't update cif now, check all cif  and decide later
                        System.debug('dont update cif now, check all cif  and decide later');
                        checkAccLaterList.add(acc);  //what if 2 grower has new-entered apps
                        continue;
                    }
                    
                }

                if(appsInNLS.isEmpty() && appsList.isEmpty()){
                    System.debug('coapplicant');
                    acc.cif_number__c = getNewCIF(acc.coop_type__c);
                    accountsToUpdate.add(acc);
                }
            }

            for(Account currAcc : checkAccLaterList){
                List<genesis__applications__c> appsList = accVsAppMap.get(currAcc.id);

                if(borrowerWithLoanInNLSFound == true ){ //we already have a grower with app in NLS with this cif, so update cif and loan number here
                    System.debug('we already have a grower with app in NLS with this cif, so update cif and loan number here');
                    currAcc.cif_number__c = getNewCIF(currAcc.coop_type__c);
                    accountsToUpdate.add(currAcc);
                    appsToUpdate.addAll(appsList); //update the apps later
                }else{
                    borrowerWithLoanInNLSFound = true;
                }
            }
        }
        
        // Update accounts with new CIFs
        if (!accountsToUpdate.isEmpty()) {
            Database.update(accountsToUpdate);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    // Utility method to generate a unique CIF
    private String getNewCIF(String coopType) {
        CFA_Configuration__c latestCIF = [SELECT CIF_Number__c,
                                                    Growmark_CIF_Number__c
                                              FROM CFA_Configuration__c];
        String newCIF = '';

        if(coopType == 'Growmark'){
            newCIF = latestCIF.Growmark_CIF_Number__c;
            latestCIF.Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.Growmark_CIF_Number__c) + PortalConstants.ONE_VALUE);
        }else{
            newCIF = latestCIF.CIF_Number__c;
            latestCIF.CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.CIF_Number__c) + PortalConstants.ONE_VALUE);
        }
        Database.Update(latestCIF, true);

        //what if app coop and account coop is different 

        return newCIF;
        
    }
}