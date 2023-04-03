import { LightningElement, api, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi'; 
import NOTE_OBJECT from '@salesforce/schema/Note'; 
import TITLE_FIELD from '@salesforce/schema/Note.Title';  
import BODY_FIELD from '@salesforce/schema/Note.Body'; 
import PARENT_ID_FIELD from '@salesforce/schema/Note.ParentId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

 export default class CustomNote extends LightningElement {
     @api recordId; 
     // Account ID passed from the parent component 
     noteTitle = ''; 
     noteBody = '';
      handleNoteTitleChange(event) {
         this.noteTitle = event.target.value; 
        } 
        handleNoteBodyChange(event) {
             this.noteBody = event.target.value; 
        }
        handleSave() { 
                    const fields = {};
                    fields[TITLE_FIELD.fieldApiName] = this.noteTitle; 
                    fields[BODY_FIELD.fieldApiName] = this.noteBody; 
                    fields[PARENT_ID_FIELD.fieldApiName] = this.recordId; 
                    const recordInput = { apiName: NOTE_OBJECT.objectApiName, fields }; 
                    
                    createRecord(recordInput) .then(() => { 
                                this.noteTitle = ''; 
                                this.noteBody = '';
                               
                                const evt = new ShowToastEvent({
                                    title: 'Toast Success',
                                    message: 'Note created successfully',
                                    variant: 'success',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                                                     
                            }).catch(error => { 
                                console.error(error);
                               
                                const evt = new ShowToastEvent({
                                    title: 'Toast Error',
                                    message: 'Error creating note',
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                            }); 
            } 
}
