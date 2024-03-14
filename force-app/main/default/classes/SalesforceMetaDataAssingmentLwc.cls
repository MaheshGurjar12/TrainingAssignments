public class SalesforceMetaDataAssingmentLwc {
        
    /**
     Description : method to fetch all the sobjects dynamically from database
     params : None
     return : the sobjects fetched from database
     **/
    @AuraEnabled
    public static List<string> getObject(){

        List<String> objects = new List<String>();

        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        for(Schema.SObjectType sobj : gd){
            objects.add(sobj.getDescribe().getName());
        }
       objects.sort();
                System.debug('objetcs    =>'+objects);
        return objects;
    }
          
   /**
     Description : method to fetch all the fields of the selected object dynamically
     params : string objname
     return : the fields of the selected sObject fetched from database
     **/
    @AuraEnabled
    public static List<wrapper> fieldMap(string objname){

        List<wrapper> fieldsList = new List<wrapper>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType sobjType = gd.get(objname); 
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
        
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
            wrapper wrapperObject =new wrapper(); 
            wrapperObject.label = fieldName;
            wrapperObject.value = string.valueof(fieldsMap.get(fieldName));
            fieldsList.add(wrapperObject);
        }
        return fieldsList;
    }

     /**
     Description : wrapper class to store field label and value
     params : None
     return : void
     **/
    public class wrapper{
        @auraEnabled public String label;
        @auraEnabled public String value;
    }
    
     /**
     Description : method to create table based on SOQL Query
     params : string objname, List<string> fields
     return : sobject data fetched from the database
     **/
    @AuraEnabled
    public static   List<SObject> fieldTable(string objname, List<string> fields){
        System.debug('fieldTable');
        String soqlQuery = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objname;
        
        List<SObject> objectData = Database.query(soqlQuery);
        System.debug(objectData);
        return   objectData;
    }
    
}