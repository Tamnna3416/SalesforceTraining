import { LightningElement, track } from 'lwc';
 
export default class HelloWorld extends LightningElement {
    @track name = 'Developer';
 
    handleChange(event) {
        this.name = event.target.value;
    }
   
    // Lifecycle Hooks
    constructor() {
        super();
        console.log('constructor called');
    }
 
    connectedCallback() {
        console.log('connectedCallback called');
    }
 
    renderedCallback() {
        console.log('renderedCallback called');
    }
 
    disconnectedCallback() {
        console.log('disconnectedCallback called');
    }
 
    errorCallback(error, stack) {
        console.error('errorCallback:', error, stack);
    }
}