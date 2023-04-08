@RestResource(urlMapping='/checkEmail/*')
global class EmailChecker {
    @HttpGet
    global static Boolean isEmailExists() {
        String email = RestContext.request.params.get('email');
        List<User> userList = [SELECT Id FROM User WHERE Email = :email];
        return !userList.isEmpty();
    }
}