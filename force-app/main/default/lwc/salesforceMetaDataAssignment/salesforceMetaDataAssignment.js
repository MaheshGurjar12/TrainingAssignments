import { LightningElement, track } from 'lwc';
import getObject from '@salesforce/apex/SalesforceMetaDataAssingmentLwc.getObject';
import fieldMap from '@salesforce/apex/SalesforceMetaDataAssingmentLwc.fieldMap';
import fieldTable from '@salesforce/apex/SalesforceMetaDataAssingmentLwc.fieldTable';
export default class SalesforceMetaDataAssignment extends LightningElement {
    selectedObject = '';
    objects = [];
    fields = [];
    cardVisible = false;
    buttonVisible = false;
    textAreaVisible = false;
    tableButton = false;
    selectedvalues = [];
    soqlQuery = '';
    objtableColumns = [];
    tableData = [];

    /** 
     Description : getter for combobox  
     params : None
     return : sobjects
     **/
    get objects() {
        return this.objects;
    }

    /**
     Description : getter for selected values in dualList-box
     params : None
     return : selcted values from dual-listbox
     **/
    get selectedvalues() {
        return this.selectedvalues.length ? this.selectedvalues : 'none';
    }

     /**
     Description : method to call apex method to get all objects
     params : None
     return : void
     **/
    connectedCallback() {
        getObject()
            .then(result => {
                let data = JSON.parse(JSON.stringify(result));
                let arr = [];
                for (var i = 0; i < data.length; i++) {
                    arr.push({ value: data[i], label: data[i] })
                }
                this.objects = arr;
            }).catch(error => {
                window.alert("error:" + error)
            })
    }

    /**
     Description : method to get selected objects' fields
     params : event
     return : void
     **/
    displayFields(event) {

        this.buttonVisible = false;
        this.textAreaVisible = false;
        this.tableButton = false;
        this.selectedvalues = [];
        this.soqlQuery = '';
        this.objtableColumns = [];


        this.cardVisible = true;
        this.selectedObject = event.detail.value;

        fieldMap({ objname: this.selectedObject })  
            .then(result => {
                this.fields = result;
            })
            .catch(error => {
                window.alert("errormsg:" + error)
            })
    }

    /**
     Description : method to get selected values from dual-listbox
     params : event
     return : void
     **/
    dualChange(event) {
        this.selectedvalues = event.detail.value;
        this.buttonVisible = true;
    }

     /**
     Description : method to create SOQL Query
     params : None
     return : void
     **/
    createQuery() {
        this.textAreaVisible = true;
        var objectName = this.selectedObject;
        var selectedFields = this.selectedvalues;
        this.soqlQuery = 'SELECT ' + selectedFields.join(', ') + ' ' + 'FROM ' + objectName;
        this.tableButton = true;
    }

    /**
     Description : method to create table based on SOQL Query
     params : None
     return : void
     **/
    getTable() {
        var objectName = this.selectedObject;
        var selectedFields = this.selectedvalues;

        var tableColumns = [];
        selectedFields.forEach(function (field) {
            tableColumns.push({ label: field, fieldName: field, type: "string" });
        });
        this.objtableColumns = tableColumns;

        fieldTable({ objname: objectName, fields: selectedFields })
            .then(result => {
                this.tableData = result;
            })
            .catch(error => {
                window.alert(`Error message: ${error}`);
            });
    }

}