import { LightningElement } from 'lwc';

export default class HelloLightingWebComponent extends LightningElement {

    message = 'Tarun Jest Test!'; 
  
  handleChange(event) {
    this.message = event.target.value;
  }
}