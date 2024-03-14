({
    /**
     Description : method to get all Sobjects dynamically
     params : component
     return : void
     **/
    objects : function(component) {

        var action= component.get("c.getObject");
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                component.set("v.options", allValues);
            }
            else{
                console.log("Unknown error")
            }
            
        });
        $A.enqueueAction(action);
    },
    
      /**
     Description : method to get the fields of the selected object in picklist
     params : component
     return : void
     **/
    getFields : function(component) {

        component.set("v.tableLabel",[]);
        
        component.set("v.selectedValues",[]);
        
        component.set("v.textAreaValues",[]);
        
        var objectName= component.get("v.selectedValue");
        
        var action=component.get("c.fieldMap");
        action.setParams({
            objname:objectName
        });
        action.setCallback(this,function(data){
            component.set("v.fields",data.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
      /**
     Description : method to create SOQL Query
     params : component
     return : void
     **/
    getQuery:function(component){
        var objectName= component.get("v.selectedValue");
        var selectedFields = component.get("v.selectedValues");
        var fieldsWithCommas = 'SELECT '+selectedFields.join(', ')+' '+'FROM '+objectName;
        component.set("v.textAreaValues",fieldsWithCommas);
        
    },
    
    /**
     Description : method to create table based on SOQL Query
     params : component, event, helper
     return : void
     **/
    getTable:function(component,event,helper){
        var objectName= component.get("v.selectedValue");
        var selectedFields = component.get("v.selectedValues");
        
        var tableColumns = [];
        selectedFields.forEach(function(field) {
            tableColumns.push({ label: field, fieldName: field, type: "string" });
        });
        component.set("v.tableLabel", tableColumns);
        
        var action=component.get("c.fieldTable");
        action.setParams({
            objname:objectName,
            fields:selectedFields
        });
        action.setCallback(this,function(data){
            component.set("v.tableData",data.getReturnValue());
        });
        $A.enqueueAction(action); 
        
    }    
})