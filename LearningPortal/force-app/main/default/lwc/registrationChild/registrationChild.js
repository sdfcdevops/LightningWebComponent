import { LightningElement } from 'lwc';
import USER_IMAGE from '@salesforce/resourceUrl/userIcon';
import MY_IMAGE from '@salesforce/resourceUrl/RegisterBackground';
export default class RegistrationChild extends LightningElement {

    userIcon = USER_IMAGE;
    imageUrl = MY_IMAGE;
}