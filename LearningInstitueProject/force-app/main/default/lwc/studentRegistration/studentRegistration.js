import { LightningElement, track ,wire} from 'lwc';
//import isEmailExists from '@salesforce/apex/StudentAuthController.isEmailExists';
// import registerUser from '@salesforce/apex/StudentAuthController.registerUser';
import createAccount from '@salesforce/apex/StudentAuthController.createAccount';

import backgroundUrl from '@salesforce/resourceUrl/RegisterBg';

export default class StudentRegistration extends LightningElement {

    email = '';
    // @wire(isEmailExists, { email: '$email' })
    // isEmailExists;

    @track termsAndConditions = false;
    @track title = null;
    @track firstName = null;
    @track lastName = null;
    
    @track userName = null;
    @track password = null;
    @track confirmPassword = null;
    @track errorCheck;
    @track errorMessage;
    showUserName;
    @track showTermsAndConditions;
    @track showTermsAndConditionsLoading = false;
    @track infoTooltipDisplayData = {};
    @track requiredTooltipDisplayData = {};
    @track errorTooltipDisplayData = {};
    @track emailError;
    @track passwordError;

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
      }

      @track isShowModal = false;

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    connectedCallback(){


        var meta = document.createElement("meta");
        meta.setAttribute("name", "viewport");
        meta.setAttribute("content", "width=device-width, initial-scale=1.0");
        document.getElementsByTagName('head')[0].appendChild(meta);
        //this.showUserName = false;

        // this.infoTooltipDisplayData.username = "tooltiptext usernameTooltiptext";
        this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";
        this.requiredTooltipDisplayData.title = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        // this.requiredTooltipDisplayData.username = 'tooltiptext tooltipHide';        
        // this.requiredTooltipDisplayData.hearAboutUs = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.errorTooltipDisplayData.password = 'tooltiptext tooltipHide';
    }

    onEmailInvalid(event){

        if (!event.target.validity.valid) {
            event.target.setCustomValidity('Enter a valid email address')
        }
        
    }

    onEmailInput(event){

        event.target.setCustomValidity('')
    }

    onEmailClick(event){

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.remove('tooltipEmail');
    }

    onEmailBlur(event){

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.add('tooltipEmail');
    }

    handleRegisterClick() {
        createAccount({ firstName: this.firstName, lastName: this.lastName, email: this.email, password: this.password })
            .then(() => {
                // Account created successfully
                console.log("success");
            })
            .catch(error => {
                // Handle error

                console.log(error.message);
            });
    }


    handleRegister(event){

        this.errorCheck = false;
        this.errorMessage = null;

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.errorTooltipDisplayData.password = 'tooltiptext tooltipHide';
        if(!this.title){

            this.requiredTooltipDisplayData.title = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.title = 'tooltiptext tooltipHide';
        }
        if(!this.firstName){

            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        }

        if(!this.lastName){

            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipShow';

        } else {
            
            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        }

        if(!this.email){

            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipShow';

        } else {
            
            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        }

    

        if(!this.password){

            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipShow';
            this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";

        } else {
            
            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';
        }

        if(!this.confirmPassword){

            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipShow';

        } else {
            
            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';
        }

        
        
        if(this.title && this.firstName && this.lastName && this.email && this.userName && this.hearAboutUs && this.password && this.confirmPassword){

            this.showTermsAndConditionsLoading = true;

            if(this.password != this.confirmPassword){

                this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";
                this.passwordError = 'Password did not match. Please Make sure both the passwords match.';
                this.errorTooltipDisplayData.password = 'tooltiptext tooltipShow tooltipError';

                event.preventDefault();

                this.showTermsAndConditionsLoading = false;
                
                return;
            }

            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);

            console.log('emailCheck--',emailCheck);

    



            if( emailCheck == null || emailCheck == undefined || emailCheck == false ){

                this.showTermsAndConditionsLoading = false;
                console.log('inside email check');
                
                this.emailError = 'Please enter a valid email address';
                this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';
                
                return;
            }

            let passwordCheck = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/.test(this.password);

            if(passwordCheck == null || passwordCheck == undefined || passwordCheck == false){

                this.showTermsAndConditionsLoading = false;

                this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";
                this.passwordError = 'Password must be Minimum eight characters, at least one letter, one number and one special character.';
                this.errorTooltipDisplayData.password = 'tooltiptext tooltipShow tooltipError';
                
                return;
            }
            
            event.preventDefault();

            // checkEmail(event.target.value).then(result => {
            //     if (result) {
            //         console.log('Email already exists');
            //     } else {
            //         console.log('Email does not exist');
            //     }
            // });


            // isEmailExists({ email: this.email })
            // .then((result) => {

            //     console.log('login result---'+result, typeof result);
                
            //     if(result != null && result != undefined && result == true){

            //         this.emailError = 'Your username already exists somewhere on the  Salesforce Ecosystem.';
            //         this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';

            //         this.showTermsAndConditionsLoading = false;

            //     } else {

            //         registerUser({ firstName: this.firstName, lastName: this.lastName, username: this.userName, email: this.email, communityNickname: this.firstName, password: this.password, })
            //             .then((result) => {
                                        
            //                 if(result){            
                                          
            //                     window.location.href = result;
            
            //                 } 
							
            //                 this.showTermsAndConditionsLoading = false;
            //             })
            //             .catch((error) => {
            //                 this.error = error;
            
            //                 console.log('error-',error);
            
            //                 this.showTermsAndConditionsLoading = false;
            
            //                 if(error && error.body && error.body.message){
            
            //                     this.showTermsAndConditions = false;
            //                     this.errorCheck = true;
            //                     this.errorMessage = error.body.message;
                               
            //                 }           
                            
            //             });
            //     }

                
            // })
            // .catch((error) => {
            //     this.error = error;
             
            //     if(error && error.body && error.body.message){
                    
            //         console.log('error msg-', error.body.message);
            //     }

            //     this.showTermsAndConditionsLoading = false;
				
            // });
        
        }

        
    }

    handleTermsAndConditions(event){

        this.showTermsAndConditions = true;
    }

    handleFirstNameChange(event){
        if(!event.target.value){
            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipShow';

        }
        else
        {
            this.requiredTooltipDisplayData.title = 'tooltiptext tooltipHide';

        }

        this.firstName = event.target.value;
    }

    handleTitleChange(event){
      
        if(!event.target.value){
            this.requiredTooltipDisplayData.title = 'tooltiptext tooltipShow';

        }
        else
        {
            this.requiredTooltipDisplayData.title = 'tooltiptext tooltipHide';

        }
        this.title = event.target.value;
    }


    handleLastNameChange(event){

        this.lastName = event.target.value;

        if(!event.target.value){
            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipShow';

        }
        else
        {
            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';

        }

    }

    handleEmailChange(event){

    
        if(event.target.value){

            this.email = event.target.value;
            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        
        } else {
            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipShow';
            this.email = event.target.value;
            
        }
    }  

    handlePasswordChange(event){

        this.password = event.target.value;

        if(!event.target.value){
            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipShow';

        }
        else
        {
            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';

        }

    }

    handleConfirmPasswordChange(event){

        this.confirmPassword = event.target.value;

        if(!event.target.value){
            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipShow';

        }
        else
        {
            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';

        }
    }

    closeTermsAndConditions(event){

        this.showTermsAndConditions = false;
    }


    handleEmailHover(event){
    }

}

// function checkEmail(email) {
//     return fetch('/services/apexrest/checkEmail?email=' + email)
//         .then(response => response.json())
//         .then(data => data[0].IsEmailExists);
// }