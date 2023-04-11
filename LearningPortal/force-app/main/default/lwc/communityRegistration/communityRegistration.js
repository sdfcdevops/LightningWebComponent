import { LightningElement,track,wire } from 'lwc';
import isguest from '@salesforce/user/isGuest';
import createUser from '@salesforce/apex/CommunityRegistrationController.createUser';
import checkApiCallAccess from '@salesforce/apex/CommunityRegistrationController.checkApiCallAccess';
import CommunityUserCheck from '@salesforce/apex/CommunityRegistrationController.CommunityUserCheck'
import isEmailExist from '@salesforce/apex/CommunityRegistrationController.isEmailExist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CommunityRegistration extends LightningElement {
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
    @track errorEmailDupicateMessage = '';
    @track errorBlock = false;
    @track errorEmailBlock = false;
    @track errorCheck;
    @track communityNickname;

    //This method is for get the user agree term & Condtion yes or not !
    handleAgreeTermChange(event) {

      checkApiCallAccess({ name: 'Student'}).then(result => {

        //console.log('variable:', result);

      });
     
          if (event.target.checked) {
            this.agreeTerm = true;
          } else {
            this.agreeTerm = false;
          }
          //console.log("I agree to the Terms & Conditions Value > : "+this.agreeTerm);
      }

      options = [
        { label: 'Student', value: '1' },
        { label: 'Student Alumni', value: '2' },
      
      ];

      handleRegTypeChange(event) {
        this.userType = event.detail.value;
        //console.log("Select an Category > : "+this.userType);
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
        const eventData = new ShowToastEvent({
          title: 'Success',
          message: 'Account created successfully!',
          variant: 'success',
      });
      this.dispatchEvent(eventData);
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
         
          //CommunityUserCheck({ email: event.detail.value}).then(result => {
            isEmailExist({ email: event.detail.value}).then(result => {
          
            if(result){
              this.errorEmailBlock = true;
              this.errorEmailDupicateMessage = 'E-Mail address already exists!';
            }
            else {
              this.errorEmailDupicateMessage = '';
              this.errorEmailMessage = '';
              this.errorEmailBlock = false;
              this.email = event.detail.value;
            }
            //console.log('variable:', result);
    
          });
         
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

          isEmailExist({ email: this.email })
            .then((result) => {

                console.log('login result---'+result, typeof result);
                
                if(result != null && result != undefined && result == true){

                  this.errorEmailBlock = true;
                  this.errorEmailDupicateMessage = 'E-Mail address already exists!';
                 // this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';

                 // this.showTermsAndConditionsLoading = false;

              } else {

                this.errorEmailBlock = false;
                this.errorEmailDupicateMessage = '';

                createUser({ userType: this.userType,title:this.title, communityNickname: this.firstName,firstName: this.firstName, lastName: this.lastName, email: this.email, password: this.password}
                ).then((result) => {
                                        
                              if(result){            
                                            
                                 //window.location.href = result;

                                 const event = new ShowToastEvent({
                                  title: 'Success',
                                  message: 'Account created successfully!',
                                  variant: 'success',
                              });
                              this.dispatchEvent(event);
                              this.userType = null;
                              this.title = '';
                              this.firstName = '';
                              this.lastName = '';
                              this.password = '';
                              this.confirmPassword = '';
                              this.agreeTerm = false;

                          }
                 }).catch((error) => {
                           this.error = error;
                           console.log('error-',error);   
                           if(error && error.body && error.body.message){

                          this.showTermsAndConditions = false;
                          this.errorCheck = true;
                          this.errorMessage = error.body.message;
           
                           }           
        
                  });
              }
            }).catch((error) => {
                    this.error = error;

                      if(error && error.body && error.body.message){
                          
                          console.log('error msg-', error.body.message);
                      }
                });
        }
  }
}