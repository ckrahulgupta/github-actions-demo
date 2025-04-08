/**
 * @description       : Purpose of this class is to define the different regex 
 *                      required for validation on the portal.
 * @author            : Rahul Gupta | 06-02-2022
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
**/
global with sharing class PortalRegexUtil {

    public static final String STRING_RGX = '^([\\w\\s\\(\\)-\\.\\%\\?\\!\\&\\+]{1,50})$';
    public static final String DECIMAL_RGX = '^([\\d]{1,})?(\\.[\\d]{0,2})?$';
    public static final String PHONE_RGX = '^(\\+\\d{1,2}\\s?)?1?\\-?\\.?\\s?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}$';
    public static final String EMAIL_RGX = '^([\\w\\.-]{1,50})@([\\w-]{1,50})\\.([\\w-]{1,20})(\\.[\\w-]{1,20})?$';

    public static final Pattern STRING_PATTERN = Pattern.compile(STRING_RGX);
    public static final Pattern DECIMAL_PATTERN = Pattern.compile(DECIMAL_RGX);
    public static final Pattern PHONE_PATTERN = Pattern.compile(PHONE_RGX);
    public static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_RGX);

    /**
    * @description : Validate String
    * @author  Pritam Roy | 03-12-2024 
    * @param input 
    * @return Boolean 
    **/
    public static Boolean isValidString(String input) {
        return STRING_PATTERN.matcher(input).matches();
    }

    /**
    * @description : Validate Decimal
    * @author  Pritam Roy | 03-12-2024 
    * @param input 
    * @return Boolean 
    **/
    public static Boolean isValidDecimal(String input) {
        return DECIMAL_PATTERN.matcher(input).matches();
    }

    // public static Boolean isValidPhone(String input) {
    //     return PHONE_PATTERN.matcher(input).matches();
    // }

    // public static Boolean isValidEmail(String input) {
    //     return EMAIL_PATTERN.matcher(input).matches();
    // }
}