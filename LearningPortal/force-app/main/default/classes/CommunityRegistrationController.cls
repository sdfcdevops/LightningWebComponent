global without sharing class CommunityRegistrationController {

    public CommunityRegistrationController() {

    }

    @AuraEnabled
    public static String checkApiCallAccess(String name) {
        return 'Hello ' + name + '!';
    }


    @AuraEnabled
    public static boolean isEmailExist(String email){
        try {
            
            List<User> userList = new List<User>();
            userList = [Select Id, Name From User Where email = :email];
            return !userList.isEmpty();
        } catch (Exception e) {
            return null;    
        }
    }

    @AuraEnabled
    public static boolean sendVerifyEmail(String email){
        try {
            
            String subject1 = 'Test Emailww';
            String body1 = 'Helloqw';
            String toSend1 = 'tarungupta051@gmail.com';
            String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(body1 + ':' + toSend1)));
            EmailTemplate Emailtempl=[SELECT Id, Name, body FROM EmailTemplate WHERE Name ='Verify Community User'];
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            String[] toAddresses1 = new String[] {toSend1};
            mail1.setToAddresses(toAddresses1);
            mail1.setTemplateId(Emailtempl.id);
            mail1.setSubject(subject1);
            mail1.setHtmlBody(Emailtempl.Body.replace('{!User.FirstName}', 'New User tarun').replace('{!User.ActivationCode}', activationCode));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
            return true;
        } catch (Exception e) {
            return false;    
        }
    }



    @AuraEnabled
    public static string createUser(String userType, String communityNickname,String title,String firstName, String lastName, String email, String password)
    {
        Set<String> communityNicknameSet = new Set<String>();
        String uniqueCommunityNickName;
        String profileID = '';
        String profileIDText = '';
        Boolean MsgEMail = false;
        String erM = 'nofound';
        Set<String> communityAccountId = new Set<String>();
        Map<Id, Contact> contactToAccountIdMap = new Map<Id, Contact>();
        String userId;
        Contact newContact = new Contact();
        try {
            for(User usr : [Select Id, CommunityNickname From User Where CommunityNickname != null]){

                communityNicknameSet.add(usr.CommunityNickname);
            }

            if(communityNicknameSet.isEmpty())
            {

                if(communityNickname.length() > 4){ uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                                            
                    } else { uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                            }
            } else 
            {

                    for(Integer i=1; i <= 9999 ; i++)
                    {

                                                if(communityNickname.length() > 4){
                                                    
                                                    uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                                                
                                                } else {

                                                    uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                                                }

                                                if(!communityNicknameSet.contains(uniqueCommunityNickName)){

                                                    break;
                                                }
                    }
            }
              // get the Community Profile ID based on selected type via Registerion 
              
              list<User> UserList = [SELECT id , name ,email, Account.id , Account.name from User where email=:email AND Account.name = 'Learning institute Portal' ]; 
              if(userType == '1')
              {
              profileID = [select id from profile where name='Student Community Plus User'].id;
              profileIDText = 'Student portal';
              } else if(userType == '2')
              {
              profileID = [select id from profile where name='Alumni Community Plus User'].id;
              profileIDText = 'Alumni portal';
              } 
              
              list<Account> contactsList = [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account where Name = 'Learning institute Portal' ]; 
             
             for(Account contact : contactsList) {
              communityAccountId.add(contact.Id);
              }
              Id accountId = Id.valueOf(communityAccountId.iterator().next());
             
              newContact.title = title;
              newContact.FirstName = firstName;
              newContact.LastName = lastName;
              newContact.Email = email;
              newContact.AccountId = accountId;
  
                  if(userType == '1'){
                      newContact.Student__c = true;
                      newContact.Student_Portal__c = true;
                      newContact.Alumni__c = false;
                      newContact.Alumni_Portal__c = false;
                  }
                  else{
                      newContact.Student__c = false;
                      newContact.Student_Portal__c = false;
                      newContact.Alumni__c = true;
                      newContact.Alumni_Portal__c = true;
                  }
                  insert newContact;
                    System.debug('New Contact record created with Id: ' + newContact.Id);
                    // Here is the create a user and set the profile on user
                    User newCustomerUser = new User();
                    newCustomerUser.Username = uniqueCommunityNickName;
                    newCustomerUser.Email = email;
                    newCustomerUser.FirstName = String.valueof(firstName);
                    newCustomerUser.LastName = String.valueof(lastName);
                    newCustomerUser.Alias = firstName.substring(1, 3);
                    newCustomerUser.CommunityNickname = email.substringBefore('@');
                    newCustomerUser.ContactId = newContact.Id;
                    newCustomerUser.ProfileId = profileID; // Replace with the desired Customer Community Plus profile Id
                    // //insert newCustomerUser;
                    newCustomerUser.LanguageLocaleKey = 'en_US';
                    newCustomerUser.IsActive = false;
                    
                   
                    userId = Site.createPortalUser(newCustomerUser, accountId, password);

                 

                    if (userId != null) {
                
                        String emailResult = sendVerfyEMail(newCustomerUser, userId);

                       
                        
                        if (password != null && password.length() > 1) {
                            ApexPages.PageReference pageRef = Site.login(uniqueCommunityNickName, password, null);
                            if(pageRef != null) return pageRef.getUrl();
                        }
                        else {
                            ApexPages.PageReference page = System.Page.SiteRegisterConfirm;
                            page.setRedirect(true);
                            return page.getUrl();
                        }
                    }
                    
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        return profileIDText+uniqueCommunityNickName+'=>'+communityAccountId+'New Contact record created with Id: ' + newContact.Id+'=>EmailStatus'+MsgEMail;

    }
            
    // Method for create the User of Learning Institue
    @AuraEnabled
    public static List<User> CommunityUserCheck(String email) {
        list<User> UserList = [SELECT id , name ,email, Account.id , Account.name from User where email=:email AND Account.name = 'Learning institute Portal' ]; 
        return UserList;
    
    }

    @AuraEnabled
    public static string sendVerfyEMail(User usr, String userId){
        try {
            String encodedEmail = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(usr.Email)));            
          
           // String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(usr.Username + ':' + usr.Email)));            
           
           // String tokenId = EncodingUtil.convertToHex(Crypto.generateDigest('SHA256', userId + String.valueOf(System.now().getTime())));
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(usr.Username + ':' + usr.Email)));            
            
            //String verificationUrl = 'https://tarungupta-sfdx-dev-ed.develop.my.site.com/learningportal/s/verify?token=' + activationCode + '&email=' + encodedEmail;
            String verificationUrl = 'https://tarungupta-sfdx-dev-ed.develop.my.site.com/learningportal/s/ActivateUser?tokenc=' + activationCode + '&email=' + encodedEmail;

           
            List<EmailTemplate> VerfyTemplate = new List<EmailTemplate>([Select Id from EmailTemplate where name = 'Verify Email']);      
            mail.setSenderDisplayName('learning institute Portal');
            mail.setTargetObjectId(userId);
            mail.setTemplateId(VerfyTemplate[0].Id);
            mail.setSaveAsActivity(false);
            mail.setSubject('Verify your email address');
            String plainTextBody = 'Dear ' + usr.FirstName + ',\n\nThank you for Registered.! We hope you are enjoying it.\n\n Please click on the following link to verify your email address: \n    Verification Link : ' + verificationUrl + '.\n\nThanks again,\n If you have any questions, please contact us at support@learningInstitute.com \n\n The team \n Learning Institute Support';
            mail.setPlainTextBody(plainTextBody);


           // mail.setPlainTextBody(emailTemplateBody.replace('{!VerificationUrl}', verificationUrl));
           
            Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail} );

            return 'success';

        } catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string sendWelcomeEMail(User usr, String userId){
        try {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(usr.Username + ':' + usr.Email)));            
            List<EmailTemplate> welcomeTemplate = new List<EmailTemplate>([Select Id from EmailTemplate where name = 'Verify Community User']);      
            mail.setSenderDisplayName('Learning Portol');
            mail.setTargetObjectId(userId);
            mail.setTemplateId(welcomeTemplate[0].Id);
            mail.setSaveAsActivity(false);

            Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail} );

            return 'success';

        } catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
    }

}