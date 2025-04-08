/**
 * @description       : Assigns the permission set to the USE
 * @author            : Soumik Pattanayak
 * @group             : 
 * @last modified on  : 14-01-2025
 * @last modified by  : Soumik Pattanayak
**/
public class UpdateUserPermissionSetQueueable implements Queueable {
    
    // Class variables to hold user Id and Permission Set Name
    private Id userId;
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(PortalConstants.SIGN_BY));  
    private List<String> permissionSetNameList;
    
    /**
    * @description Constructor to pass parameters to the class
    * @author Soumik Pattanayak | 30-12-2024 
    * @param userId 
    * @param permissionSetNameList 
    **/
    public UpdateUserPermissionSetQueueable(Id userId, List<String> permissionSetNameList) {
        this.userId = userId;
        this.permissionSetNameList = permissionSetNameList;
    }

    /**
    * @description Execute method required by Queueable interface
    * @author Soumik Pattanayak | 30-12-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        try {
            List<PermissionSetAssignment> permissionSetAssignList = new List<PermissionSetAssignment>();
            // Fetch the Permission Set based on the name
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNameList AND Id NOT IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: userId)];
            for(PermissionSet eachPermissionSet : permissionSet){
                //Create a PermissionSetAssignment to assign the permission set to the user
                PermissionSetAssignment psa = new PermissionSetAssignment(
                    AssigneeId = userId,      // User to whom we are assigning the permission set
                    PermissionSetId = eachPermissionSet.Id // PermissionSet to assign
                );
                permissionSetAssignList.add(psa);
                
            }
            // Insert the PermissionSetAssignment record
            Database.upsert(permissionSetAssignList, true);
            

        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = CLASS_NAME,
                    clcommon__Message__c = CLASS_NAME  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
    }
}