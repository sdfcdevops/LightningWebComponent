public without sharing class StudentAuthController {
    public StudentAuthController() {

    }

    // @AuraEnabled(cacheable=true)
    // public static Boolean isEmailExists(String email) {
    //     try {
    //         System.debug('yourstudent@gmail.com');
    //     String profileName = 'Student Identity User';
    //     List<User> userList = new List<User>();
    //     userList = [select id, name,email, profile.name, userrole.name from user where email = :email];
    //     return !userList.isEmpty();
    //     } catch (Exception e) {
    //     return false;
    //     }
    // }

    @AuraEnabled
    public static void createAccount(String firstName, String lastName, String email, String password) {

            User u = new User();
            u.firstName = firstName;
            u.lastName = lastName;
            u.Email = email;
            String accountId;
            Account portalAccount = new Account();
            portalAccount.Name = firstName + ' ' + lastName;
            insert portalAccount;
            portalAccount.IsPartner = true;
            update portalAccount;

            accountId = portalAccount.Id;
            String userId = Site.createPortalUser(u, accountId, password);
        // Create a new account record
     
    }
    
}