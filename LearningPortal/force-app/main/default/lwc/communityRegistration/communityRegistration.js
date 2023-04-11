import { LightningElement,track,wire } from 'lwc';
import isguest from '@salesforce/user/isGuest';
import createUser from '@salesforce/apex/CommunityRegistrationController.createUser';
import checkApiCallAccess from '@salesforce/apex/CommunityRegistrationController.checkApiCallAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CommunityRegistration extends LightningElement {

 

   @track showTermsAndConditions;
   @track showTermsAndConditionsLoading = false;
    @track userType = 0;
    @track title;
    @track firstName;
    @track lastName;
    @track email;
    @track password;
    @track confirmPassword;
    @track email;
    @track agreeTerm;
    @track showPasswordError = false;
    @track errorMessage = '';
    @track checkApexClass = '';
    @track errorBlock = false;


    //This method is for get the user agree term & Condtion yes or not !
    handleAgreeTermChange(event) {
          if (event.target.checked) {
            this.agreeTerm = true;
          } else {
            this.agreeTerm = false;
          }
          console.log("I agree to the Terms & Conditions Value > : "+this.agreeTerm);
      }

      options = [
        { label: 'Student', value: '1' },
        { label: 'Student Alumni', value: '2' },
      
      ];
     


      handleRegTypeChange(event) {
        this.userType = event.detail.value;
        console.log("Select an Category > : "+this.userType);
        this.userType = event.detail.value;
        if (this.userType.length == 0) {
            this.errorBlock = true;
            this.errorMessage = 'Complete Category field.';
        } else {
            this.errorBlock = false;
            this.errorMessage = '';
        }

      }

      handleTitleChange(event){
        this.title = event.target.value;
      }
     
      handleFnameChange(event){
        this.firstName = event.target.value;

      }
      handleLnameChange(event){
        this.lastName = event.target.value;
      }

      handleEmailChange(event){

        if (!event.target.validity.valid) {
          this.errorEmailMessage = 'Please enter a valid email address';
        } else {
          this.errorEmailMessage = '';
          this.email = event.detail.value;
        }


       
      }
      validatePasswords() {
        if (this.password !== this.confirmPassword) {
          this.showPasswordError = true;
        } else {
          this.showPasswordError = false;
        }
      }

      handlePasswordChange(event) {
        this.password = event.target.value;
        
      }
    
      handleConfirmPasswordChange(event) {
        this.confirmPassword = event.target.value;
        this.validatePasswords();
      }
      isGuestUser = isguest;

      handleRegisterClick(){

        if (this.userType == 0) {
          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Category field!';
        }
        else if(!this.title){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Title field!';
  
        } 
        else if(!this.firstName){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete First Name field!';
  
        }
        else if(!this.lastName){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Last Name field!';
  
        }
        else if(!this.email){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Email field!';
  
        }
        else if(!this.password){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Password field!';
  
        }
        else if(!this.confirmPassword){

          this.errorBlock = true;
          this.errorMessage = 'Error : Complete Confirm Password field!';
  
        }
        else if(!this.agreeTerm){

          this.errorBlock = true;
          this.errorMessage = 'Error : Please Agree to the Terms & Conditions!';
  
        }

        else {

          this.errorBlock = false;
          this.errorMessage = '';

          createUser({ userType: this.userType,title:this.title, firstName: this.firstName, lastName: this.lastName, email: this.email, password: this.password}
          ) .then(result => {

            console.log('variable:', result);

          });
          
          //Request apex class controller for create new user
      }



      }
      // Register Button Function 
    //  handleRegisterClickk() {

        // getRecord({ param1: this.param1, param2: this.param2 });

        // CommunityUserCheck({email:this.email}).then(result => {
        //   console.log('success'+result);
        // })

        // createCommunityUser({ Salutation: this.selectedSalutation, firstName: this.firstName, lastName: this.lastName, email: this.email, password: this.password})
        // .then(result => {

        //   console.log('Result name'+result[0]);

        // });


        // if (this.password === this.confirmPassword) {
        //     // Passwords match, do something
        //     this.showPasswordError = false; // hide error message if it was previously displayed
        //   } else {
        //     // Passwords do not match, show error message
        //     this.showPasswordError = true;
        //   }
     // }
}