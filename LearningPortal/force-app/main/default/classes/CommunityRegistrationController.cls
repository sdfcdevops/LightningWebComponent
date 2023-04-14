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
    public static string createUser(String userType, String communityNickname,String title,String firstName, String lastName, String email, String password){
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

            Set<String> communityNicknameSet = new Set<String>();

            for(User usr : [Select Id, CommunityNickname From User Where CommunityNickname != null]){

                communityNicknameSet.add(usr.CommunityNickname);
            }

            String uniqueCommunityNickName;

            if(communityNicknameSet.isEmpty())
            {

                if(communityNickname.length() > 4){ uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                                            
                    } else { uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                            }
            } else {

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
            String profileID = '';
            String profileIDText = '';
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
          
          
            Set<String> communityAccountId = new Set<String>();
            //get the contact list of account id 
            Map<Id, Contact> contactToAccountIdMap = new Map<Id, Contact>();
            list<Account> contactsList = [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account where Name = 'Learning institute Portal' ]; 
           
           for(Account contact : contactsList) {
            communityAccountId.add(contact.Id);
            }
     
            System.debug(contactsList);

            Id accountId = Id.valueOf(communityAccountId.iterator().next());
            String userId;
            Contact newContact = new Contact();
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
              
               
                try {
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
                    newCustomerUser.IsActive = false;

                   userId = Site.createPortalUser(newCustomerUser, accountId, password);
                   
                    //insert newCustomerUser;

                 //   userId = Site.createPortalUser(newCustomerUser, accountId, password);

                    // if(userId != '' || userId != 'undefind') {

                    //     List<User> userLists = [SELECT Id, Email, IsActive FROM User WHERE Email = :email];

                    //     if (userLists.size() > 0) 
                    //     {
                    //         User user = userLists[0];
                    //         if (!user.IsActive) 
                    //         {
                    //             String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(user.Id + ':' + user.Email)));
        
                    //             // Set activation code on user record
                    //             // user.ActivationCode = activationCode;
                    //             // update user;

                    //             // Set activation code on user record
                    //             // newCustomerUser.ActivationCode = activationCode;
                    //             // update user;

                    //                   EmailTemplate Emailtempl=[SELECT Id, Name, body FROM EmailTemplate WHERE Name ='Verify Community User'];
                    //                   Messaging.reserveSingleEmailCapacity(1);
                                      
                    //                   try {
                    //                     messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
                    //                 //    toAddress.add('krrish.kishore02@gmail.com');
                    //                 //             ccAddress = new List<String>(); //{'bala.bandanadam@birlasoft.com'};
                                                        
                    //                             // mail.setToAddresses(user.Email);
                    //                             // mail.setCcAddresses(user.Email);
                    //                             mail.setToAddresses(new String[] { user.Email });    
                    //                             mail.setReplyTo(user.Email);
                    //                             mail.setTemplateId(Emailtempl.id);
                    //                             mail.setSenderDisplayName('Tarun');
                    //                             mail.setSubject('Welcome to our'+profileIDText);
                    //                             mail.setHtmlBody(Emailtempl.Body.replace('{!User.FirstName}',  user.Id)); 
                                              
                    //                             Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
                    //                   } catch(Exception e) {
                    //                     System.debug(e.getMessage());
                    //                     throw new AuraHandledException(e.getMessage());
                    //                     //return null;
                    //                   }
                    //                 // Send activation email
                    //                 // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //                 // mail.setTargetObjectId(userId);
                    //                 // mail.setTemplateId(Emailtempl.id);
                    //                 // mail.setToAddresses(new String[] { newCustomerUser.email });    
                    //                 // mail.setSubject('Welcome to our'+profileIDText);
                    //                 // mail.setHtmlBody(Emailtempl.Body.replace('{!User.FirstName}',  newCustomerUser.FirstName));    
                    //                 // mail.saveAsActivity = false;
       
                    //                 // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    //                 System.debug('Activation email sent to user with email ' + email);
                    //         } else {
                    //                     System.debug('User with email ' + email + ' is already active.');
                    //         }
                    //     } else {
                    //                  System.debug('User with email ' + email + ' not found.');
                    //             }
                    //     // Template Name : Verify Community User
                    //     // EmailTemplate Emailtempl=[SELECT Id, Name, body FROM EmailTemplate WHERE Name ='Verify Community User'];
                    //     // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //     // mail.setTemplateId(Emailtempl.id);
                    //     // mail.setToAddresses(new String[] { newUser.email });           
                    //     // mail.setSubject('Welcome to our'+profileIDText);
                    //     // mail.setHtmlBody(Emailtempl.Body.replace('{!User.Id}', newCustomerUser.ContactId));          
                    //     // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    //     // return 

                    // }
                    // Enable a Customer User for the Contact record

                } catch(Exception e) {
                    System.debug('Error creating Contact record: ' + e.getMessage());
                }

               // List<User> userLists = [SELECT Id, Email, IsActive FROM User WHERE Email = :email];

                // if (userLists.size() > 0) 
                // {
                //     User user = userLists[0];
                //     if (!user.IsActive) 
                //     {
                //         String activationCode = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(user.Id + ':' + user.Email)));

                //         // Set activation code on user record
                //         // user.ActivationCode = activationCode;
                //         // update user;

                //         // Set activation code on user record
                //         // newCustomerUser.ActivationCode = activationCode;
                //         // update user;

                //               EmailTemplate Emailtempl=[SELECT Id, Name, body FROM EmailTemplate WHERE Name ='Verify Community User'];
                //               Messaging.reserveSingleEmailCapacity(1);
                              
                //               try {
                //                 messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
                //             //    toAddress.add('krrish.kishore02@gmail.com');
                //             //             ccAddress = new List<String>(); //{'bala.bandanadam@birlasoft.com'};
                                                
                //                         // mail.setToAddresses(user.Email);
                //                         // mail.setCcAddresses(user.Email);
                //                         mail.setToAddresses(new String[] { user.Email });    
                //                         mail.setReplyTo(user.Email);
                //                         mail.setTemplateId(Emailtempl.id);
                //                         mail.setSenderDisplayName('Tarun');
                //                         mail.setSubject('Welcome to our'+profileIDText);
                //                         mail.setHtmlBody(Emailtempl.Body.replace('{!User.FirstName}',  user.Id)); 
                                      
                //                         Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
                //               } catch(Exception e) {
                //                 System.debug(e.getMessage());
                //                 throw new AuraHandledException(e.getMessage());
                //                 //return null;
                //               }
                //             // Send activation email
                //             // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //             // mail.setTargetObjectId(userId);
                //             // mail.setTemplateId(Emailtempl.id);
                //             // mail.setToAddresses(new String[] { newCustomerUser.email });    
                //             // mail.setSubject('Welcome to our'+profileIDText);
                //             // mail.setHtmlBody(Emailtempl.Body.replace('{!User.FirstName}',  newCustomerUser.FirstName));    
                //             // mail.saveAsActivity = false;

                //             // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                //             System.debug('Activation email sent to user with email ' + email);
                //     } else {
                //                 System.debug('User with email ' + email + ' is already active.');
                //     }
                // } else {
                //              System.debug('User with email ' + email + ' not found.');
                // }

               String subject = 'Test Email';
               String body = 'Hello';
               String toSend = 'tarungupta051@gmail.com';


                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {toSend};
                mail.setToAddresses(toAddresses);
                mail.setSubject(subject);
                mail.setHtmlBody('<h1>'+ body + '</h1>');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            return profileIDText+uniqueCommunityNickName+'=>'+communityAccountId+'New Contact record created with Id: ' + newContact.Id+'=>';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    // Method for create the User of Learning Institue
    @AuraEnabled
    public static List<User> CommunityUserCheck(String email) {
        list<User> UserList = [SELECT id , name ,email, Account.id , Account.name from User where email=:email AND Account.name = 'Learning institute Portal' ]; 
        return UserList;
    
    }
}