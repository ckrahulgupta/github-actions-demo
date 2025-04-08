/**
 * @description       : 
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 09-20-2024
 * @last modified by  : Sk Minsar
**/

global without sharing class GMKSaveRateCardDetailsHandler {
    //constants specific to this class starts
    private static final String SPECIAL_TERM_C = PortalConstants.SPECIAL_TERM_C;
    private static final String SPECIAL_TERM_D = PortalConstants.SPECIAL_TERM_D;
    private static final String SPECIAL_TERM_E = PortalConstants.SPECIAL_TERM_E;
    private static final String SPECIAL_TERM_F = PortalConstants.SPECIAL_TERM_F;
    private static final String SPECIAL_TERM_G = PortalConstants.SPECIAL_TERM_G;
    private static final String SPECIAL_TERM_H = PortalConstants.SPECIAL_TERM_H;
    private static final String MASTER_NOTERATE_A = PortalConstants.MASTER_NOTERATE_A;
    private static final String SUB_TRANCHE_B = PortalConstants.SUB_TRANCHE_B;
    private static final String SUB_TRANCHE_C = PortalConstants.SUB_TRANCHE_C;
    private static final String SUB_TRANCHE_D = PortalConstants.SUB_TRANCHE_D;
    private static final String SUB_TRANCHE_E = PortalConstants.SUB_TRANCHE_E;
    private static final String SUB_TRANCHE_F = PortalConstants.SUB_TRANCHE_F;
    private static final String SUB_TRANCHE_G = PortalConstants.SUB_TRANCHE_G;
    private static final String SUB_TRANCHE_H = PortalConstants.SUB_TRANCHE_H;
    //constants specific to this class ends
    /**
    * @description : 
    * @author  Pritam Roy | 07-25-2024 
    * @param objRateCardHeaderList 
    **/
    public static void validateRateCardHeader(List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList){
        if(objRateCardHeaderList[0].Name == null ||
            objRateCardHeaderList[0].Account__r.Name == null ||
            objRateCardHeaderList[0].FS_Index_Rate__c == null ||
            objRateCardHeaderList[0].genesis__End_Date__c == null) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description : Get the sub tranche
    * @author  Pritam Roy | 03-04-2024 
    * @param specialTermName 
    * @return String 
    **/
    public static String getSubTranche(String specialTermName) {

        if (specialTermName == MASTER_NOTERATE_A) {
            return PortalConstants.SPECIAL_TERM_A;
        } 
        if (specialTermName == SUB_TRANCHE_B) {
            return PortalConstants.SPECIAL_TERM_B;
        } 
        if (specialTermName == SUB_TRANCHE_C) {
            return SPECIAL_TERM_C;
        } 
        if (specialTermName == SUB_TRANCHE_D) {
            return SPECIAL_TERM_D;
        } 
        if (specialTermName == SUB_TRANCHE_E) {
            return SPECIAL_TERM_E;
        }
        if (specialTermName == SUB_TRANCHE_F) {
            return SPECIAL_TERM_F;
        }
        if (specialTermName == SUB_TRANCHE_G) {
            return SPECIAL_TERM_G;
        }
        if (specialTermName == SUB_TRANCHE_H) {
            return SPECIAL_TERM_H;
        }
        return null;
    }
}