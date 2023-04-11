global without sharing class CommunityRegistrationController {

    public CommunityRegistrationController() {

    }

    @AuraEnabled
    public static String checkApiCallAccess(String name) {
        return 'Hello ' + name + '!';
    }


    global list<Contact> contactList;

    public static List<Contact> getContacts() {
        return [SELECT Id, Name, Email FROM Contact limit 1];
    }

    @AuraEnabled
    global static list<contact> createUser(String userType, String title,String firstName, String lastName, String email, String password){
        try {

            list<Contact> Conlist = [select id from Contact where Email =:email limit 1 ]; 
            return Conlist;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    // Method for create the User of Learning Institue 
    // @AuraEnabled
    // public static list<contact> createCommunityUser(String password) {

    //    try {
            
    //     System.debug('password:'+password);


    //     } catch(Exception e) {
            
    //         System.debug(e.getMessage());
    //         throw new CustException ('Above condition Not satisfy');
    //     }
      
    // return null; 
    // }

    public class CustException extends Exception {
        
    }

    @AuraEnabled(cacheable=true)
    public static List<contact> CommunityUserCheck(String email) {
        list<Contact> Conlist = [select id from Contact where Email =:email limit 1 ]; 
        return Conlist;
    
    }
}