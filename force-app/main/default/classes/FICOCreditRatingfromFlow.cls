/**
 * @description       : Invocable class which calls the queueable for credit rating matrix
 * @author            : Subham Nandi
 * Created Date       : 01-27-2022
 * @group             : 
 * @last modified on  : 02-29-2024
 * @last modified by  : Ayan Bhowmik
**/

global without sharing class FICOCreditRatingfromFlow {
    /**
    * @description Calling the queueable credit rating for fico
    * @author Ayan Bhowmik | 02-29-2024 
    * @param applicationIdList 
    **/
    @invocableMethod(label = 'CategorisingTheApplication')
    global static void callTheQueueableCreditRating (List<String> applicationIdList){
        try {
            if(applicationIdList == null || applicationIdList.size() == 0){
                throw new CustomException(ConstantValues.FICOFLOW_EXCEPTION);
            }
            else{
                String applicationId = applicationIdList[0];
                FICOCreditRating.ficoCreditRatingMatrix(applicationId);
            }
        } 
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
    }
}