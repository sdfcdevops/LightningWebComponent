global without sharing  class test {
    public test() {
      
    }
    @AuraEnabled

    public static string getRecord(String param1 , String param2){
        System.debug('test'+param1+param2);
        return 'test'+param1+param2;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [SELECT Id, Name, Email FROM Contact];
    }
    

}