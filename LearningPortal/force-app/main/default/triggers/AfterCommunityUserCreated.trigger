trigger AfterCommunityUserCreated on User (before insert,before update) {
    List<User> communityUsers = new List<User>();
    
    // Iterate through the new user records
    for(User u : Trigger.new) {
        // Check if the user is a Community user
        if(u.Profile.Name == 'Alumni Community Plus User') {
            communityUsers.add(u);
        }
        if(u.Profile.Name == 'Student Community Plus User') {
            communityUsers.add(u);
        }
        // if(u.Profile.Name == 'Learning institute Portal Customer User') {
        //     communityUsers.add(u);
        // }

     
        
    }

     // Update the IsActive field for Community users
    // Perform actions for Community users

    List<User> communityUsersToUpdate = new List<User>();
    for(User u : Trigger.new) {
        if(u.Profile.Name == 'Alumni Community Plus User' && u.isActive && !Trigger.oldMap.get(u.Id).isActive) {
            // If the user is a Community User and their isActive field has changed from true to false
            u.isActive = false;
            communityUsersToUpdate.add(u);
        }
        if(u.Profile.Name == 'Student Community Plus User' && u.isActive && !Trigger.oldMap.get(u.Id).isActive) {
            // If the user is a Community User and their isActive field has changed from true to false
            u.isActive = false;
            communityUsersToUpdate.add(u);
        }
    }
  


    if(!communityUsers.isEmpty()) {
        // Your code here
        update communityUsersToUpdate;

          // Set the IsActive field to false
          for(User u : communityUsers) {

            if(u.IsActive == true){
                u.IsActive = false;
            }
           
        }
        
        // Update the user records
        update communityUsers;
        System.debug('New Community user created: ' + communityUsers[0].Username);
    }
}