/**
 * @description       : Test class for PaymentReceiptController
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-19-2025
 * @last modified by  : Rahul Gupta
**/
@isTest
public class PaymentReceiptControllerTest {
    
    /**
    * @description - success scenario for testing ACH by Dealer
    * @author Sk Minsar | 12-17-2024 
    **/
    @IsTest
    public static void testACHByDealerSuccess() {

        pageReference pdfPage = Page.PaymentReceipt;
                 
        pdfPage.getParameters().put(PortalConstants.KEY_LOAN_NUMBER, '1000850001-A');
        pdfPage.getParameters().put(PortalConstants.KEY_GROWER_NAME, 'Marcus Lutrell');
        pdfPage.getParameters().put(PortalConstants.KEY_PAYMENT_MODE, 'ACH');
        pdfPage.getParameters().put(PortalConstants.KEY_COOP_TYPE, 'Growmark');

        pdfPage.getParameters().put(PortalConstants.KEY_IS_PAID_BY_DEALER, 'true');
        pdfPage.getParameters().put(PortalConstants.KEY_TOTAL_AMOUNT, '1000.01');
        pdfPage.getParameters().put(PortalConstants.KEY_CREATED_DATE, String.valueOf(System.now()));
        pdfPage.getParameters().put(PortalConstants.KEY_TRASACTION_NUMBER, 'TRAN-0000001');
        pdfPage.getParameters().put(PortalConstants.KEY_SHOW_COMMENT, 'true');
        pdfPage.getParameters().put(PortalConstants.KEY_COMMENTS, 'This is a test comment');
        pdfPage.getParameters().put(PortalConstants.KEY_LOGO, '/resource/agriFinancePortalLogo');

        List<Map<String, Object>> transactions = new List<Map<String, Object>>();

        transactions.add(
            new Map<String, Object> {
                PortalConstants.KEY_LOAN_NUMBER     => '1000850001-A',
                PortalConstants.KEY_PRINCIPAL       => 0.00,
                PortalConstants.KEY_INTEREST        => 0.00,
                PortalConstants.KEY_FEES            => 0.00,
                PortalConstants.KEY_AMOUNT          => 1000.01,
                PortalConstants.KEY_DESCRIPTION     => 'Need to buy seeds'
            }
        );

        pdfPage.getParameters().put(PortalConstants.KEY_TRANSACTIONS, JSON.serialize(transactions));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Test.startTest();

            Test.setCurrentPage(pdfPage);

            PaymentReceiptController controller = new PaymentReceiptController();
            Map<String, Object> pageParameters = controller.pageParameters;

            System.assertEquals('1000850001-A', pageParameters.get(PortalConstants.KEY_LOAN_NUMBER), 'Failed to set Loan #');
            System.assertEquals('Marcus Lutrell', pageParameters.get(PortalConstants.KEY_GROWER_NAME), 'Failed to set Grower name');
            System.assertEquals('ACH', pageParameters.get(PortalConstants.KEY_PAYMENT_MODE), 'Failed to set Payment mode');
            System.assertEquals('Growmark', pageParameters.get(PortalConstants.KEY_COOP_TYPE), 'Failed to set Coop type');
            System.assertEquals(true, pageParameters.get(PortalConstants.KEY_IS_PAID_BY_DEALER), 'Failed to set Is Paid By Dealer');
            System.assertEquals('1000.01', pageParameters.get(PortalConstants.KEY_TOTAL_AMOUNT), 'Failed to set Total amount');
            System.assertEquals(System.now(), pageParameters.get(PortalConstants.KEY_CREATED_DATE), 'Failed to set Created date');
            System.assertEquals('TRAN-0000001', pageParameters.get(PortalConstants.KEY_TRASACTION_NUMBER), 'Failed to set Transaction #');
            System.assertEquals(true, pageParameters.get(PortalConstants.KEY_SHOW_COMMENT), 'Failed to set show comment');
            System.assertEquals('This is a test comment', pageParameters.get(PortalConstants.KEY_COMMENTS), 'Failed to set Comment');
            System.assertEquals('/resource/agriFinancePortalLogo', pageParameters.get(PortalConstants.KEY_LOGO), 'Failed to set Logo');
          
            Test.stopTest();
        }
    }


    /**
    * @description - failure scenario for testing ACH by Dealer with invalid created date
    * @author Sk Minsar | 12-17-2024 
    **/
    @IsTest
    public static void testACHByDealerInvalidCreatedDateFailure() {

        pageReference pdfPage = Page.PaymentReceipt;
                 
        pdfPage.getParameters().put(PortalConstants.KEY_LOAN_NUMBER, '1000850001-A');
        pdfPage.getParameters().put(PortalConstants.KEY_GROWER_NAME, 'Marcus Lutrell');
        pdfPage.getParameters().put(PortalConstants.KEY_PAYMENT_MODE, 'ACH');
        pdfPage.getParameters().put(PortalConstants.KEY_COOP_TYPE, 'Growmark');

        pdfPage.getParameters().put(PortalConstants.KEY_IS_PAID_BY_DEALER, 'true');
        pdfPage.getParameters().put(PortalConstants.KEY_TOTAL_AMOUNT, '1000.01');
        pdfPage.getParameters().put(PortalConstants.KEY_CREATED_DATE, '123');
        pdfPage.getParameters().put(PortalConstants.KEY_TRASACTION_NUMBER, 'TRAN-0000001');
        pdfPage.getParameters().put(PortalConstants.KEY_SHOW_COMMENT, 'true');
        pdfPage.getParameters().put(PortalConstants.KEY_COMMENTS, 'This is a test comment');
        pdfPage.getParameters().put(PortalConstants.KEY_LOGO, '/resource/agriFinancePortalLogo');

        List<Map<String, Object>> transactions = new List<Map<String, Object>>();

        transactions.add(
            new Map<String, Object> {
                PortalConstants.KEY_LOAN_NUMBER     => '1000850001-A',
                PortalConstants.KEY_PRINCIPAL       => 0.00,
                PortalConstants.KEY_INTEREST        => 0.00,
                PortalConstants.KEY_FEES            => 0.00,
                PortalConstants.KEY_AMOUNT          => 1000.01,
                PortalConstants.KEY_DESCRIPTION     => 'Need to buy seeds'
            }
        );

        pdfPage.getParameters().put(PortalConstants.KEY_TRANSACTIONS, JSON.serialize(transactions));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Test.startTest();

            Test.setCurrentPage(pdfPage);

            PaymentReceiptController controller = new PaymentReceiptController();

            List<clcommon__Log__c> errorLog = [
                    SELECT Id
                    FROM clcommon__Log__c
                    WHERE Name = :PaymentReceiptController.class.getName()
                    LIMIT 1
                ];

            System.assertEquals(1, errorLog.size(), 'Created controller instance with wrong data type');
            System.assertEquals('123', controller.pageParameters.get(PortalConstants.KEY_CREATED_DATE), 'Created controller instance with wrong data type');
            
            Test.stopTest();
        }
    }
}