/**
 * @description       : Helper class for Statement Code modification
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Kabir Pramanik
**/

public inherited sharing class StatementCodeHelper {

    private static final String KEY_PARTNER_PROGRAM_ID = 'PartnerProgramId';
    private static final String GROWMARK_LIKE_STRING = 'GROWMARK%';

    /**
    * @description Returns the existing statement code details with security enforced
    * @author Rahul Gupta | 08-02-2023 
    * @param loanList 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getAllStatementCodeDetailsWtihSecurity(List<Map<String, Object>> loanList) {

        Map<String, Object> statementCodesMap = new Map<String, Object>();
        List<String> partnerProgramIdList = new List<String>();
        List<CFA_Partner_Program__c> partnerProgramList = new List<CFA_Partner_Program__c>();

        List<Statement_Code__mdt> statementCodesMetaData = [
                        SELECT Id,
                               Label,
                               Opt_Out_Code__c,
                               Opt_In_Code__c
                        FROM Statement_Code__mdt
                        WHERE Label LIKE :GROWMARK_LIKE_STRING
                        WITH SECURITY_ENFORCED
                    ];

        for (Map<String, Object> activeLoan : loanList) {  
            if (activeLoan.get(KEY_PARTNER_PROGRAM_ID) != null) {
                partnerProgramIdList.add(String.valueOf(activeLoan.get(KEY_PARTNER_PROGRAM_ID)));
            }
        }
        if(!partnerProgramIdList.isEmpty()){
            partnerProgramList = [SELECT Id,
                                        Name,
                                        Statement_Code_Single_Rate_Opt_In__c,
                                        Statement_Code_Multi_Rate_Opt_In__c
                                    FROM CFA_Partner_Program__c
                                   WHERE Id IN :partnerProgramIdList
                                    WITH SECURITY_ENFORCED];
        }

        for (Statement_Code__mdt statementCodeMetaData : statementCodesMetaData) {
            if (String.isNotBlank(statementCodeMetaData.Label) 
                && !statementCodesMap.containsKey(statementCodeMetaData.Label)) {
                statementCodesMap.put(
                        String.valueOf(statementCodeMetaData.Label), 
                        statementCodeMetaData
                    );
            }
        }
        statementCodesMap = addOptInStatementCode(partnerProgramList, statementCodesMap);
       
        return statementCodesMap;
    }

    /**
     * @description Returns the existing statement code details
     * 
     * @author Rahul Gupta | 08-02-2023 
     * @return Map<String, Statement_Code__mdt> returns the map containing statement code details
     */
    public static Map<String, Statement_Code__mdt> getAllStatementCodeDetails() { 

        Map<String, Statement_Code__mdt> statementCodesMap = new Map<String, Statement_Code__mdt>();

        List<Statement_Code__mdt> statementCodesMetaData = [ 
                        SELECT Id,
                               Label,
                               Opt_Out_Code__c,
                               Opt_In_Code__c
                        FROM Statement_Code__mdt
                    ];

        for (Statement_Code__mdt statementCodeMetaData : statementCodesMetaData) {
            if (String.isNotBlank(statementCodeMetaData.Label) 
                && !statementCodesMap.containsKey(statementCodeMetaData.Label)) {
                statementCodesMap.put(
                        String.valueOf(statementCodeMetaData.Label), 
                        statementCodeMetaData
                    );
            }
        }

        return statementCodesMap;
    }

    /**
     * @description Returns the existing statement code labels based on the opt-out status
     * 
     * @author Rahul Gupta | 08-02-2023 
     * @return Map<String, Statement_Code__mdt> returns the map containing statement code details
     */
    public static Set<String> getOptOutStatementCodes() {

        Set<String> statementCodes = new Set<String>();

        List<Statement_Code__mdt> statementCodesMetaData = [
                        SELECT Id,
                               Opt_Out_Code__c
                        FROM Statement_Code__mdt
                        WITH SECURITY_ENFORCED
                    ];

        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Statement_Code_Single_Rate_Opt_Out__c,
                                                                Statement_Code_Multi_Rate_Opt_Out__c
                                                            FROM CFA_Partner_Program__c
                                                            WITH SECURITY_ENFORCED];

        for(CFA_Partner_Program__c eachPartnerProgram : partnerProgramList){

            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Single_Rate_Opt_Out__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Single_Rate_Opt_Out__c));
            }

            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_Out__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_Out__c));
            }
        }

        for (Statement_Code__mdt statementCodeMetaData : statementCodesMetaData) {
            if (String.isNotBlank(statementCodeMetaData.Opt_Out_Code__c)) {
                statementCodes.add(String.valueOf(statementCodeMetaData.Opt_Out_Code__c));
            }
        }

        return statementCodes;
    }

    /**
     * @description Returns the existing statement code labels based on the opt-out status
     * 
     * @author Rahul Gupta | 08-02-2023 
     * @return Map<String, Statement_Code__mdt> returns the map containing statement code details
     */

     
    /**
    * @description Returns the existing statement code labels based on the opt-out status
    * @author Rahul Gupta | 08-02-2023 
    * @param programIdList 
    * @return Set<String> 
    **/
    public static Set<String> getAllStatementCodes(List<String> programIdList) {

        Set<String> statementCodes = new Set<String>();
        List<CFA_Partner_Program__c> partnerProgramList = new List<CFA_Partner_Program__c>();

        List<Statement_Code__mdt> statementCodesMetaData = [
                        SELECT Id,
                               Opt_Out_Code__c,
                               Opt_In_Code__c
                        FROM Statement_Code__mdt
                        WITH SECURITY_ENFORCED
                    ];
        if(!programIdList.isEmpty()){
            partnerProgramList = [SELECT Id,
                                        Statement_Code_Single_Rate_Opt_In__c,
                                        Statement_Code_Single_Rate_Opt_Out__c,
                                        Statement_Code_Multi_Rate_Opt_In__c,
                                        Statement_Code_Multi_Rate_Opt_Out__c
                                    FROM CFA_Partner_Program__c
                                    WHERE Id IN :programIdList
                                    WITH SECURITY_ENFORCED];
        }

        for (Statement_Code__mdt statementCodeMetaData : statementCodesMetaData) {
            if (String.isNotBlank(statementCodeMetaData.Opt_Out_Code__c)) {
                statementCodes.add(String.valueOf(statementCodeMetaData.Opt_Out_Code__c));
            }

            if (String.isNotBlank(statementCodeMetaData.Opt_In_Code__c)) {
                statementCodes.add(String.valueOf(statementCodeMetaData.Opt_In_Code__c));
            }
        }
        statementCodes = addStatementCodes(partnerProgramList, statementCodes);

        return statementCodes;
    }
    /**
    * @description Add all statement codes specific programs.
    * @author Ayan Bhowmik | 07-15-2024 
    * @param partnerProgramList 
    * @param statementCodes 
    * @return Set<String> 
    **/
    private static Set<String> addStatementCodes(List<CFA_Partner_Program__c> partnerProgramList, Set<String> statementCodes){
        for(CFA_Partner_Program__c eachPartnerProgram : partnerProgramList){
            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Single_Rate_Opt_In__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Single_Rate_Opt_In__c));
            }

            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Single_Rate_Opt_Out__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Single_Rate_Opt_Out__c));
            }
            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_In__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_In__c));
            }

            if (String.isNotBlank(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_Out__c)) {
                statementCodes.add(String.valueOf(eachPartnerProgram.Statement_Code_Multi_Rate_Opt_Out__c));
            }
        }
        return statementCodes;
    }
    /**
    * @description Add all opt in statement code for specific programs.
    * @author Ayan Bhowmik | 07-15-2024 
    * @param partnerProgramList 
    * @param statementCodesMap 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> addOptInStatementCode(List<CFA_Partner_Program__c> partnerProgramList,
                                                                Map<String, Object> statementCodesMap){
        for(CFA_Partner_Program__c eachProgram : partnerProgramList){
            if (String.isNotBlank(eachProgram.Statement_Code_Single_Rate_Opt_In__c)
                        && !statementCodesMap.containsKey(eachProgram.Statement_Code_Single_Rate_Opt_In__c + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX)) {
                statementCodesMap.put(String.valueOf(eachProgram.Name).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX, eachProgram);
            }
            if (String.isNotBlank(eachProgram.Statement_Code_Multi_Rate_Opt_In__c)
                        && !statementCodesMap.containsKey(eachProgram.Statement_Code_Multi_Rate_Opt_In__c + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX)) {
                statementCodesMap.put(String.valueOf(eachProgram.Name).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX, eachProgram);
            }
        }
        return statementCodesMap;
    }
}