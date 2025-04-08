/**
 * @description       :  Does FICO callout
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  :  Pritam Roy
**/

global without sharing class FICOFromFlow {
    /**
    * @description Calls the FICOCallout class
    * @author  Pritam Roy | 03-04-2024 
    * @param applicationIdList 
    **/
    @invocableMethod(label = 'AutomateFICOfromFlow')
    global static void callTheQueueableFICO (List<String> applicationIdList){
        try {
            if(applicationIdList.size() == 0 || applicationIdList == null){
                throw new CustomException(ConstantValues.APPLICATION_ID_MISSING);
            }
            //call the FICOCallout class
            FICOCallout ficoCallout = new FICOCallout(applicationIdList[0]);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);

        } catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.FICOFROM_FLOW_ERROR);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.FICOFROM_FLOW_ERROR);
        }
        
    }

}